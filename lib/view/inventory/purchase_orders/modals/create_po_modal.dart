// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

// Base imports
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_user.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_attendance.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

// API Shizz
import 'package:jcsd_flutter/api/global_variables.dart'; // For supabaseDB.auth.currentUser

// Backend Imports
//Employees
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart'; // To get current employee ID if needed (or pass it)

//Product Definitions
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';

//Purchase Order
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart'; // For productDefinitionNotifierProvider(true)

//Suppliers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // For activeSuppliersForDropdownProvider

// State Management Variables

// Managing the line items within the modal
final _poLineItemsProvider =
    StateProvider.autoDispose<List<PurchaseOrderItemData>>((ref) => []);
// Selected supplier in the modal
final _selectedSupplierIdProvider =
    StateProvider.autoDispose<int?>((ref) => null);
// State for selected order date
final _selectedOrderDateProvider =
    StateProvider.autoDispose<DateTime>((ref) => DateTime.now());
// State for selected expected delivery date
final _selectedExpectedDeliveryDateProvider =
    StateProvider.autoDispose<DateTime?>((ref) => null);

// Global Variables (I don't want to create a provider or what, diretsoay nalang ni)
String? currentEmployeeName;
int? currentEmployeeID;

//Grabbing the Employee's Name based on the given UUID
Future<void> fetchEmployeeName(String empUUID) async {
  try {
    final fetchUserDetails = await supabaseDB
        .from('accounts')
        .select()
        .eq('userID', empUUID)
        .single();

    currentEmployeeName =
        '${fetchUserDetails['firstName']} ${fetchUserDetails['lastName']}';
  } catch (err, sty) {
    print('Failed to fetch Account details, kindly relogin \n $err');
    currentEmployeeName = null;
    rethrow;
  }
}

Future<int?> fetchEmployeeIDviaUUID(String empUUID) async {
  try {
    final fetchUserDetails = await supabaseDB
        .from('employee')
        .select('employeeID')
        .eq('userID', empUUID)
        .single();
    return fetchUserDetails['employeeID'] as int?;
  } catch (err) {
    print('Failed to fetch Account details, kindly relogin \n $err');
    currentEmployeeID = null;
    rethrow;
  }
}

class CreatePurchaseOrderModal extends ConsumerStatefulWidget {
  const CreatePurchaseOrderModal({super.key});

  @override
  ConsumerState<CreatePurchaseOrderModal> createState() =>
      _CreatePurchaseOrderModalState();
}

