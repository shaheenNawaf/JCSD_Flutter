// ignore_for_file: library_private_types_in_public_api

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_notifier.dart';
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
  Future<void> _submitNewItem() async {

    if
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
                              setController: _addItemDescription),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Item Quantity',
                            hintText: 'Initial item quantity',
                            setController: _addItemQuantity,
                            maxLines: 1,
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
                            value: _selectedItemType,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedItemType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          //Supplier Fields
                          _buildSuppliersList(
                            label: 'Supplier',
                            hintText: 'Select supplier',
                            value: _selectedSupplier,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedSupplier = value;
                              });
                            },
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                      onPressed: () async {
                        try {
                          final InventoryNotifier notifier =
                              InventoryNotifier(context, true);
                          final InventoryService addItem = InventoryService();

                          String itemName = _addItemName.text;
                          String itemDescription = _addItemDescription.text;
                          int itemQuantity = int.parse(_addItemQuantity.text);
                          int supplierID = int.parse(_addItemSupplier.text);
                          double itemPrice = double.parse(_addItemPrice.text);

                          await addItem.addItem(
                              itemName,
                              itemTypeID,
                              itemDescription,
                              itemQuantity,
                              supplierID,
                              itemPrice);
                        } catch (err) {
                          print('Tried adding item details. $err');
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
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

  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
    required TextEditingController setController,
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
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
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

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
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
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? getItemType) {
            print(getItemType);
            _addItemType.text = getItemType ?? '';
          },
        ),
      ],
    );
  }

  Widget _buildItemTypeList({
    required String label,
    required String hintText,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return FutureBuilder(
        future: ref.read(fetchItemTypesList.future),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error fetching: ${snapshot.error}');
          }
          final typeList = snapshot.data!;

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
                DropdownButtonFormField<String>(
                  value: value,
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
                  items: typeList.map((itemTypes) {
                    return DropdownMenuItem<String>(
                      value: itemTypes.itemType,
                      child: Text(
                        itemTypes.itemType,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? getTypeName) async {
                    print(getTypeName);

                    if (getTypeName != null) {
                      int fetchID = await ref
                          .read(itemTypesProvider)
                          .getIdByName(getTypeName);
                      if (fetchID != -1) {
                        itemTypeID = fetchID;
                      }
                    }
                  },
                ),
              ]);
        });
  }

  Widget _buildSuppliersList({
    required String label,
    required String hintText,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return FutureBuilder(
      future: ref.read(fetchAvailableSuppliers.future),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error fetching: ${snapshot.error}');
        }

        final supplierList = snapshot.data!;

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
            DropdownButtonFormField<String>(
              value: value,
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
              items: supplierList.map((supplier) {
                return DropdownMenuItem<String>(
                  value: supplier.supplierID.toString(),
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
              onChanged: (String? getSupplierText) {
                print(getSupplierText);
                _addItemSupplier.text = getSupplierText ?? '';
              },
            ),
          ],
        );
      },
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
