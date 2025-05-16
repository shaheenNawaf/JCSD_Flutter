// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_import

//Default Imports
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

//Backend Imports
// Employee
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart';

// Purchase Order
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';
import 'package:jcsd_flutter/view/inventory/purchase_orders/modals/view_approve_po_modal.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';

// Suppliers and Inventory
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';

class ReceivingLineItemEntry {
  final PurchaseOrderItemData poItem;
  final TextEditingController quantityReceivedNowController;
  final List<TextEditingController> serialNumberControllers;
  final GlobalKey<FormFieldState<String>> quantityFormFieldKey;
  final String productName;

  ReceivingLineItemEntry({required this.poItem, required this.productName})
      : quantityReceivedNowController = TextEditingController(),
        serialNumberControllers = [],
        quantityFormFieldKey = GlobalKey<FormFieldState<String>>();

  int get quantityActuallyOrdered => poItem.quantityOrdered;
  int get quantityAlreadyReceived => poItem.quantityReceived;
  int get quantityRemainingToReceive =>
      quantityActuallyOrdered - quantityAlreadyReceived;

  void dispose() {
    quantityReceivedNowController.dispose();
    for (var controller in serialNumberControllers) {
      controller.dispose();
    }
  }

  void updateSerialControllers(String quantityStr) {
    final newQuantity = int.tryParse(quantityStr) ?? 0;
    if (newQuantity < 0) return;

    final effectiveQuantity = newQuantity > quantityRemainingToReceive
        ? quantityRemainingToReceive
        : newQuantity;

    while (serialNumberControllers.length > effectiveQuantity) {
      serialNumberControllers.removeLast().dispose();
    }
    while (serialNumberControllers.length < effectiveQuantity) {
      serialNumberControllers.add(TextEditingController());
    }
  }
}

class ReceivePurchaseOrderItemsModal extends ConsumerStatefulWidget {
  final PurchaseOrderData initialPurchaseOrderHeader;

  const ReceivePurchaseOrderItemsModal(
      {super.key, required this.initialPurchaseOrderHeader});

  @override
  ConsumerState<ReceivePurchaseOrderItemsModal> createState() =>
      _ReceivePurchaseOrderItemsModalState();
}