class _CreatePurchaseOrderModalState
    extends ConsumerState<CreatePurchaseOrderModal> {
  final _formKey = GlobalKey<FormState>();
  final _poNotesController = TextEditingController();
  bool _isSaving = false;

  ProductDefinitionData? _selectedProductForNewLine;
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final GlobalKey<FormState> _lineItemFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_poLineItemsProvider.notifier).state = [];
      ref.read(_selectedSupplierIdProvider.notifier).state = null;
      ref.read(_selectedOrderDateProvider.notifier).state = DateTime.now();
      ref.read(_selectedExpectedDeliveryDateProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _poNotesController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, StateController<DateTime?> dateController,
      {bool isOrderDate = false}) async {
    final DateTime initial = dateController.state ?? DateTime.now();
    final DateTime first =
        isOrderDate ? DateTime(2000) : ref.read(_selectedOrderDateProvider);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateController.state = picked;
    }
  }

  void _addLineItem() {
    if (!_lineItemFormKey.currentState!.validate()) {
      ToastManager().showToast(
          context, 'Please correct item details before adding.', Colors.orange);
      return;
    }

    //Values parsed to static variables for submission here
    final quantity = int.parse(_quantityController.text);
    final unitCost = double.parse(_unitCostController.text);

    final newItem = PurchaseOrderItemData(
      purchaseOrderID:
          0, //Temp Value, but will actually be populated by the service/DB (for the sake lang na mapasa, since a required var)
      prodDefID: _selectedProductForNewLine!.prodDefID!,
      quantityOrdered: quantity,
      unitCostPrice: unitCost,
      lineTotalCost: quantity * unitCost,
    );

    ref
        .read(_poLineItemsProvider.notifier)
        .update((state) => [...state, newItem]);

    setState(() {
      _selectedProductForNewLine = null;
      _quantityController.clear();
      _unitCostController.clear();
      _lineItemFormKey.currentState
          ?.reset(); //Cleaning the validation errors, kay every after input (prior to applying globalkey), it reads as empty input
    });
  }

  void _removeLineItem(int index) {
    ref.read(_poLineItemsProvider.notifier).update((state) {
      final newList = List<PurchaseOrderItemData>.from(state);
      newList.removeAt(index);
      return newList;
    });
  }

  Future<void> _submitPO() async {
    if (!_formKey.currentState!.validate()) {
      ToastManager().showToast(
          context, 'Please correct errors in the form.', Colors.orange);
      return;
    }
    final selectedSupplierId = ref.read(_selectedSupplierIdProvider);
    final lineItems = ref.read(_poLineItemsProvider);

    if (selectedSupplierId == null) {
      ToastManager()
          .showToast(context, 'Please select a supplier.', Colors.orange);
      return;
    }
    if (lineItems.isEmpty) {
      ToastManager().showToast(context,
          'Please add at least one item to the purchase order.', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final String currentAuthID = supabaseDB.auth.currentUser!.id;
      final int? fetchedEmployeeID =
          await fetchEmployeeIDviaUUID(currentAuthID);

      fetchEmployeeIDviaUUID(currentAuthID); //Null safety was implemented

      if (fetchedEmployeeID == null) {
        ToastManager().showToast(
            context,
            'Error: Could not retrieve employee details. Please try again.',
            Colors.red);
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      await ref
          .read(purchaseOrderListNotifierProvider.notifier)
          .createNewPurchaseOrder(
            supplierID: selectedSupplierId,
            createdByEmployee: fetchedEmployeeID,
            orderDate: ref.read(_selectedOrderDateProvider),
            expectedDeliveryDate:
                ref.read(_selectedExpectedDeliveryDateProvider),
            note: _poNotesController.text.trim().isEmpty
                ? null
                : _poNotesController.text.trim(),
            items: lineItems,
          );
      ToastManager().showToast(
          context, 'Purchase Order created successfully!', Colors.green);
      Navigator.of(context).pop(true);
    } catch (e, sty) {
      print('Error creating PO: $e \n $sty');
      ToastManager().showToast(
          context, 'Failed to create PO: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = screenWidth > 800 ? 750 : screenWidth * 0.9;
    final lineItems = ref.watch(_poLineItemsProvider);
    final selectedOrderDate = ref.watch(_selectedOrderDateProvider);
    final selectedExpectedDeliveryDate =
        ref.watch(_selectedExpectedDeliveryDateProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: modalWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: const BoxDecoration(
                    color: Color(0xFF00AEEF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10))),
                child: const Center(
                    child: Text('Create New Purchase Order',
                        style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white))),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSupplierDropdown(ref)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePickerField(
                              context,
                              label: 'Order Date *',
                              selectedDate: selectedOrderDate,
                              dateController:
                                  ref.read(_selectedOrderDateProvider.notifier),
                              isOrderDate: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePickerField(
                              context,
                              label: 'Expected Delivery Date',
                              selectedDate: selectedExpectedDeliveryDate,
                              dateController: ref.read(
                                  _selectedExpectedDeliveryDateProvider
                                      .notifier),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                          label: "Notes for PO",
                          hintText: "Enter any notes for this PO...",
                          controller: _poNotesController,
                          maxLines: 2,
                          isRequired: false),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text("Add Items to Purchase Order",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'NunitoSans')),
                      const SizedBox(height: 10),
                      _buildAddLineItemForm(ref),
                      const SizedBox(height: 16),
                      _buildLineItemsList(lineItems),
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
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel')),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: _isSaving
                          ? Container()
                          : const Icon(Icons.save, size: 18),
                      label: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Create Purchase Order'),
                      onPressed: _isSaving ? null : _submitPO,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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

  Widget _buildTextField(
      {required String label,
      required String hintText,
      required TextEditingController controller,
      int maxLines = 1,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
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
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
            (v) =>
                (v == null || v.trim().isEmpty) ? '$label is required' : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ]);
  }

  Widget _buildSupplierDropdown(WidgetRef ref) {
    final suppliersAsync = ref.watch(activeSuppliersForDropdownProvider);
    final selectedSupplierId = ref.watch(_selectedSupplierIdProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Text('Supplier',
            style: TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
        Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 4),
      suppliersAsync.when(
        data: (suppliers) => DropdownButtonFormField<int?>(
          value: selectedSupplierId,
          hint: const Text('Select supplier...',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0)),
          isExpanded: true,
          items: suppliers
              .map((sup) => DropdownMenuItem<int>(
                  value: sup.supplierID,
                  child: Text(sup.supplierName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontFamily: 'NunitoSans'))))
              .toList(),
          onChanged: (v) =>
              ref.read(_selectedSupplierIdProvider.notifier).state = v,
          validator: (v) => v == null ? 'Supplier is required' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        loading: () => const Center(
            child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))),
        error: (err, _) => Text('Error: $err',
            style: const TextStyle(color: Colors.red, fontSize: 11)),
      ),
    ]);
  }

  Widget _buildDatePickerField(BuildContext context,
      {required String label,
      required DateTime? selectedDate,
      required StateController<DateTime?> dateController,
      bool isOrderDate = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label,
            style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 13)),
        if (isOrderDate) const Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 4),
      TextFormField(
        controller: TextEditingController(
            text: selectedDate != null
                ? DateFormat('MM/dd/yyyy').format(selectedDate)
                : ''),
        readOnly: true,
        decoration: InputDecoration(
            hintText: 'Select Date',
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 11),
            suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today, size: 18),
                onPressed: () => _selectDate(context, dateController,
                    isOrderDate: isOrderDate))),
        validator: (v) =>
            (isOrderDate && selectedDate == null) ? '$label is required' : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      )
    ]);
  }

  Widget _buildAddLineItemForm(WidgetRef ref) {
    final productsAsync = ref.watch(productDefinitionNotifierProvider(true));

    return Form(
      key: _lineItemFormKey, // Watches the current line item state - iwas bug
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            productsAsync.when(
              data: (productState) {
                if (productState.productDefinitions.isEmpty) {
                  return const Text("No products available to add.",
                      style: TextStyle(fontFamily: 'NunitoSans'));
                }
                return DropdownButtonFormField<ProductDefinitionData?>(
                  value: _selectedProductForNewLine,
                  hint: const Text('Select Product...',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: 'Poppins')),
                  decoration: const InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      labelStyle:
                          TextStyle(fontSize: 13, fontFamily: 'NunitoSans')),
                  isExpanded: true,
                  items: productState.productDefinitions
                      .map((pd) => DropdownMenuItem<ProductDefinitionData>(
                            value: pd,
                            child: Text(pd.prodDefName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, fontFamily: 'NunitoSans')),
                          ))
                      .toList(),
                  onChanged: (pd) => setState(() {
                    _selectedProductForNewLine = pd;
                    if (pd?.prodDefMSRP != null) {
                      _unitCostController.text =
                          pd!.prodDefMSRP!.toStringAsFixed(2);
                    } else {
                      _unitCostController.clear();
                    }
                  }),
                  validator: (pd) => pd == null ? 'Product is required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                );
              },
              loading: () => const Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, s) => Text('Error loading products: $e',
                  style: const TextStyle(color: Colors.red, fontSize: 11)),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _buildTextField(
                        label: 'Quantity Ordered',
                        hintText: 'Qty',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        isRequired: true,
                        validator: (v) {
                          final value = v?.trim();
                          if (value == null || value.isEmpty) {
                            return 'Qty is required';
                          }
                          final qty = int.tryParse(value);
                          if (qty == null) return 'Invalid number';
                          if (qty <= 0) return 'Qty must be > 0';
                          return null;
                        })),
                const SizedBox(width: 10),
                Expanded(
                    child: _buildTextField(
                        label: 'Unit Cost Price (PHP)',
                        hintText: 'Cost',
                        controller: _unitCostController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'))
                        ],
                        isRequired: true,
                        validator: (v) {
                          final value = v?.trim(); // Trim whitespace
                          if (value == null || value.isEmpty) {
                            return 'Cost is required';
                          }
                          final cost = double.tryParse(value);
                          if (cost == null) return 'Invalid number';
                          if (cost < 0) return 'Cost must be >= 0';
                          return null;
                        })),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item to PO',
                    style: TextStyle(fontSize: 12, fontFamily: 'NunitoSans')),
                onPressed: _addLineItem,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsList(List<PurchaseOrderItemData> items) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
            child: Text('No items added to this PO yet.',
                style:
                    TextStyle(color: Colors.grey, fontFamily: 'NunitoSans'))),
      );
    }
    // Fetch product names for display
    final productDefinitionsState =
        ref.watch(productDefinitionNotifierProvider(true)).asData?.value;
    final productNameMap = productDefinitionsState?.productDefinitions
            .fold<Map<String?, String>>(
                {}, (map, pd) => map..[pd.prodDefID] = pd.prodDefName) ??
        {};

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final productName = productNameMap[item.prodDefID] ??
            'Product ID: ${item.prodDefID.substring(0, 6)}...';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 1,
          child: ListTile(
            dense: true,
            title: Text('$productName (${item.quantityOrdered} units)',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'NunitoSans')),
            subtitle: Text(
                'Unit Cost: ₱${item.unitCostPrice.toStringAsFixed(2)}  |  Line Total: ₱${item.lineTotalCost.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 11, fontFamily: 'NunitoSans')),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _removeLineItem(index),
              tooltip: 'Remove Item',
            ),
          ),
        );
      },
    );
  }
}
