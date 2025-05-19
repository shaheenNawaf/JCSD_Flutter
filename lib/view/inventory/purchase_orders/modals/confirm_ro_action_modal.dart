// lib/view/inventory/return_orders/modals/create_return_order_modal.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart'; // To get PO details
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart'; // For poDetailsProviderFamily
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/services/purchase_order_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart'; // To get product_def_id from serial
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart'; // For serial item details
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // For supplier name
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/view/inventory/purchase_orders/modals/view_approve_po_modal.dart';
// You'll need a notifier for Return Orders soon
// import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_notifier.dart';

// Provider to fetch details of the original serial item being returned
final returningSerialItemDetailsProvider = FutureProvider.autoDispose
    .family<SerializedItem?, String>((ref, serialNumber) async {
  if (serialNumber.isEmpty) return null;
  return ref
      .watch(serialitemServiceProvider)
      .getSerializedItemBySerial(serialNumber);
});

class CreateReturnOrderModal extends ConsumerStatefulWidget {
  final int purchaseOrderId;
  final String
      serialNumberToReturn; // The specific serial number being returned
  final String productName; // Name of the product for display

  const CreateReturnOrderModal({
    super.key,
    required this.purchaseOrderId,
    required this.serialNumberToReturn,
    required this.productName,
  });

  @override
  ConsumerState<CreateReturnOrderModal> createState() =>
      _CreateReturnOrderModalState();
}

