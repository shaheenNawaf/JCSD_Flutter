// lib/view/inventory/modals/edit_serialized_item_modal.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

//Item Serials Import
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';

//Populating the Suppliers Dropdown
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';

//User Feedback
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class EditSerializedItemModal extends ConsumerStatefulWidget {
  final SerializedItem item; // Pass the item to edit

  const EditSerializedItemModal({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<EditSerializedItemModal> createState() =>
      _EditSerializedItemModalState();
}

class _EditSerializedItemModalState
    extends ConsumerState<EditSerializedItemModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers initialized in initState
  late TextEditingController _serialNumberController;
  late TextEditingController _costPriceController;
  late TextEditingController _notesController;
  late TextEditingController _purchaseDateController;

  // Selections initialized in initState
  int? _selectedSupplierId;
  String? _selectedStatus;
  DateTime? _selectedPurchaseDate;

  @override
  void initState() {
    super.initState();
    // Initialize with existing item data
    final item = widget.item;
    _serialNumberController = TextEditingController(text: item.serialNumber);
    _costPriceController =
        TextEditingController(text: item.costPrice!.toStringAsFixed(2));
    _notesController = TextEditingController(text: item.notes ?? '');
    _selectedSupplierId = item.supplierID;
    _selectedStatus = item.status;
    _selectedPurchaseDate = item.purchaseDate;
    _purchaseDateController = TextEditingController(
        text: item.purchaseDate != null
            ? DateFormat('yyyy-MM-dd').format(item.purchaseDate!)
            : '');
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _costPriceController.dispose();
    _notesController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  // Shows Date Picker
  Future<void> _selectPurchaseDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedPurchaseDate) {
      setState(() {
        _selectedPurchaseDate = picked;
        _purchaseDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Handles form submission for update
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ToastManager().showToast(
          context, 'Please fix the errors in the form.', Colors.orange);
      return;
    }
    setState(() => _isSaving = true);

    // Create updated object using copyWith
    final updatedItem = widget.item.copyWith(
      // serialNumber cannot be changed
      supplierID: _selectedSupplierId, // Updated
      costPrice: double.tryParse(_costPriceController.text.trim()) ??
          widget.item.costPrice, // Updated
      status: _selectedStatus, // Updated
      notes: _notesController.text.trim(), // Updated
      purchaseDate: _selectedPurchaseDate, // Updated
    );

    try {
      // Call notifier for the item's product definition
      await ref
          .read(serializedItemNotifierProvider(widget.item.prodDefID).notifier)
          .updateSerializedItem(updatedItem);
      ToastManager().showToast(
          context, 'Serial item updated successfully!', Colors.green);
      Navigator.pop(context);
    } catch (e, st) {
      print("Error updating Serialized Item: $e\n$st");
      ToastManager().showToast(
          context, 'Failed to update serial item: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 700 ? 650 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: containerWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    'Edit Serial: ${widget.item.serialNumber}',
                    style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Serial Number (Read Only)
                            _buildTextField(
                                label: 'Serial Number',
                                hintText: '',
                                controller: _serialNumberController,
                                isRequired: true,
                                readOnly: true),
                            const SizedBox(height: 15),
                            _buildSupplierDropdown(ref),
                            const SizedBox(height: 15),
                            _buildTextField(
                                label: 'Cost Price (PHP)',
                                hintText: 'Enter purchase cost',
                                controller: _costPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'))
                                ],
                                isRequired: true,
                                validator: (v) => (v == null ||
                                        v.isEmpty ||
                                        (double.tryParse(v) ?? -1) < 0)
                                    ? 'Valid cost required'
                                    : null),
                            const SizedBox(height: 15),
                            _buildStatusDropdown(ref),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPurchaseDateField(context),
                            const SizedBox(height: 15),
                            _buildTextField(
                                label: 'Notes',
                                hintText: 'Enter any relevant notes...',
                                controller: _notesController,
                                maxLines: 4,
                                isRequired: false),
                          ],
                        ),
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
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color(0xFF00AEEF)))),
                        child: const Text('Cancel',
                            style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AEEF))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _isSaving
                            ? Container()
                            : const Icon(Icons.save, size: 18),
                        label: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes'),
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AEEF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            textStyle: const TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold)),
                      ),
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

  // Builds a reusable TextFormField
  Widget _buildTextField(
      {required String label,
      required String hintText,
      required TextEditingController controller,
      int maxLines = 1,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      bool isRequired = false,
      String? Function(String?)? validator,
      Widget? suffixIcon,
      bool readOnly = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label),
        if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 12),
            suffixIcon: suffixIcon),
        validator: validator ??
            (v) => (isRequired && (v == null || v.trim().isEmpty))
                ? '$label is required'
                : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ]);
  }

  // Builds the dropdown for Suppliers
  Widget _buildSupplierDropdown(WidgetRef ref) {
    final suppliersAsync = ref.watch(activeSuppliersForDropdownProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Text('Supplier'),
        Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 5),
      suppliersAsync.when(
        data: (suppliers) {
          final isValidSelection = _selectedSupplierId != null &&
              suppliers.any((s) => s.supplierID == _selectedSupplierId);
          final currentValue = isValidSelection ? _selectedSupplierId : null;
          return DropdownButtonFormField<int>(
            value: currentValue,
            hint: const Text('Select supplier...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: suppliers
                .map((sup) => DropdownMenuItem<int>(
                    value: sup.supplierID,
                    child: Text(sup.supplierName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (v) => setState(() => _selectedSupplierId = v),
            validator: (v) => v == null ? 'Supplier is required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          );
        },
        loading: () => const Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))),
        error: (err, _) => Text('Error: $err',
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      ),
    ]);
  }

  // Builds the dropdown for Item Status
  Widget _buildStatusDropdown(WidgetRef ref) {
    final statusesAsync = ref.watch(allItemStatusesProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Text('Status'),
        Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 5),
      statusesAsync.when(
        data: (statuses) {
          final isValidSelection =
              _selectedStatus != null && statuses.contains(_selectedStatus);
          final currentValue = isValidSelection ? _selectedStatus : null;
          return DropdownButtonFormField<String>(
            value: currentValue,
            hint: const Text('Select status...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: statuses
                .map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (v) => setState(() => _selectedStatus = v),
            validator: (v) => v == null ? 'Status is required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          );
        },
        loading: () => const Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))),
        error: (err, _) => Text('Error: $err',
            style: const TextStyle(color: Colors.red, fontSize: 12)),
      ),
    ]);
  }

  // Builds the Purchase Date field with DatePicker
  Widget _buildPurchaseDateField(BuildContext context) {
    return _buildTextField(
      label: 'Purchase Date',
      hintText: 'Select date',
      controller: _purchaseDateController,
      isRequired: false, // Or true if needed
      readOnly: true,
      suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today, size: 18),
        onPressed: () => _selectPurchaseDate(context),
      ),
      validator: (v) =>
          (_selectedPurchaseDate == null && false /* set to true if required */)
              ? 'Purchase Date is required'
              : null,
    );
  }
}
