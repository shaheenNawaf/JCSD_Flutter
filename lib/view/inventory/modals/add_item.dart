// ignore_for_file: library_private_types_in_public_api

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';

//Generic Import
import 'package:jcsd_flutter/view/generic/dialogs/generic_dialog.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';

class AddItemModal extends ConsumerStatefulWidget {
  const AddItemModal({super.key});

  @override
  ConsumerState<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends ConsumerState<AddItemModal> {
  bool _isSaving = false;
  int itemTypeID = -1;

  //Fetching data inside the different fields
  final TextEditingController _addItemName = TextEditingController();
  final TextEditingController _addItemDescription = TextEditingController();
  final TextEditingController _addItemType = TextEditingController();
  final TextEditingController _addItemSupplier = TextEditingController();
  final TextEditingController _addItemPrice = TextEditingController();
  final TextEditingController _addItemQuantity = TextEditingController();

  int? _selectedItemTypeID;
  int? _selectedSupplierID;

  //WIP if dili mag display ang name, then I will use this
  String? _selectedItemType;
  String? _selectedSupplier;

  @override
  void dispose() {
    _addItemPrice.dispose();
    _addItemDescription.dispose();
    _addItemType.dispose();
    _addItemSupplier.dispose();
    _addItemPrice.dispose();
    _addItemQuantity.dispose();
    super.dispose();
  }

  //Actual Backend Functions, streamlined para malinis and good for the eyes huhu so tired
  //Will add input validation din here soon

  //Obviously, if there's something wrong - then it does just return an empty input
  Future<void> _submitNewItem() async {
    if (_addItemName.text.isEmpty ||
        _addItemDescription.text.isEmpty ||
        _addItemPrice.text.isEmpty ||
        _addItemQuantity.text.isEmpty ||
        _addItemType.text.isEmpty ||
        _selectedItemTypeID == null ||
        _selectedSupplierID == null) {
      showCustomNotificationDialog(
          context: context,
          headerBar: "Empty Text",
          messageText: "Missing input on one of the fields.");
      return;
    }
    final int? itemQuantity = int.tryParse(_addItemQuantity.text);
    final double? itemPrice = double.tryParse(_addItemPrice.text);

    if (itemQuantity == null || itemPrice == null) {
      showCustomNotificationDialog(
          context: context,
          headerBar: "Empty Quantity/Price",
          messageText: "Missing input on either Quantity or Price.");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    //Creating of the InventoryData object
    final newItem = InventoryData(
      itemID: 0,
      supplierID: _selectedSupplierID!,
      itemName: _addItemName.text,
      itemTypeID: _selectedItemTypeID!,
      itemDescription: _addItemDescription.text,
      itemQuantity: itemQuantity,
      itemPrice: itemPrice,
      isVisible:
          true, //Kasi of course, all newly added items are active by default
    );

    //Actual Notifer to Provider comunication
    try {
      final addNotifier = ref.read(inventoryProvider.notifier);
      await addNotifier.addInventoryItem(newItem);

      if (mounted) {
        Navigator.pop(context);
        //Replace with notification
        showCustomNotificationDialog(
            context: context,
            headerBar: "Operation Success!",
            messageText: "Added new item successfully!");
      }

      //Add Audit Logs Logic Here
    } catch (err) {
      //Replace with notification
      showCustomNotificationDialog(
          context: context,
          headerBar: "Error",
          messageText: "Failed adding new item. Refer to \n $err");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.99;
    const double containerHeight = 380;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Add Item',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Item Name',
                            hintText: 'Enter item name',
                            setController: _addItemName,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Item Description',
                            hintText: 'Enter item description here',
                            maxLines: 1,
                            setController: _addItemDescription,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Item Quantity',
                            hintText: 'Initial item quantity',
                            setController: _addItemQuantity,
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildItemTypeList(
                            label: 'Item Type',
                            hintText: 'Select item type',
                          ),
                          const SizedBox(height: 12),
                          //Supplier Fields
                          _buildSuppliersList(
                            label: 'Supplier',
                            hintText: 'Select supplier',
                          ),
                          const SizedBox(height: 8),
                          _buildPriceField(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF00AEEF),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submitNewItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      //Adding Conditional Rendering, para aware ang user na being submitted ang data
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: Colors.white),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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

  //Changes nako, adding TextInputType to control user input type, para ranis validation mga broskers
  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
    required TextEditingController setController,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: setController,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemTypeList({
    required String label,
    required String hintText,
  }) {
    //Simplified fetching already, since I already have it as a FutureProvider and no need to directly re-render every time.

    final itemTypesList = ref.watch(fetchActiveTypes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        itemTypesList.when(
          data: (itemTypes) {
            return DropdownButtonFormField<int>(
              value: _selectedItemTypeID, // -> stores the value of the ID
              hint: Text(
                hintText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              items: itemTypes.map((itemTypes) {
                return DropdownMenuItem<int>(
                  value: itemTypes.itemTypeID, // -> Value of the ID
                  child: Text(
                    itemTypes.itemType, // Displays itemTypeName
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? selectedID) {
                setState(() {
                  _selectedItemTypeID = selectedID;
                });
              },
              //Validator huhu
              validator: (value) =>
                  value == null ? "Item type is required" : null,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stackTrace) {
            //Can be replaced into a notification
            showCustomNotificationDialog(
              context: context,
              headerBar: "Error encountered",
              messageText: "Failed to save selected item type. \n $error",
            );
            throw error;
          },
        )
      ],
    );
  }

  Widget _buildSuppliersList({
    required String label,
    required String hintText,
  }) {
    final suppliersNamesList = ref.watch(fetchAvailableSuppliers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        suppliersNamesList.when(
          data: (supplierNames) {
            return DropdownButtonFormField<int>(
              value: _selectedSupplierID,
              isExpanded: true,
              hint: Text(
                hintText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              icon: const Icon(Icons.arrow_drop_down),
              dropdownColor: Colors.white,
              items: supplierNames.map((supplier) {
                return DropdownMenuItem<int>(
                  value: supplier.supplierID,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      supplier.supplierName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? selectedID) {
                setState(
                  () {
                    _selectedSupplierID = selectedID;
                  },
                );
              },
              validator: (value) =>
                  value == null ? 'Supplier is required' : null,
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (error, stackTrace) {
            //Can be replaced into a notification
            showCustomNotificationDialog(
              context: context,
              headerBar: "Error encountered",
              messageText: "Failed to save selected supplier name. \n $error",
            );
            throw error;
          },
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
              'Enter Price',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _addItemPrice,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            hintText: 'Enter item price',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