class _CreateReturnOrderModalState
    extends ConsumerState<CreateReturnOrderModal> {
  final _formKey = GlobalKey<FormState>();
  final _returnReasonController = TextEditingController();
  final _overallNotesController = TextEditingController();
  DateTime _returnDate = DateTime.now();
  bool _isSubmitting = false;

  String? _selectedReturnReason;
  final List<String> _returnReasons = [
    "Defective on Arrival",
    "Warranty Claim",
    "Incorrect Item Shipped",
    "Damaged in Transit",
    "Other (Specify in notes)"
  ];

  @override
  void dispose() {
    _returnReasonController.dispose();
    _overallNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate,
      firstDate:
          DateTime.now().subtract(const Duration(days: 30)), // Example range
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null && picked != _returnDate) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  Future<void> _submitReturnRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedReturnReason == null) {
      ToastManager().showToast(
          context, "Please select a reason for return.", Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    final poDetailsAsync =
        ref.read(poDetailsProviderFamily(widget.purchaseOrderId));
    final serialDetailsAsync = ref
        .read(returningSerialItemDetailsProvider(widget.serialNumberToReturn));

    final poDetails = poDetailsAsync.asData?.value;
    final serialDetails = serialDetailsAsync.asData?.value;

    if (poDetails == null || serialDetails == null) {
      ToastManager().showToast(
          context, "Error: Original PO or item details not found.", Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }

    final currentAuthUserId = supabaseDB.auth.currentUser?.id;
    if (currentAuthUserId == null) {
      ToastManager().showToast(
          context, "Authentication error. Please log in.", Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }
    final employeeIDResponse = await supabaseDB
        .from('employee')
        .select('employeeID')
        .eq('userID', currentAuthUserId)
        .maybeSingle();
    if (employeeIDResponse == null ||
        employeeIDResponse['employeeID'] == null) {
      ToastManager().showToast(
          context, "Employee record not found for current user.", Colors.red);
      setState(() => _isSubmitting = false);
      return;
    }
    final int currentEmployeeId = employeeIDResponse['employeeID'] as int;

    String fullReason = _selectedReturnReason!;
    if (_selectedReturnReason == "Other (Specify in notes)" &&
        _returnReasonController.text.trim().isNotEmpty) {
      fullReason = "Other: ${_returnReasonController.text.trim()}";
    } else if (_selectedReturnReason == "Other (Specify in notes)" &&
        _returnReasonController.text.trim().isEmpty) {
      ToastManager().showToast(context,
          "Please specify reason if 'Other' is selected.", Colors.orange);
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final returnService = ref
          .read(purchaseOrderServiceProvider)
          .returnOrderService; // Assuming you add this getter

      await returnService.createReturnOrder(
        purchaseOrderId: widget.purchaseOrderId,
        supplierId: poDetails.supplierID,
        createdByEmployeeId: currentEmployeeId,
        returnDate: _returnDate,
        reasonForReturn: fullReason, // This is now the item-specific reason
        notes: _overallNotesController.text.trim().isEmpty
            ? null
            : _overallNotesController.text.trim(),
        itemsToReturn: [
          (
            returnedSerialID: widget.serialNumberToReturn,
            prodDefID:
                serialDetails.prodDefID, // Get prodDefID from the serial item
            itemReason: fullReason // Or specific reason for this item
          )
        ],
      );

      ToastManager().showToast(
          context, "Return Order created successfully!", Colors.green);
      // ref.invalidate(returnOrderListNotifierProvider); // You'll create this
      Navigator.of(context).pop(true); // Indicate success
    } catch (e) {
      print("Error submitting RO: $e");
      ToastManager().showToast(context,
          "Failed to create Return Order: ${e.toString()}", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = screenWidth > 600 ? 550 : screenWidth * 0.9;
    final poDetailsAsync =
        ref.watch(poDetailsProviderFamily(widget.purchaseOrderId));
    final supplierNamesMapAsync = ref.watch(supplierNameMapProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: modalWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent, // Color for return/warning
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Return Item: ${widget.productName} (SN: ${widget.serialNumberToReturn})',
                        style: const TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: "Close",
                    )
                  ],
                ),
              ),
              Flexible(
                // Makes the content scrollable if it overflows
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      poDetailsAsync.when(
                        data: (po) {
                          if (po == null)
                            return const Text("Error: PO details not found.");
                          return supplierNamesMapAsync.when(
                            data: (map) => _buildReadOnlyField("Supplier:",
                                map[po.supplierID] ?? "ID: ${po.supplierID}"),
                            loading: () =>
                                _buildReadOnlyField("Supplier:", "Loading..."),
                            error: (e, s) =>
                                _buildReadOnlyField("Supplier:", "Error"),
                          );
                        },
                        loading: () =>
                            _buildReadOnlyField("Supplier:", "Loading PO..."),
                        error: (e, s) => _buildReadOnlyField(
                            "Supplier:", "Error loading PO"),
                      ),
                      _buildReadOnlyField(
                          "Original PO ID:", widget.purchaseOrderId.toString()),
                      const SizedBox(height: 16),
                      _buildDatePickerField(context, "Return Date *"),
                      const SizedBox(height: 16),
                      _buildDropdownField(
                        label: "Reason for Return *",
                        hintText: "Select reason...",
                        value: _selectedReturnReason,
                        items: _returnReasons,
                        onChanged: (val) =>
                            setState(() => _selectedReturnReason = val),
                        validator: (val) =>
                            val == null ? "Reason is required" : null,
                      ),
                      if (_selectedReturnReason ==
                          "Other (Specify in notes)") ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: "Specify Other Reason *",
                          hintText: "Details for 'Other' reason",
                          controller: _returnReasonController,
                          maxLines: 2,
                          isRequired: true,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Overall Return Notes (Optional)",
                        hintText:
                            "Any additional notes for this return order...",
                        controller: _overallNotesController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: _isSubmitting
                          ? Container()
                          : const Icon(Icons.send_outlined, size: 18),
                      label: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Submit Return Request'),
                      onPressed: _isSubmitting ? null : _submitReturnRequest,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'NunitoSans',
                  fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style:
                      const TextStyle(fontFamily: 'NunitoSans', fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label,
              style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
          const Text(' *', style: TextStyle(color: Colors.red))
        ]),
        const SizedBox(height: 4),
        TextFormField(
          controller: TextEditingController(
              text: DateFormat('MM/dd/yyyy').format(_returnDate)),
          readOnly: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today, size: 18),
              onPressed: () => _selectReturnDate(context),
            ),
          ),
          validator: (v) => _returnDate == null ? '$label is required' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        )
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hintText,
      required TextEditingController controller,
      int maxLines = 1,
      bool isRequired = false,
      String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label,
            style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
        if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 4),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 11)),
        validator: validator ??
            (v) => (isRequired && (v == null || v.trim().isEmpty))
                ? '$label is required'
                : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ]);
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label,
            style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
        if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 4),
      DropdownButtonFormField<String>(
        value: value,
        hint: Text(hintText,
            style: const TextStyle(
                fontSize: 11, color: Colors.grey, fontFamily: 'Poppins')),
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0)),
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item,
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'NunitoSans'))))
            .toList(),
        onChanged: onChanged,
        validator: validator ??
            (v) => (isRequired && v == null) ? '$label is required' : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ]);
  }
}

// Helper extension in case PurchaseOrderService does not yet have ReturnOrderService instance
extension PurchaseOrderServiceReturnExtension on PurchaseOrderService {
  ReturnOrderService get returnOrderService => ReturnOrderService();
}
