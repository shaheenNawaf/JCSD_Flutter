//Base Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports and Other related functionalities
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_providers.dart';

//Front-End -- Improved User Feedback
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class AddProdDefModal extends ConsumerStatefulWidget {
  final bool isVisible;
  const AddProdDefModal({super.key, this.isVisible = true});

  @override
  ConsumerState<AddProdDefModal> createState() => _AddProdDefModalState();
}

class _AddProdDefModalState extends ConsumerState<AddProdDefModal> {
  //Initial state for both validation and saving state
  final formKey = GlobalKey<FormState>();
  bool isSaving = false;

  //Controllers for the forms
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _msrpController = TextEditingController();
  final TextEditingController _desiredStockLevel = TextEditingController();

  //For the dropdowns
  int? selectedItemTypeID;
  String? selectedManufacturerName;
  int? selectedSupplierID;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _msrpController.dispose();
    _desiredStockLevel.dispose();
    super.dispose();
  }

  /// NEW PD: Form submission method
  Future<void> submitForm() async {
    //Form Validation - ensures na naay sulod!
    if (!formKey.currentState!.validate()) {
      ToastManager()
          .showToast(context, 'Please fix errors in the form', Colors.orange);
      return;
    }

    //Indicates processing
    setState(() => isSaving = true);

    final newProdDef = ProductDefinitionData(
      prodDefName: _nameController.text.trim(),
      prodDefDescription: _descriptionController.text.trim(),
      manufacturerName: selectedManufacturerName!,
      prodDefMSRP: double.tryParse(_msrpController.text.trim()) ?? 0.0,
      isVisible: true,
      itemTypeID: selectedItemTypeID!,
      desiredStockLevel: int.tryParse(_desiredStockLevel.text.trim()),
      preferredSupplierID: selectedSupplierID,
    );

    //Actual Supabase DB Call
    try {
      await ref
          .read(productDefinitionNotifierProvider(widget.isVisible).notifier)
          .addProductDefinition(newProdDef);

      print('Trying to add a new Product Definition');
      await Future.delayed(const Duration(seconds: 1));

      ToastManager().showToast(
          context, 'Product Definition added successfully!', Colors.green);
      Navigator.pop(context);
    } catch (err, st) {
      print("Error adding Product Definition: $err\n$st");
      ToastManager().showToast(context,
          'Failed to add Product Definition: ${err.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => isSaving = false); // Hide loading indicator
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth =
        screenWidth > 700 ? 650 : screenWidth * 0.9; // Dynamic width

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
                  child: Text('Add New Product Definition',
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                ),
              ),
              // Form Fields
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
                              maxLines: 5,
                              isRequired: true,
                            ),
                            const SizedBox(height: 19),
                            _buildTextField(
                              label: 'Desired Stock Level',
                              hintText: 'Enter desired quantity',
                              controller: _desiredStockLevel,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              isRequired: true,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final stock = int.tryParse(value);
                                  if (stock == null || stock < 1) {
                                    return 'Must be a positive number and more than zero';
                                  }
                                  return null;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right Column
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildItemTypeDropdown(ref), // Item Type dropdown
                            const SizedBox(height: 15),
                            _buildManufacturerDropdown(
                                ref), // Manufacturer dropdown
                            const SizedBox(height: 15),
                            _buildSupplierDropdown(ref),
                            const SizedBox(height: 15),
                            _buildTextField(
                                // Reusable text field widget
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
                                  // Price validation
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
                        onPressed: isSaving
                            ? null
                            : () => Navigator.pop(context), // Disable if saving
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
                            : const Icon(Icons.add_circle_outline,
                                size: 18), // Show icon only when not saving
                        label: isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Add Product'),
                        onPressed: isSaving ? null : submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.bold),
                        ),
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
          if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))
        ]), // Label with optional required marker
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
                return null; // Return null if valid
              },
          autovalidateMode:
              AutovalidateMode.onUserInteraction, // Validate as user types
        ),
      ],
    );
  }

  //ItemType Dropdown
  Widget _buildItemTypeDropdown(WidgetRef ref) {
    // Provider for fetching active itemTypes
    final itemTypesAsync = ref.watch(fetchActiveTypes);

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
            value: selectedItemTypeID, // Currently selected value
            hint: const Text('Select type...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: types
                .map((type) => DropdownMenuItem<int>(
                      // Create dropdown items from fetched data
                      value: type.itemTypeID,
                      child: Text(type.itemType,
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (value) => setState(
                () => selectedItemTypeID = value), // Update state on selection
            validator: (value) =>
                value == null ? 'Item Type is required' : null, // Validation
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

  Widget _buildManufacturerDropdown(WidgetRef ref) {
    // Provider for fetching the active manufacturers
    final manufacturersAsync =
        ref.watch(activeManufacturersForDropdownProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Text('Manufacturer'),
          Text(' *', style: TextStyle(color: Colors.red))
        ]),
        const SizedBox(height: 5),
        manufacturersAsync.when(
          // Handle loading/error/data states
          data: (manufacturers) => DropdownButtonFormField<String>(
            value: selectedManufacturerName, // Currently selected name
            hint: const Text('Select manufacturer...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
            isExpanded: true,
            items: manufacturers
                .map((mfg) => DropdownMenuItem<String>(
                      value: mfg.manufacturerName, // Value is the name string
                      child: Text(mfg.manufacturerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => selectedManufacturerName = value),
            validator: (value) =>
                value == null ? 'Manufacturer is required' : null, // Validation
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
            // Value is int (supplierID)
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
                      value: supplier.supplierID, // Store supplierID
                      child: Text(supplier.supplierName, // Display supplierName
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
