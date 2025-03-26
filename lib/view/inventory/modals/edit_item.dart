// ignore_for_file: library_private_types_in_public_api

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';

//Inventory, Supplier and Item Type Imports
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';

class EditItemModal extends ConsumerStatefulWidget {
  final int itemInventoryID;

  const EditItemModal({super.key, required this.itemInventoryID});

  @override
  ConsumerState<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends ConsumerState<EditItemModal> {
  //For Displaying Names  on Dropdown - WAG GALAWIN
  String? _selectedItemType;
  String? _selectedSupplier;

  //To Store the actual numbers
  late int _initItemTypeID;
  late int _initSupplierID;

  // Controllers for default input
  final TextEditingController _itemName = TextEditingController();
  final TextEditingController _itemDescription = TextEditingController();
  final TextEditingController _supplierID = TextEditingController();
  final TextEditingController _itemPrice = TextEditingController();
  final TextEditingController _itemQuantity = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  @override
  void dispose() {
    _priceController.dispose();
    _itemName.dispose();
    _itemDescription.dispose();
    _supplierID.dispose();
    _itemPrice.dispose();
    _itemQuantity.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //Don't touch, retrieves the necessary text from their respective tables based from the stored ID
    initialSupplierName(_initSupplierID);
    initialItemType(_initItemTypeID);
  }

  Future<void> initialSupplierName(int supplierID) async {
    final supplierService = SuppliersService();
    String supplierName = await supplierService.getSupplierNameByID(supplierID);

    setState(() {
      _selectedSupplier =
          supplierName; // Set Value to Supplier's Name based on the ID
    });
  }

  Future<void> initialItemType(int typeID) async {
    final typeService = ItemtypesService();
    String itemType = await typeService.getTypeNameByID(typeID);

    print(itemType);
    setState(() {
      _selectedItemType = itemType;
    });
  }

  @override
  Widget build(BuildContext context) {
    //For itemID usage
    final inventoryState = ref.watch(inventoryProvider);
    final itemBaseData = inventoryState.originalData.firstWhere(
      (item) => item.itemID == widget.itemInventoryID,
      orElse: () => InventoryData(
          itemID: -1,
          supplierID: -1,
          itemName: "",
          itemTypeID: -1,
          itemDescription: "",
          itemQuantity: -1,
          itemPrice: -1,
          isVisible: false),
    );

    //Checker and Error Handler for multiple hidden cases
    if (itemBaseData.itemID == -1 ||
        itemBaseData.supplierID == -1 ||
        itemBaseData.itemTypeID == -1) {
      return const AlertDialog(
        title: Text('Error'),
        content: Text('Item not found.'),
      );
    }

    //Data loaded to controllers
    _itemName.text = itemBaseData.itemName;
    _itemDescription.text = itemBaseData.itemDescription;
    _itemQuantity.text = itemBaseData.itemQuantity.toString();

    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;
    const double containerHeight = 390;

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
                  'Edit Item',
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
                            setController: _itemName,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Item Description',
                            hintText: 'Enter item description here',
                            setController: _itemDescription,
                          ),
                          const SizedBox(height: 8),
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
                          _buildSupliersList(
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
                          final InventoryService items = InventoryService();

                          int itemID = widget.itemInventoryID;
                          String itemName = _itemName.text;
                          int itemTypeID = _initItemTypeID;
                          String itemDescription = _itemDescription.text;
                          int itemQuantity = int.parse(_itemQuantity.text);
                          int supplierID = _initSupplierID;
                          double itemPrice = double.parse(_itemPrice.text);

                          await items.updateItem(
                              itemID,
                              itemName,
                              itemTypeID,
                              itemDescription,
                              itemQuantity,
                              supplierID,
                              itemPrice);
                        } catch (err) {
                          print('Tried updating item details. $err');
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
                        'Save Changes',
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

  Widget _buildSupliersList({
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
                      value: supplier.supplierName,
                      child: Text(
                        supplier.supplierName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? getSupplierText) async {
                    print(getSupplierText);

                    if (getSupplierText != null) {
                      int fetchID = await ref
                          .read(supplierServiceProv)
                          .getNameByID(getSupplierText);
                      if (fetchID != -1) {
                        _initSupplierID = fetchID;
                      }
                    }
                  },
                ),
              ]);
        });
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
                        _initItemTypeID = fetchID;
                      }
                    }
                  },
                ),
              ]);
        });
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
          controller: _itemPrice,
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
