// stock_in_item.dart (Refactored)
// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart'; // Access inventoryProvider

//Employee Information
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';

// Audit Logs
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_state.dart';
import 'package:jcsd_flutter/view/generic/dialogs/generic_dialog.dart'; // Create this provider

class StockInItemModal extends ConsumerStatefulWidget {
  const StockInItemModal({super.key});

  @override
  ConsumerState<StockInItemModal> createState() => _StockInItemModalState();
}

class _StockInItemModalState extends ConsumerState<StockInItemModal> {
  // Base Variables
  int? _selectedItemId;
  int? _selectedEmployeeId;
  bool _isSaving = false;

  // Controllers
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

//Main Stock-In Logic, sep na sa UI hehe!
  Future<void> _stockInItem() async {
    // Same structure as previous methods, Validation->Parsing->Sending
    // Essentially very efficient way in checking (validation) prior to sending, which is v nice!

    if (_selectedItemId == null ||
        _selectedEmployeeId == null ||
        _quantityController.text.isEmpty) {
      showCustomNotificationDialog(
          context: context,
          headerBar: 'Invalid Input',
          messageText: 'Please select item, receiver, and enter quantity.');
      return;
    }

    final int? quantityToAdd = int.tryParse(_quantityController.text);
    if (quantityToAdd == null || quantityToAdd <= 0) {
      showCustomNotificationDialog(
          context: context,
          headerBar: 'Invalid Quantity',
          messageText: 'Please enter a valid positive quantity.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final stockNotifier = ref.read(inventoryProvider.notifier);
      await stockNotifier.stockInItem(_selectedItemId!, quantityToAdd);

      // final auditService = ref.read(auditServiceProvider); // Assuming auditServiceProvider exists
      // await auditService.logStockIn(
      //    itemId: _selectedItemId!,
      //    quantityAdded: quantityToAdd,
      //    employeeId: 1, //Samtang wala pay employee functionality
      // );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Stock added successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add stock: ${e.toString()}'),
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
    double containerWidth =
        screenWidth > 400 ? 450 : screenWidth * 0.9; // Slightly wider
    // Height might need adjustment based on content
    const double containerHeight = 380; // Adjusted height

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        // Use SizedBox for sizing
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
                child: Text('Stock In Item',
                    style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white)),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // Take minimum vertical space
                    children: [
                      _buildItemListDropdown(), // Use Inventory State
                      const SizedBox(height: 16),
                      // _buildEmployeeDropdown(), // For when Employee is implemented already
                      // const SizedBox(height: 16),
                      _buildQuantityField(),
                    ],
                  ),
                ),
              ),
            ),

            // --- Action Buttons ---
            Padding(
              padding: const EdgeInsets.all(16.0), // Consistent padding
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
                      onPressed: _isSaving
                          ? null
                          : _stockInItem, // Call the stock-in method
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
                          : const Text('Submit',
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

  // --- Helper: Item Dropdown ---
  Widget _buildItemListDropdown() {
    // Read the current state directly - doesn't need to rebuild if inventory changes *while modal is open*
    // Use watch if you *want* the dropdown to update live (e.g., if an item is added/removed elsewhere)
    final inventoryState = ref.watch(inventoryProvider).state;
    // Filter for active items if necessary, assuming isVisible determines this
    final activeItems =
        inventoryState.originalData.where((item) => item.isVisible).toList();

    // Sort items alphabetically for better usability
    activeItems.sort(
        (a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));

    return _buildDropdownFormField<int>(
      // Use ID as value
      label: "Item to Stock In",
      hintText: "Select an item",
      value: _selectedItemId,
      items: activeItems.map((item) {
        return DropdownMenuItem<int>(
          value: item.itemID,
          child: Text(item.itemName, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedItemId = newValue;
        });
      },
      // Add a check icon for visual feedback
      selectedItemBuilder: (BuildContext context) {
        return activeItems.map<Widget>((InventoryData item) {
          return Row(
            children: [
              Expanded(
                  child: Text(item.itemName, overflow: TextOverflow.ellipsis)),
              if (_selectedItemId == item.itemID)
                const Icon(Icons.check, color: Colors.green, size: 20),
            ],
          );
        }).toList();
      },
    );
  }

  // --- Helper: Employee Dropdown ---
  Widget _buildEmployeeDropdown() {
    // --- ASSUMPTION: fetchEmployeesProvider exists and returns List<EmployeeData> ---
    final employeesAsyncValue = ref.watch(fetchEmployeesProvider);

    return employeesAsyncValue.when(
      data: (employeeList) {
        // Sort employees alphabetically
        employeeList.sort((a, b) => (a.employeeName ?? '')
            .toLowerCase()
            .compareTo((b.employeeName ?? '')
                .toLowerCase())); // Handle potential null names

        return _buildDropdownFormField<int>(
          // Use ID as value
          label: 'Receiver (Employee)',
          hintText: 'Select employee',
          value: _selectedEmployeeId,
          items: employeeList.map((employee) {
            // Assuming EmployeeData has employeeID and employeeName
            return DropdownMenuItem<int>(
              value: employee.employeeID, // Use the actual ID
              child: Text(employee.employeeName ?? 'Unnamed Employee',
                  overflow: TextOverflow.ellipsis), // Handle null name
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _selectedEmployeeId = newValue;
            });
          },
          selectedItemBuilder: (BuildContext context) {
            return employeeList.map<Widget>((EmployeeData emp) {
              return Row(
                children: [
                  Expanded(
                      child: Text(emp.employeeName ?? 'Unnamed',
                          overflow: TextOverflow.ellipsis)),
                  if (_selectedEmployeeId == emp.employeeID)
                    const Icon(Icons.check, color: Colors.green, size: 20),
                ],
              );
            }).toList();
          },
        );
      },
      loading: () => const Center(
          child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2))),
      error: (error, stack) => Text('Error loading employees: $error',
          style: const TextStyle(color: Colors.red)),
    );
  }

  // --- Generic Dropdown Helper (similar to previous modals) ---
  Widget _buildDropdownFormField<T>({
    required String label,
    required String hintText,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    List<Widget> Function(BuildContext)?
        selectedItemBuilder, // Optional builder for selected item display
    String? Function(T?)? validator, // Optional validator
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
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hintText,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.grey)),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 12.0), // Adjust padding
          ),
          isExpanded: true, // Ensure dropdown takes full width
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: Colors.white,
          items: items,
          onChanged: onChanged,
          selectedItemBuilder:
              selectedItemBuilder, // Use the builder if provided
          validator: validator ??
              (v) => v == null
                  ? 'This field is required'
                  : null, // Default validator
        ),
      ],
    );
  }

  // --- Quantity Field Helper ---
  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Quantity to Add',
                style: TextStyle(
                    fontFamily: 'NunitoSans', fontWeight: FontWeight.normal)),
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          // Use TextFormField for validation
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Enter quantity',
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
              return 'Quantity is required';
            }
            final int? quantity = int.tryParse(value);
            if (quantity == null || quantity <= 0) {
              return 'Enter a positive number';
            }
            return null;
          },
        ),
      ],
    );
  }
}
