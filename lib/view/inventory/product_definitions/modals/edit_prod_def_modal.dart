import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';

//Populating the drop-downs
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_providers.dart';

//Front-End/User Feedback
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

/// Modal dialog for editing an existing product definition.
class EditProductDefinitionModal extends ConsumerStatefulWidget {
  final ProductDefinitionData
      productDefinition; // Pass the existing data to edit
  final bool
      isVisibleContext; // Context from which it was called (true = active list)

  const EditProductDefinitionModal({
    super.key,
    required this.productDefinition,
    this.isVisibleContext = true,
  });

  @override
  ConsumerState<EditProductDefinitionModal> createState() =>
      _EditProductDefinitionModalState();
}

class _EditProductDefinitionModalState
    extends ConsumerState<EditProductDefinitionModal> {
  //Initial state for both validation and saving state

  final formKey = GlobalKey<FormState>();
  bool isSaving = false;

  // Text editing controllers
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _msrpController = TextEditingController();
  late TextEditingController _desiredStockLevelContoller =
      TextEditingController();

  // Dropdown selections
  int? selectedItemTypeID;
  String? selectedManufacturerName; // Store name based on new schema
  int? selectedSupplierID;

  @override
  void initState() {
    super.initState();
    final pd = widget.productDefinition;
    _nameController = TextEditingController(text: pd.prodDefName);
    _descriptionController =
        TextEditingController(text: pd.prodDefDescription ?? '');
    _msrpController =
        TextEditingController(text: pd.prodDefMSRP?.toStringAsFixed(2) ?? '');
    _desiredStockLevelContoller =
        TextEditingController(text: pd.desiredStockLevel?.toString() ?? '');
    selectedItemTypeID = pd.itemTypeID;
    selectedManufacturerName = pd.manufacturerName;
    selectedSupplierID = pd.preferredSupplierID;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _msrpController.dispose();
    _desiredStockLevelContoller.dispose();
    super.dispose();
  }

  /// EDIT PD: Form submission method
  Future<void> _submitForm() async {
    //Form Validation - ensures na naay sulod!
    if (!formKey.currentState!.validate()) {
      ToastManager().showToast(
          context, 'Please fix the errors in the form.', Colors.orange);
      return;
    }

    setState(() => isSaving = true);

    final updatedProdDef = widget.productDefinition.copyWith(
      prodDefName: _nameController.text.trim(),
      prodDefDescription: _descriptionController.text.trim(),
      manufacturerName: selectedManufacturerName,
      itemTypeID: selectedItemTypeID,
      prodDefMSRP: double.tryParse(_msrpController.text.trim()) ??
          widget.productDefinition.prodDefMSRP, // Update price safely
      desiredStockLevel: int.tryParse(_desiredStockLevelContoller.text.trim()),
      preferredSupplierID: selectedSupplierID,
    );

    try {
      await ref
          .read(productDefinitionNotifierProvider(widget.isVisibleContext)
              .notifier)
          .updateProductDefinition(updatedProdDef);

      ToastManager().showToast(
          context, 'Product Definition updated successfully!', Colors.green);
      Navigator.pop(context);
    } catch (e, st) {
      print("Error updating Product Definition: $e\n$st");
      ToastManager().showToast(context,
          'Failed to update Product Definition: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
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
          key: formKey,
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
                child: const Center(
                  child: Text('Edit Product Definition',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
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
                            _buildTextField(
                              label: 'Product Name',
                              hintText: 'e.g., GeForce RTX 4090 OC',
                              controller: _nameController,
                              isRequired: true,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                              label: 'Product Description',
                              hintText: 'Enter detailed description...',
                              controller: _descriptionController,
                              maxLines: 4,
                              isRequired: true,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                                label: 'Desired Stock Level',
                                hintText: 'Enter desired quantity..',
                                controller: _desiredStockLevelContoller,
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Desired Stock Level is required';
                                  }
                                  final stock = int.tryParse(value.trim());
                                  if (stock == null || stock < 1) {
                                    return 'Must be a number greater than or equal to 1';
                                  }
                                  return null;
                                }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildItemTypeDropdown(ref),
                            const SizedBox(height: 15),
                            _buildManufacturerDropdown(ref),
                            const SizedBox(height: 15),
                            _buildSupplierDropdown(ref),
                            const SizedBox(height: 15),
                            _buildTextField(
                                label: 'MSRP (PHP)',
                                hintText: 'Enter suggested retail price',
                                controller: _msrpController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}'))
                                ],
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'MSRP is required';
                                  }
                                  final price = double.tryParse(value);
                                  if (price == null || price < 0) {
                                    return 'Invalid positive price';
                                  }
                                  return null;
                                }),
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
                            isSaving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Color(0xFF00AEEF))),
                        ),
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
                        icon: isSaving
                            ? Container()
                            : const Icon(Icons.save, size: 18),
                        label: isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes'),
                        onPressed: isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF00AEEF), // Consistent color
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

  //Builder Widgets
  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            )
        ]),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 12),
          ),
          validator: validator ??
              (value) {
                if (isRequired && (value == null || value.trim().isEmpty)) {
                  return '$label is required';
                }
                return null;
              },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  //ItemType Dropdown
  Widget _buildItemTypeDropdown(WidgetRef ref) {
    final itemTypesAsync = ref.watch(fetchActiveTypes); // Fetch active types

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text('Item Type'),
          Text(' *', style: TextStyle(color: Colors.red))
        ]),
        const SizedBox(height: 5),
        itemTypesAsync.when(
          data: (types) => DropdownButtonFormField<int>(
            value: selectedItemTypeID, // Set initial value
            hint: const Text('Select type...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: types
                .map((type) => DropdownMenuItem<int>(
                      value: type.itemTypeID,
                      child: Text(type.itemType,
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => selectedItemTypeID = value), // Update state
            validator: (value) =>
                value == null ? 'Item Type is required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          loading: () => const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))),
          error: (err, stack) => Text('Error loading types: $err',
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    );
  }

  //Manufacturers Dropdown
  Widget _buildManufacturerDropdown(WidgetRef ref) {
    final manufacturersAsync = ref.watch(
        allManufacturersForEditDropdownProvider); // Fetch active manufacturers

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text('Manufacturer'),
          Text(' *', style: TextStyle(color: Colors.red))
        ]),
        const SizedBox(height: 5),
        manufacturersAsync.when(
          data: (manufacturers) => DropdownButtonFormField<String>(
            value: selectedManufacturerName, // Set initial name value
            hint: const Text('Select manufacturer...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: manufacturers
                .map((mfg) => DropdownMenuItem<String>(
                      value: mfg.manufacturerName, // Value is the name
                      child: Text(mfg.manufacturerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (value) => setState(() =>
                selectedManufacturerName = value), // Update state with name
            validator: (value) =>
                value == null ? 'Manufacturer is required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          loading: () => const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))),
          error: (err, stack) => Text('Error loading manufacturers: $err',
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildSupplierDropdown(WidgetRef ref) {
    final suppliersAsync = ref.watch(activeSuppliersForDropdownProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text('Preferred Supplier'),
          Text(' *', style: TextStyle(color: Colors.red))
        ]),
        const SizedBox(height: 5),
        suppliersAsync.when(
          data: (suppliers) => DropdownButtonFormField<int>(
            value: selectedSupplierID,
            hint: const Text('Select supplier (optional)...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: suppliers
                .map((supplier) => DropdownMenuItem<int>(
                      value: supplier.supplierID,
                      child: Text(supplier.supplierName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => selectedSupplierID = value),
            validator: (value) {
              if (value == null) return 'Preferred Supplier is required';
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          loading: () => const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))),
          error: (err, stack) => Text('Error loading suppliers: $err',
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    );
  }
}
