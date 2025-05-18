import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Default Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_item_data.dart';

import '../../../../backend/modules/accounts/account_notifier.dart'; // For userProvider

//Backend Imports
//Suppliers Data and Providers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_providers.dart';

//VRO
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';
import '../../../../backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';

//Generic
import 'package:jcsd_flutter/widgets/header.dart';

//Inventory
import 'package:jcsd_flutter/view/inventory/vendor_return/modals/create_vro_modal.dart';
import 'package:jcsd_flutter/view/inventory/vendor_return/modals/view_vro_modal.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';

class CreateVROModal extends ConsumerStatefulWidget {
  const CreateVROModal({super.key});

  @override
  ConsumerState<CreateVROModal> createState() => _CreateVROModalState();
}

class _CreateVROModalState extends ConsumerState<CreateVROModal> {
  final _formKey = GlobalKey<FormState>();

  SuppliersData? _selectedSupplier;
  PurchaseOrderData? _selectedPO;
  final Set<SerializedItem> _selectedSerials = {};
  late String _vroNumber;
  String _notes = '';
  final String _initialVROStatus = "Draft";

  @override
  void initState() {
    super.initState();
    _vroNumber =
        'VRO-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // activeSuppliersForDropdownProvider is FutureProvider, watched directly in build
      ref
          .read(vendorReturnOrderNotifierProvider.notifier)
          .clearDefectiveSerials();
    });
  }

  Future<void> _createVRO() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedSupplier == null ||
        _selectedPO == null ||
        _selectedSerials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content:
                Text('Supplier, PO, and at least one item must be selected.')),
      );
      return;
    }

    final vroNotifier = ref.read(vendorReturnOrderNotifierProvider.notifier);
    // Use your actual provider for current employee data
    final currentEmployeeAsync =
        ref.read(currentEmployeeDataProvider); // Assumed provider

    if (!currentEmployeeAsync.hasValue ||
        currentEmployeeAsync.value?.employeeID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Current employee data not available.')),
      );
      return;
    }
    final employeeId = currentEmployeeAsync.value!.employeeID!;

    final List<VendorReturnOrderItem> vroItems = _selectedSerials.map((serial) {
      return VendorReturnOrderItem(
        vroItemID: 0,
        vroID: 0,
        returnedSerialNumber: serial.toString(),
        prodDefID: serial.prodDefID,
        costAtTimeOfPurchase: serial.costPrice ?? 0.0,
        rejectionReason: 'Defective on Arrival',
        createdAt: DateTime.now(),
      );
    }).toList();

    final newVROData = VendorReturnOrder(
      vroID: 0,
      vroNumber: _vroNumber,
      supplierID: _selectedSupplier!.supplierID,
      originalPoID: _selectedPO!.poId,
      status: _initialVROStatus,
      isReplacementExpected: true,
      returnInitiationDate: DateTime.now(),
      createdByEmployeeID: employeeId,
      notes: _notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: const [],
    );

    try {
      final createdVRO = await vroNotifier.createVRO(
        vroData: newVROData,
        items: vroItems,
        initialDefectiveStatus: "Defective",
        postCreationSerialStatus: "PendingReturn",
      );

      if (mounted && createdVRO != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text('VRO ${createdVRO.vroNumber} created!')),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to create VRO.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(activeSuppliersForDropdownProvider);

    // Watch the main PO list and filter client-side for the dropdown
    final allPOsAsync = ref.watch(purchaseOrderListNotifierProvider);

    List<PurchaseOrderData> filteredPOs = [];
    if (_selectedSupplier != null && allPOsAsync.hasValue) {
      filteredPOs = allPOsAsync.value!.purchaseOrders
          .where((po) =>
                  po.supplierID == _selectedSupplier!.supplierID &&
                  (po.status ==
                          PurchaseOrderStatus
                              .Received || // Using your enum from PurchaseOrderData
                      po.status == PurchaseOrderStatus.PartiallyReceived ||
                      po.status ==
                          PurchaseOrderStatus
                              .Approved) // Or other relevant statuses
              )
          .toList();
    }

    final defectiveSerialsAsync =
        ref.watch(defectiveSerialsForSelectedPOProvider);

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Create Vendor Return Order'),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: "Close")
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _vroNumber,
                decoration: const InputDecoration(
                    labelText: 'VRO Number', border: OutlineInputBorder()),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: suppliersAsync.when(
                      data: (suppliers) =>
                          DropdownButtonFormField<SuppliersData>(
                        decoration: const InputDecoration(
                            labelText: 'Select Supplier *',
                            border: OutlineInputBorder()),
                        value: _selectedSupplier,
                        isExpanded: true,
                        items: suppliers
                            .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.supplierName ?? '',
                                    overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          if (!mounted) return;
                          setState(() {
                            _selectedSupplier = val;
                            _selectedPO = null;
                            _selectedSerials.clear();
                            ref
                                .read(
                                    vendorReturnOrderNotifierProvider.notifier)
                                .clearDefectiveSerials();
                            // Trigger PO list filter if needed, though watching allPOsAsync and filtering locally
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Supplier is required' : null,
                      ),
                      loading: () => const Center(
                          child: SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                      error: (e, s) => Text('Error: $e'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<PurchaseOrderData>(
                      decoration: const InputDecoration(
                          labelText: 'Select Original PO *',
                          border: OutlineInputBorder()),
                      value: _selectedPO,
                      isExpanded: true,
                      disabledHint: _selectedSupplier == null
                          ? const Text("Select supplier first")
                          : (filteredPOs.isEmpty
                              ? const Text("No eligible POs")
                              : null),
                      items: _selectedSupplier == null
                          ? []
                          : filteredPOs
                              .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.poId.toString(),
                                      overflow: TextOverflow.ellipsis)))
                              .toList(), // Using poId for display
                      onChanged: _selectedSupplier == null
                          ? null
                          : (val) {
                              if (!mounted) return;
                              setState(() {
                                _selectedPO = val;
                                _selectedSerials.clear();
                                if (val != null) {
                                  ref
                                      .read(vendorReturnOrderNotifierProvider
                                          .notifier)
                                      .fetchDefectiveSerialsForPO(
                                          val.poId, "Defective");
                                } else {
                                  ref
                                      .read(vendorReturnOrderNotifierProvider
                                          .notifier)
                                      .clearDefectiveSerials();
                                }
                              });
                            },
                      validator: (v) => v == null ? 'PO is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Select Defective Items for Return *:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: defectiveSerialsAsync.when(
                  data: (serials) {
                    if (_selectedPO == null) {
                      return const Center(
                          child: Text('Please select a Purchase Order first.'));
                    }
                    if (serials.isEmpty) {
                      return const Center(
                          child: Text(
                              'No items marked "Defective" found for this PO.'));
                    }
                    return Container(
                      decoration:
                          BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: serials.length,
                        itemBuilder: (context, index) {
                          final serial = serials[index];
                          return CheckboxListTile(
                            title: Text(serial.serialNumber ?? 'N/A'),
                            subtitle: Text(
                                'Product ID: ${serial.prodDefID} - Cost: ${serial.costPrice?.toStringAsFixed(2) ?? 'N/A'}'),
                            value: _selectedSerials.any(
                                (s) => s.serialNumber == serial.serialNumber),
                            onChanged: (bool? value) {
                              if (!mounted) return;
                              setState(() {
                                if (value == true) {
                                  _selectedSerials.add(serial);
                                } else {
                                  _selectedSerials.removeWhere((s) =>
                                      s?.serialNumber == serial.serialNumber);
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true),
                maxLines: 2,
                onSaved: (value) => _notes = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save_alt_outlined),
          onPressed: _createVRO,
          label: const Text('Create VRO'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ],
    );
  }
}
