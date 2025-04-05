// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import refactored providers and data/state models
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // Assuming this exists

class EditItemModal extends ConsumerStatefulWidget {
  final InventoryData item;

  const EditItemModal({super.key, required this.item});

  @override
  ConsumerState<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends ConsumerState<EditItemModal> {
  bool _isSaving = false; // For button loading state

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // All controllers, needed to insert data from the selected item
  late TextEditingController _itemName;
  late TextEditingController _itemDescription;
  late TextEditingController _itemPrice;

  // Selected IDs for dropdowns - Initialized in initState
  int? _selectedItemTypeId;
  int? _selectedSupplierId;

  //Initialize everything
  @override
  void initState() {
    super.initState();
    _itemName = TextEditingController(text: widget.item.itemName);
    _itemDescription = TextEditingController(text: widget.item.itemDescription);
    _itemPrice = TextEditingController(text: widget.item.itemPrice.toStringAsFixed(2));
    _selectedItemTypeId = widget.item.itemTypeID;
    _selectedSupplierId = widget.item.supplierID;
  }

  @override
  void dispose() {
    _itemName.dispose();
    _itemDescription.dispose();
    _itemPrice.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Validate Form using GlobalKey
    if (!_formKey.currentState!.validate()) {
      //Pwede rin ito or a notification, not a big deal -- michael

       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please fix the errors in the form.'), backgroundColor: Colors.orange),
       );
      return;
    }

    // Price validated by TextFormField, safely parse
    final double price = double.parse(_itemPrice.text);

    setState(() => _isSaving = true);

    // Create Updated InventoryData object using widget.item.copyWith
    final updatedItem = widget.item.copyWith(
      itemName: _itemName.text.trim(),
      itemDescription: _itemDescription.text.trim(),
      itemPrice: price,
      itemTypeID: _selectedItemTypeId!,
      supplierID: _selectedSupplierId!,
    );

    // Call the updateItem method on the appropriate notifier instance
    try {
      const bool isVisibleContext = true; // Assuming editing from active list
      await ref.read(InventoryNotifierProvider(isVisibleContext).notifier).updateItemDetails(updatedItem);

      Navigator.pop(context); // Close on success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully!'), backgroundColor: Colors.green),
      );

    } catch (e) {
      print("Error updating item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      // Reset saving state only if the widget is still in the tree
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: containerWidth,
        child: Form(
           key: _formKey,
           child: Column(
             mainAxisSize: MainAxisSize.min, // Fit content vertically
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Header part
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.symmetric(vertical: 10.0),
                 decoration: const BoxDecoration(
                   color: Color(0xFF00AEEF),
                   borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                 ),
                 child: Center(
                   child: Text('Edit Item ID: ${widget.item.itemID}',
                       style: const TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                 ),
               ),

               // --- Form Body ---
               _buildForm(),

               // --- Action Buttons ---
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                           style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Color(0xFF00AEEF))),
                           ),
                           child: const Text('Cancel', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Color(0xFF00AEEF))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEEF),
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            // Show loading indicator or text
                            child: _isSaving
                                ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator( strokeWidth: 2, color: Colors.white))
                                : const Text('Save Changes', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white)),
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

  /// Builds the main form content with input fields.
  Widget _buildForm() {
    return SingleChildScrollView( // Prevents overflow
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   _buildTextField(
                    label: 'Item Name', 
                    hintText: 'Enter item name', 
                    controller: _itemName, 
                    isRequired: true
                  ),
                   const SizedBox(height: 12),
                   _buildTextField(
                    label: 'Item Description', 
                    hintText: 'Enter item description', 
                    controller: _itemDescription, 
                    maxLines: 3, 
                    isRequired: true
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right Column
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   _buildItemTypeList(label: 'Item Type', hintText: 'Select item type'),
                   const SizedBox(height: 12),
                   _buildSuppliersList(label: 'Supplier', hintText: 'Select supplier'),
                   const SizedBox(height: 12),
                   _buildPriceField(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 /// Builds a reusable TextFormField.
 Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
 }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontFamily: 'NunitoSans')),
            if (isRequired) const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
             hintText: hintText,
             border: const OutlineInputBorder(),
             contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
             hintStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, fontSize: 12),
          ),
          // Add validator if field is required
          validator: isRequired ? (value) {
             if (value == null || value.trim().isEmpty) {
                return '$label is required';
             }
             return null;
          } : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
 }

  // Dropdown for the Item Type List
  Widget _buildItemTypeList({required String label, required String hintText}) {
    //Just fetches the entire item types na available, since it's just an edit item
    final itemTypesAsyncValue = ref.watch(fetchItemTypesList); 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [ Text(label), const Text('*', style: TextStyle(color: Colors.red)) ]),
        const SizedBox(height: 5),
        itemTypesAsyncValue.when(
          data: (typeList) {
            // Ensure the pre-selected value is valid within the current list -- TY Gemini for this! Complicated na function but it is what it is
            final isValidSelection = _selectedItemTypeId != null && typeList.any((t) => t.itemTypeID == _selectedItemTypeId);
            final currentValue = isValidSelection ? _selectedItemTypeId : null;

            return DropdownButtonFormField<int>(
              value: currentValue,
              hint: Text(hintText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
              items: typeList.map((itemType) => DropdownMenuItem<int>(
                    value: itemType.itemTypeID,
                    child: Text(itemType.itemType, style: const TextStyle(fontSize: 12)),
                 )).toList(),
              onChanged: (int? selectedId) => setState(() => _selectedItemTypeId = selectedId),
              validator: (value) => value == null ? 'Item type is required' : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            );
          },
          loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          error: (error, stack) => Text('Error: ${error.toString()}', style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    );
  }

  /// Builds the dropdown for selecting Supplier.
  Widget _buildSuppliersList({required String label, required String hintText}) {
     // Watch the provider that fetches the list of suppliers
    final suppliersAsyncValue = ref.watch(fetchSupplierList); // Ensure this provider exists and returns List<SupplierData> or similar

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Row(children: [ Text(label), const Text('*', style: TextStyle(color: Colors.red)) ]),
         const SizedBox(height: 5),
         suppliersAsyncValue.when(
            data: (supplierList) {
               // Ensure the pre-selected value is valid within the current list
               final isValidSelection = _selectedSupplierId != null && supplierList.any((s) => s.supplierID == _selectedSupplierId);
               final currentValue = isValidSelection ? _selectedSupplierId : null;

               return DropdownButtonFormField<int>(
                  value: currentValue,
                  isExpanded: true,
                  hint: Text(hintText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
                  items: supplierList.map((supplier) => DropdownMenuItem<int>(
                        value: supplier.supplierID,
                        child: Text(supplier.supplierName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                     )).toList(),
                  onChanged: (int? selectedId) => setState(() => _selectedSupplierId = selectedId),
                  validator: (value) => value == null ? 'Supplier is required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
               );
            },
            loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (error, stack) => Text('Error: ${error.toString()}', style: const TextStyle(color: Colors.red, fontSize: 12)),
         ),
      ],
    );
  }

  /// Builds the TextFormField for the Item Price.
  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children:[
            Text('Item Price'),
            Text(
              '*', 
              style: TextStyle(
                color: Colors.red
                )
              ) 
            ]
          ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _itemPrice,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          // Allow only numbers and up to two decimal places
          inputFormatters: [ FilteringTextInputFormatter.allow( RegExp(r'^\d*\.?\d{0,2}'), ) ],
          decoration: const InputDecoration(
             hintText: 'Enter item price',
             prefixText: 'P ',
             border: OutlineInputBorder(),
             contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
             hintStyle: TextStyle(fontSize: 12),
          ),
          validator: (value) {
             if (value == null || value.trim().isEmpty) return 'Price is required';
             final price = double.tryParse(value);
             if (price == null || price < 0) return 'Invalid positive price';
             return null; // Valid
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }
}