class _ReceivePurchaseOrderItemsModalState
    extends ConsumerState<ReceivePurchaseOrderItemsModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  List<ReceivingLineItemEntry> _lineItemEntries = [];
  DateTime _dateReceived = DateTime.now();
  Map<String?, String> _productNameMap = {};
  bool _dataFullyLoadedAndInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchProductNames();
  }

  Future<void> _fetchProductNames() async {
    final productDefinitionsStateValue =
        await ref.read(productDefinitionNotifierProvider(true).future);
    if (mounted) {
      _productNameMap = productDefinitionsStateValue.productDefinitions
          .fold<Map<String?, String>>({}, (map, pd) {
        if (pd.prodDefID != null) {
          map[pd.prodDefID!] = pd.prodDefName;
        }
        return map;
      });
      if (_dataFullyLoadedAndInitialized) {
        final currentPOData = ref
            .read(
                poDetailsProviderFamily(widget.initialPurchaseOrderHeader.poId))
            .asData
            ?.value;
        if (currentPOData != null) {
          _initializeLineItemEntriesFromFetchedPO(currentPOData);
          if (mounted) setState(() {});
        }
      }
    }
  }

  void _initializeLineItemEntriesFromFetchedPO(PurchaseOrderData fullPO) {
    if (!_productNameMap.isNotEmpty && (fullPO.items?.isNotEmpty ?? false)) {
      return;
    }
    for (var entry in _lineItemEntries) {
      entry.dispose();
    }
    _lineItemEntries = fullPO.items
            ?.where((item) => item.quantityReceived < item.quantityOrdered)
            .map((poItem) {
          final productName = _productNameMap[poItem.prodDefID] ??
              'Prod. ID: ${poItem.prodDefID.substring(0, 6)}...';
          return ReceivingLineItemEntry(
              poItem: poItem, productName: productName);
        }).toList() ??
        [];
    _dataFullyLoadedAndInitialized = true;
  }

  @override
  void dispose() {
    for (var entry in _lineItemEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDateReceived(
      BuildContext context, DateTime orderDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateReceived,
      firstDate: orderDate,
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _dateReceived) {
      setState(() {
        _dateReceived = picked;
      });
    }
  }

  Future<void> _submitReceipt(PurchaseOrderData currentFullPO) async {
    if (!_formKey.currentState!.validate()) {
      ToastManager().showToast(
          context, 'Please correct errors before submitting.', Colors.orange);
      return;
    }

    final currentAuthUserId = supabaseDB.auth.currentUser?.id;
    if (currentAuthUserId == null) {
      ToastManager()
          .showToast(context, 'Error: User not authenticated.', Colors.red);
      return;
    }

    int? receivingEmployeeId;
    try {
      final employeeRecord = await supabaseDB
          .from('employee')
          .select('employeeID')
          .eq('userID', currentAuthUserId)
          .maybeSingle();
      if (employeeRecord != null && employeeRecord['employeeID'] != null) {
        receivingEmployeeId = employeeRecord['employeeID'] as int;
      } else {
        throw Exception(
            'Receiving employee record not found for current user.');
      }
    } catch (e) {
      ToastManager().showToast(
          context, 'Error fetching your employee ID: $e', Colors.red);
      return;
    }

    setState(() => _isProcessing = true);
    bool overallSuccess = true;
    String overallErrorMessage = "";
    int itemsAttemptedToProcessCount = 0;

    for (var entry in _lineItemEntries) {
      final qtyReceivedNowStr = entry.quantityReceivedNowController.text.trim();
      if (qtyReceivedNowStr.isEmpty) continue;

      final qtyReceivedNow = int.tryParse(qtyReceivedNowStr) ?? 0;
      if (qtyReceivedNow <= 0) continue;
      itemsAttemptedToProcessCount++;

      if (entry.serialNumberControllers.length != qtyReceivedNow) {
        ToastManager().showToast(
            context,
            'Serial count must match "Qty Receiving Now" for ${entry.productName}. Expected $qtyReceivedNow, got ${entry.serialNumberControllers.length}.',
            Colors.orange);
        overallSuccess = false;
        break;
      }
      if (entry.serialNumberControllers
          .any((controller) => controller.text.trim().isEmpty)) {
        ToastManager().showToast(
            context,
            'All serial numbers must be entered for ${entry.productName} if quantity is > 0.',
            Colors.orange);
        overallSuccess = false;
        break;
      }
    }

    if (!overallSuccess && itemsAttemptedToProcessCount > 0) {
      if (mounted) setState(() => _isProcessing = false);
      return;
    }
    if (itemsAttemptedToProcessCount == 0 &&
        _lineItemEntries.any(
            (e) => e.quantityReceivedNowController.text.trim().isNotEmpty)) {
      // This means some quantities were entered but were invalid (e.g., 0)
    } else if (itemsAttemptedToProcessCount == 0) {
      ToastManager().showToast(context,
          'No quantities entered to receive for any item.', Colors.blue);
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    for (var entry in _lineItemEntries) {
      final qtyReceivedNowStr = entry.quantityReceivedNowController.text.trim();
      if (qtyReceivedNowStr.isEmpty) continue;
      final qtyReceivedNow = int.parse(qtyReceivedNowStr);
      if (qtyReceivedNow <= 0) continue;

      final serials =
          entry.serialNumberControllers.map((c) => c.text.trim()).toList();

      try {
        await ref
            .read(purchaseOrderListNotifierProvider.notifier)
            .receiveItemsForPOItem(
              poId: currentFullPO.poId,
              poItemId: entry.poItem.purchaseItemID!,
              quantityReceivedNow: qtyReceivedNow,
              serialNumbers: serials,
              employeeId: receivingEmployeeId!,
              dateReceived: _dateReceived,
            );
      } catch (e) {
        overallSuccess = false;
        overallErrorMessage +=
            'Error receiving ${entry.productName}: ${e.toString()}\n';
      }
    }

    if (overallSuccess) {
      ToastManager()
          .showToast(context, 'Items received successfully!', Colors.green);
      ref.invalidate(poDetailsProviderFamily(currentFullPO.poId));
      Navigator.of(context).pop(true);
    } else {
      ToastManager().showToast(
          context,
          'Some items failed to receive. Details: $overallErrorMessage',
          Colors.red);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final poDetailsAsync = ref
        .watch(poDetailsProviderFamily(widget.initialPurchaseOrderHeader.poId));

    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = screenWidth > 800 ? 850 : screenWidth * 0.95;
    final supplierNamesMapAsync = ref.watch(supplierNameMapProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 30.0 : 10.0),
      child: SizedBox(
        width: modalWidth,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Form(
          key: _formKey,
          child: poDetailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text("Error loading PO details: $err")),
              data: (fullPO) {
                if (fullPO == null) {
                  return const Center(
                      child: Text(
                          "Could not load purchase order details. Please try again."));
                }

                if (!_dataFullyLoadedAndInitialized &&
                    _productNameMap.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _initializeLineItemEntriesFromFetchedPO(fullPO);
                      setState(() {});
                    }
                  });
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0),
                      decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Receive Items for PO #${fullPO.poId}',
                              style: const TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white)),
                          IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: "Close")
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          supplierNamesMapAsync.when(
                            data: (map) => Text(
                                'Supplier: ${map[fullPO.supplierID] ?? 'ID: ${fullPO.supplierID}'}',
                                style: const TextStyle(
                                    fontFamily: 'NunitoSans', fontSize: 13)),
                            loading: () => const Text('Supplier: Loading...',
                                style: TextStyle(
                                    fontFamily: 'NunitoSans', fontSize: 13)),
                            error: (e, s) => const Text('Supplier: Error',
                                style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontSize: 13,
                                    color: Colors.red)),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(
                                'Date Received: ${DateFormat('MM/dd/yyyy').format(_dateReceived)}',
                                style: const TextStyle(
                                    fontFamily: 'NunitoSans', fontSize: 13)),
                            onPressed: () =>
                                _selectDateReceived(context, fullPO.orderDate),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: !_dataFullyLoadedAndInitialized
                          ? const Center(child: CircularProgressIndicator())
                          : _lineItemEntries.isEmpty
                              ? const Center(
                                  child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "All items for this PO have been fully received, no items were on the PO, or product names are still loading.",
                                    style: TextStyle(
                                        fontFamily: 'NunitoSans',
                                        color: Colors.grey,
                                        fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _lineItemEntries.length,
                                  itemBuilder: (context, index) {
                                    final entry = _lineItemEntries[index];
                                    return _buildLineItemEntryWidget(
                                        entry, index);
                                  },
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Cancel')),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: _isProcessing
                                ? Container()
                                : const Icon(Icons.check_circle_outline,
                                    size: 18),
                            label: _isProcessing
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Confirm Receipt & Add Serials'),
                            onPressed: _isProcessing ||
                                    (!_dataFullyLoadedAndInitialized ||
                                        _lineItemEntries.isEmpty)
                                ? null
                                : () => _submitReceipt(fullPO),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildLineItemEntryWidget(
      ReceivingLineItemEntry entry, int itemIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.productName,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NunitoSans')),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ordered: ${entry.quantityActuallyOrdered}',
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'NunitoSans')),
                Text('Received: ${entry.quantityAlreadyReceived}',
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'NunitoSans')),
                Text('Remaining: ${entry.quantityRemainingToReceive}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'NunitoSans')),
              ],
            ),
            const SizedBox(height: 8),
            if (entry.quantityRemainingToReceive > 0)
              TextFormField(
                key: entry.quantityFormFieldKey,
                controller: entry.quantityReceivedNowController,
                decoration: InputDecoration(
                  labelText:
                      'Quantity Receiving Now (Max: ${entry.quantityRemainingToReceive})',
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  labelStyle:
                      const TextStyle(fontSize: 12, fontFamily: 'NunitoSans'),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final formFieldState =
                      entry.quantityFormFieldKey.currentState;
                  if ((formFieldState != null && formFieldState.validate()) ||
                      value.isEmpty) {
                    setState(() {
                      entry.updateSerialControllers(value);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final qty = int.tryParse(value);
                  if (qty == null) return 'Invalid num';
                  if (qty < 0) return 'Cannot be <0';
                  if (qty > entry.quantityRemainingToReceive) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted &&
                          entry.quantityReceivedNowController.text !=
                              entry.quantityRemainingToReceive.toString()) {
                        entry.quantityReceivedNowController.text =
                            entry.quantityRemainingToReceive.toString();
                        entry.quantityReceivedNowController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: entry.quantityReceivedNowController.text
                                    .length));
                        setState(() {
                          entry.updateSerialControllers(
                              entry.quantityRemainingToReceive.toString());
                        });
                      }
                    });
                    return 'Max ${entry.quantityRemainingToReceive}';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            if (entry.quantityRemainingToReceive == 0)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("All units received for this item.",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontFamily: 'NunitoSans')),
              ),
            if (entry.serialNumberControllers.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                  'Enter Serial Numbers (${entry.serialNumberControllers.length}):',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'NunitoSans')),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entry.serialNumberControllers.length,
                itemBuilder: (context, serialIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 16.0),
                    child: TextFormField(
                      controller: entry.serialNumberControllers[serialIndex],
                      decoration: InputDecoration(
                        labelText: 'Serial #${serialIndex + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        labelStyle: const TextStyle(
                            fontSize: 11, fontFamily: 'NunitoSans'),
                      ),
                      style: const TextStyle(
                          fontSize: 12, fontFamily: 'NunitoSans'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Serial #${serialIndex + 1} is required'
                          : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
