// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//Actual Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';

//Just in case
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';

class EditItemModal extends ConsumerStatefulWidget {
  final int itemInventoryID;

  const EditItemModal({super.key, required this.itemInventoryID});

  @override
  ConsumerState<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends ConsumerState<EditItemModal> {
  // State Variables
  InventoryData? _initialItemData;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Controllers
  final TextEditingController _itemName = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();
  final TextEditingController _itemPrice = TextEditingController();

  // Selected IDs for dropdowns
  int? _selectedItemTypeId;
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  Future<void> _loadItemData() async {
    // Ensure widget is still mounted before starting async work in initState
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final item = await ref
          .read(inventoryServiceProv)
          .getItemByID(widget.itemInventoryID);

      if (!mounted) return; // Check again after await

      if (item == null) {
        throw Exception('Item with ID ${widget.itemInventoryID} not found.');
      }

      setState(() {
        _initialItemData = item;
        _itemName.text = item.itemName;
        _itemDescription.text = item.itemDescription;
        _itemPrice.text = item.itemPrice.toStringAsFixed(2);
        _selectedItemTypeId = item.itemTypeID;
        _selectedSupplierId = item.supplierID;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading item data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load item details. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _itemName.dispose();
    _itemDescription.dispose();
    _itemPrice.dispose();
    super.dispose();
  }

//Handles save item logic ito
  Future<void> _saveChanges() async {
    if (_initialItemData == null || !mounted) return;

    // 1. Validate Input
    if (_itemName.text.isEmpty ||
        _itemDescription.text.isEmpty ||
        _itemPrice.text.isEmpty ||
        _selectedItemTypeId == null ||
        _selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all required fields.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    final double? price = double.tryParse(_itemPrice.text);

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid or negative price.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Set Saving State
    setState(() => _isSaving = true);

    // 4. Create Updated InventoryData object
    final updatedItem = _initialItemData!.copyWith(
      itemName: _itemName.text.trim(), // Trim whitespace
      itemDescription: _itemDescription.text.trim(), // Trim whitespace
      itemPrice: price,
      itemTypeID: _selectedItemTypeId!, // Not null due to validation
      supplierID: _selectedSupplierId!, // Not null due to validation
    );

    // 5. Call Notifier
    try {
      // Use ref.read for one-off action
      final notifier = ref.read(inventoryProvider.notifier);
      await notifier.updateInventoryItem(updatedItem);

      // 6. Success: Close modal and show message
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Item updated successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // 7. Error: Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update item: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      // 8. Reset Saving State
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;
    // Adjust height slightly if content might overflow, or rely on SingleChildScrollView
    const double containerHeight = 420; // Increased slightly

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        // Use SizedBox instead of Container if only for sizing
        width: containerWidth,
        height: containerHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Center(
                child: Text('Edit Item',
                    style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white)),
              ),
            ),

            // --- Body (Conditional based on loading/error) ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                        ))
                      : _buildForm(), // Build form only when data is loaded
            ),

            // --- Action Buttons ---
            if (!_isLoading &&
                _errorMessage == null) // Only show buttons if form is visible
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isSaving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

//Re-usable Form Widget, para mas dali ang conditional rendering sa build() method
  Widget _buildForm() {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTextField(
                        label: 'Item Name',
                        hintText: 'Enter item name',
                        setController: _itemName),
                    const SizedBox(height: 12),
                    _buildTextField(
                        label: 'Item Description',
                        hintText: 'Enter item description here',
                        setController: _itemDescription,
                        maxLines: 3),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildItemTypeList(
                        label: 'Item Type', hintText: 'Select item type'),
                    const SizedBox(height: 12),
                    _buildSuppliersList(
                        label: 'Supplier', hintText: 'Select supplier'),
                    const SizedBox(height: 12),
                    _buildPriceField(),
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
    required TextEditingController setController,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'NunitoSans', fontWeight: FontWeight.normal)),
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: setController,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              //Add notification here michael, and probably navigator.pop(Context)
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildItemTypeList({required String label, required String hintText}) {
    final itemTypesAsyncValue = ref.watch(fetchItemTypesList);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'NunitoSans', fontWeight: FontWeight.normal)),
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        itemTypesAsyncValue.when(
          data: (typeList) {
            // Check if the initially loaded ID is still valid in the current list
            final isValidSelection = _selectedItemTypeId != null &&
                typeList.any((t) => t.itemTypeID == _selectedItemTypeId);
            final currentValue = isValidSelection ? _selectedItemTypeId : null;

            return DropdownButtonFormField<int>(
              value: currentValue,
              hint: Text(hintText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Colors.grey)),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              items: typeList.map((itemType) {
                return DropdownMenuItem<int>(
                  value: itemType.itemTypeID,
                  child: Text(itemType.itemType,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 12)),
                );
              }).toList(),
              onChanged: (int? selectedId) {
                // Update state when user changes selection
                setState(() => _selectedItemTypeId = selectedId);
              },
              validator: (value) =>
                  value == null ? 'Item type is required' : null,
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, stack) => const Text(
            'Error loading types',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSuppliersList(
      {required String label, required String hintText}) {
    final suppliersAsyncValue = ref.watch(fetchAvailableSuppliers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'NunitoSans', fontWeight: FontWeight.normal)),
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        suppliersAsyncValue.when(
          data: (supplierList) {
            final isValidSelection = _selectedSupplierId != null &&
                supplierList.any((s) => s.supplierID == _selectedSupplierId);
            final currentValue = isValidSelection ? _selectedSupplierId : null;

            return DropdownButtonFormField<int>(
              value: currentValue,
              isExpanded: true,
              hint: Text(hintText,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                      color: Colors.grey)),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              items: supplierList.map((supplier) {
                return DropdownMenuItem<int>(
                  value: supplier.supplierID,
                  child: Text(supplier.supplierName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 12)),
                );
              }).toList(),
              onChanged: (int? selectedId) {
                setState(() => _selectedSupplierId = selectedId);
              },
              validator: (value) =>
                  value == null ? 'Supplier is required' : null,
            );
          },
          loading: () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, stack) => const Text(
            'Error loading suppliers',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Item Price',
              style: TextStyle(
                  fontFamily: 'NunitoSans', fontWeight: FontWeight.normal),
            ),
            Text(
              '*',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _itemPrice,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d{0,2}'),
            )
          ],
          decoration: const InputDecoration(
            hintText: 'Enter item price',
            prefixText: 'P ',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Price is required';
            }
            final price = double.tryParse(value);
            if (price == null || price < 0) {
              return 'Invalid price';
            }
            return null;
          },
        ),
      ],
    );
  }
}
