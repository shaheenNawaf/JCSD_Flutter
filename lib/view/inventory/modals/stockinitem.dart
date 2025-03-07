// ignore_for_file: library_private_types_in_public_api

//Default Imports
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/date_converter.dart'; //For Audit
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';

//Inventory Imports
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

//Employee Imports
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';

//Audit Imports
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_data.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

class StockInItemModal extends ConsumerStatefulWidget {
  const StockInItemModal({super.key});

  @override
  ConsumerState<StockInItemModal> createState() => _StockInItemModalState();
}

class _StockInItemModalState extends ConsumerState<StockInItemModal> {
  String? _selectedItem;
  String? _selectedReceiver;

  //Storing Data
  final TextEditingController _quantityController = TextEditingController();

  //Dummy Employee Data
  final List<String> _receivers = ['Receiver A', 'Receiver B', 'Receiver C'];

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 300 ? 400 : screenWidth * 0.9;
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
                  'Stock Item',
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
              child: Column(
                children: [
                  _buildItemList(),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Receiver',
                    hintText: 'Select employeee',
                    value: _selectedReceiver,
                    items: _receivers,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedReceiver = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildQuantityField(),
                ],
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
                        refreshTables();
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
                          int newQuantity = int.parse(
                              _quantityController.text); //New Stock in quantity

                          final fetchItem = InventoryService(); //For Backend
                          int? itemID =
                              await fetchItem.getIDByName(_selectedItem);

                          print(newQuantity);
                          print(_selectedItem);
                          print(itemID); //null
                          fetchItem.updateQuantity(itemID!, newQuantity);
                          print('Successfully stocked in: $itemID');
                        } catch (err, stackTrace) {
                          print('Error stocking in item. $err -- $stackTrace');
                        }
                        refreshTables();
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

  //Refreshing Inventory Tables
  void refreshTables() {
    ref.invalidate(fetchActive);
    ref.invalidate(fetchArchived);
  }

  //Fetching Items and Employee Methods
  Future<List<InventoryData>> fetchItemList(WidgetRef ref) async {
    return ref.read(fetchActive.future);
  }

  //Work in Progress -- For fetching Employee List
  // Future<List<EmployeeData>> fetchEmployees() async {
  //   return ref.read();
  // }

  Widget _buildItemList() {
    return FutureBuilder<List<InventoryData>>(
      future: fetchItemList(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No items found.');
        } else {
          List<String> itemNames =
              snapshot.data!.map((item) => item.itemName).toList();
          return _buildDropdownField(
            label: "Item List",
            hintText: "Select an item",
            value: _selectedItem, // Pass _selectedItem here
            items: itemNames,
            onChanged: (String? value) {
              // No need for setState here
              _selectedItem = value; // Update _selectedItem directly
            },
          );
        }
      },
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
          onChanged: (String? newValue) {
            // Update state here
            setState(() {
              value = newValue;
            });
            onChanged(newValue); // This notifies the parent widget
          },
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Quantity',
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
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            hintText: 'Enter quantity',
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
