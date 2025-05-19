// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart'; // To get all product defs
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart'; // To get serials for a PD
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart'; // For bookingDetailNotifierProvider

import 'package:jcsd_flutter/api/global_variables.dart'; // For supabaseDB to get current user
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

// State providers for the modal's internal state
final _selectedProdDefIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final _selectedSerialNumberProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final _priceAtAdditionProvider =
    StateProvider.autoDispose<double?>((ref) => null);

class AddItemListModal extends ConsumerStatefulWidget {
  final int bookingId;
  // final int employeeId; // Assuming employee ID is fetched from auth or passed

  const AddItemListModal({
    super.key,
    required this.bookingId,
    // required this.employeeId,
  });

  @override
  ConsumerState<AddItemListModal> createState() => _AddItemListModalState();
}

class _AddItemListModalState extends ConsumerState<AddItemListModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isAdding = false;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '1'); // Default to 1

  @override
  void initState() {
    super.initState();
    // Clean up providers when modal is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(_selectedProdDefIdProvider);
      ref.invalidate(_selectedSerialNumberProvider);
      ref.invalidate(_priceAtAdditionProvider);
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _addItemToBooking() async {
    if (!_formKey.currentState!.validate()) {
      ToastManager()
          .showToast(context, 'Please correct the errors.', Colors.orange);
      return;
    }

    final selectedSerialNumber = ref.read(_selectedSerialNumberProvider);
    final priceAtAddition = ref.read(_priceAtAdditionProvider);

    if (selectedSerialNumber == null || priceAtAddition == null) {
      ToastManager().showToast(
          context, 'Please select an item and confirm price.', Colors.orange);
      return;
    }

    final currentUserId = supabaseDB.auth.currentUser?.id;
    if (currentUserId == null) {
      ToastManager().showToast(
          context, 'Error: Could not identify current user.', Colors.red);
      return;
    }
    // You might need to fetch the employee's 'employeeID' (bigint) from the 'employee' table
    // using the 'userID' (uuid) from auth. For simplicity, if your BookingService
    // can accept userID and resolve it to employeeID, that's fine.
    // Otherwise, you'd fetch it here. Let's assume for now your service handles it or you pass a placeholder.
    // For demonstration, let's assume employeeID is 1. Replace with actual logic.
    int placeholderEmployeeId =
        1; // Placeholder - REPLACE WITH ACTUAL LOGIC TO GET EMPLOYEE PK

    // Fetch the actual Employee Primary Key (employeeID) based on the current UserID (uuid)
    try {
      final employeeResponse = await supabaseDB
          .from('employee')
          .select('employeeID')
          .eq('userID', currentUserId)
          .maybeSingle();

      if (employeeResponse == null || employeeResponse['employeeID'] == null) {
        ToastManager().showToast(context,
            'Error: Employee record not found for current user.', Colors.red);
        return;
      }
      placeholderEmployeeId = employeeResponse['employeeID'] as int;
    } catch (e) {
      ToastManager().showToast(
          context, 'Error fetching employee ID: ${e.toString()}', Colors.red);
      return;
    }

    setState(() => _isAdding = true);

    try {
      await ref
          .read(bookingDetailNotifierProvider(widget.bookingId).notifier)
          .addItem(
            selectedSerialNumber,
            priceAtAddition,
            placeholderEmployeeId, // Pass the fetched or placeholder employee ID
          );
      ToastManager().showToast(
          context, 'Item added to booking successfully!', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      ToastManager().showToast(
          context, 'Failed to add item: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 600 : screenWidth * 0.9;

    final selectedProdDefId = ref.watch(_selectedProdDefIdProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        padding: const EdgeInsets.all(0), // No padding for the main container
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Center(
                  child: Text('Add Item to Booking',
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProductDefinitionDropdown(ref),
                      const SizedBox(height: 16),
                      if (selectedProdDefId != null) ...[
                        _buildSerialNumberDropdown(ref, selectedProdDefId),
                        const SizedBox(height: 16),
                      ],
                      _buildPriceField(),
                      const SizedBox(height: 16),
                      _buildQuantityField(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isAdding ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isAdding ? null : _addItemToBooking,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          foregroundColor: Colors.white),
                      child: _isAdding
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Add Item'),
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

  Widget _buildProductDefinitionDropdown(WidgetRef ref) {
    // Fetch active product definitions. Assuming isVisibleFilter = true for active.
    final productDefinitionsAsync =
        ref.watch(productDefinitionNotifierProvider(true));

    return productDefinitionsAsync.when(
      data: (state) {
        if (state.productDefinitions.isEmpty) {
          return const Text("No product definitions available.");
        }
        return DropdownButtonFormField<String?>(
          value: ref.watch(_selectedProdDefIdProvider),
          hint: const Text('Select Product Category',
              style: TextStyle(fontSize: 14)),
          isExpanded: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 15)),
          items: state.productDefinitions.map((ProductDefinitionData pd) {
            return DropdownMenuItem<String?>(
              value: pd.prodDefID,
              child: Text(pd.prodDefName, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            ref.read(_selectedProdDefIdProvider.notifier).state = newValue;
            ref.read(_selectedSerialNumberProvider.notifier).state =
                null; // Reset serial when PD changes
            if (newValue != null) {
              final selectedPd = state.productDefinitions
                  .firstWhere((pd) => pd.prodDefID == newValue);
              final msrp = selectedPd.prodDefMSRP;
              ref.read(_priceAtAdditionProvider.notifier).state = msrp;
              _priceController.text = msrp?.toStringAsFixed(2) ?? '';
            } else {
              ref.read(_priceAtAdditionProvider.notifier).state = null;
              _priceController.clear();
            }
          },
          validator: (value) =>
              value == null ? 'Please select a product' : null,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error loading products: $err',
          style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildSerialNumberDropdown(WidgetRef ref, String prodDefId) {
    final serialsAsync = ref.watch(serializedItemNotifierProvider(prodDefId));

    return serialsAsync.when(
      data: (serialState) {
        final availableSerials = serialState.serializedItems
            .where((item) => item.status.toLowerCase() == 'available')
            .toList();
        if (availableSerials.isEmpty) {
          return const Text("No available serial numbers for this product.",
              style: TextStyle(fontSize: 14));
        }
        return DropdownButtonFormField<String?>(
          value: ref.watch(_selectedSerialNumberProvider),
          hint: const Text('Select Serial Number',
              style: TextStyle(fontSize: 14)),
          isExpanded: true,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 15)),
          items: availableSerials.map((SerializedItem item) {
            return DropdownMenuItem<String?>(
              value: item.serialNumber,
              child:
                  Text(item.serialNumber, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            ref.read(_selectedSerialNumberProvider.notifier).state = newValue;
          },
          validator: (value) =>
              value == null ? 'Please select a serial number' : null,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error loading serials: $err',
          style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Price at Addition (PHP)',
        hintText: 'Enter price',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
      ],
      onChanged: (value) {
        ref.read(_priceAtAdditionProvider.notifier).state =
            double.tryParse(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Price is required';
        if (double.tryParse(value) == null || double.parse(value) < 0) {
          return 'Invalid price';
        }
        return null;
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      decoration: const InputDecoration(
        labelText: 'Quantity',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      readOnly: true, // Quantity is 1 for serialized items
      validator: (value) {
        if (value == null || value.isEmpty) return 'Quantity is required';
        if (int.tryParse(value) != 1) {
          return 'Quantity must be 1 for serialized items';
        }
        return null;
      },
    );
  }
}
