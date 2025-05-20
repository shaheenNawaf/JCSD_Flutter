// lib/view/inventory/purchase_orders/modals/view_approve_po_modal.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/view/inventory/purchase_orders/modals/confirm_ro_action_modal.dart';

final poDetailsProviderFamily = FutureProvider.autoDispose
    .family<PurchaseOrderData?, int>((ref, poId) async {
  final service = ref.watch(purchaseOrderServiceProvider);
  print("[poDetailsProviderFamily] Fetching details for PO ID: $poId");
  final poData = await service.getPurchaseOrderById(poId);
  if (poData != null) {
    print(
        "[poDetailsProviderFamily] Fetched PO: ${poData.poId}, Items count: ${poData.items?.length ?? 0}");
  } else {
    print("[poDetailsProviderFamily] PO ID: $poId not found.");
  }
  return poData;
});

// Provider to fetch serials by PO ID and Product Definition ID
final serialsByPoAndProductProvider = FutureProvider.autoDispose
    .family<List<SerializedItem>, ({int poId, String prodDefId})>(
        (ref, ids) async {
  print(
      "[serialsByPoAndProductProvider] Fetching serials for PO ID: ${ids.poId}, ProdDef ID: ${ids.prodDefId}");
  if (ids.prodDefId.isEmpty) {
    print(
        "[serialsByPoAndProductProvider] Empty prodDefId, returning empty list.");
    return [];
  }
  try {
    final response = await supabaseDB
        .from('item_serials')
        .select()
        .eq('purchaseOrderID',
            ids.poId) // Ensure this column exists and is populated
        .eq('prodDefID', ids.prodDefId);

    print(
        "[serialsByPoAndProductProvider] Raw response count for PO ${ids.poId}, PD ${ids.prodDefId}: ${response.length}");
    if (response.isNotEmpty) {
      // print("[serialsByPoAndProductProvider] First serial raw: ${response.first}");
    }
    return response.map((data) => SerializedItem.fromJson(data)).toList();
  } catch (e, st) {
    print("[serialsByPoAndProductProvider] Error fetching serials: $e\n$st");
    return []; // Return empty on error to prevent UI crash
  }
});

class ViewApprovePurchaseOrderModal extends ConsumerStatefulWidget {
  final PurchaseOrderData purchaseOrder;

  const ViewApprovePurchaseOrderModal({super.key, required this.purchaseOrder});

  @override
  ConsumerState<ViewApprovePurchaseOrderModal> createState() =>
      _ViewApprovePurchaseOrderModalState();
}

class _ViewApprovePurchaseOrderModalState
    extends ConsumerState<ViewApprovePurchaseOrderModal> {
  bool _isProcessing = false;
  final _rejectionReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _showCreateReturnOrderModal(
    BuildContext context,
    PurchaseOrderData po,
    PurchaseOrderItemData poItem,
    String serialNumberToReturn,
    String productName,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateReturnOrderModal(
        purchaseOrderId: po.poId,
        serialNumberToReturn: serialNumberToReturn,
        productName: productName,
      ),
    ).then((success) {
      if (success == true) {
        ref.invalidate(poDetailsProviderFamily(po.poId));
        ref.read(purchaseOrderListNotifierProvider.notifier).refresh();
        ref.invalidate(serializedItemNotifierProvider(poItem.prodDefID));
      }
    });
  }

  Future<void> _updatePOStatus(
      PurchaseOrderData currentPO, PurchaseOrderStatus newStatus,
      {String? notes}) async {
    setState(() => _isProcessing = true);
    final currentAuthUserId = supabaseDB.auth.currentUser?.id;
    int? adminIdForApproval;

    if (currentAuthUserId == null) {
      ToastManager().showToast(context, "User not authenticated", Colors.red);
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    if (newStatus == PurchaseOrderStatus.Approved) {
      try {
        final adminEmployeeRecord = await supabaseDB
            .from('employee')
            .select('employeeID')
            .eq('userID', currentAuthUserId)
            .eq('isAdmin', true)
            .maybeSingle();
        if (adminEmployeeRecord != null &&
            adminEmployeeRecord['employeeID'] != null) {
          adminIdForApproval = adminEmployeeRecord['employeeID'] as int;
        } else {
          ToastManager().showToast(
              context,
              'Error: Admin employee record not found or user is not admin.',
              Colors.red);
          setState(() => _isProcessing = false);
          return;
        }
      } catch (e) {
        ToastManager()
            .showToast(context, 'Error fetching admin details: $e', Colors.red);
        setState(() => _isProcessing = false);
        return;
      }
    }

    try {
      await ref.read(purchaseOrderListNotifierProvider.notifier).updatePOStatus(
            currentPO.poId,
            newStatus,
            adminId: adminIdForApproval,
            notes: notes ?? currentPO.note,
          );

      ToastManager().showToast(context,
          'PO ${newStatus.dbValue.toLowerCase()} successfully!', Colors.green);
      ref.invalidate(
          poDetailsProviderFamily(currentPO.poId)); // Refresh this modal's data
      ref
          .read(purchaseOrderListNotifierProvider.notifier)
          .refresh(); // Refresh list view
      Navigator.of(context).pop(true);
    } catch (e) {
      print('Error updating PO status: $e');
      ToastManager().showToast(
          context, 'Failed to update PO status: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showRejectionDialog(PurchaseOrderData currentPO) {
    _rejectionReasonController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Purchase Order'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _rejectionReasonController,
            decoration: const InputDecoration(
                labelText: 'Reason for Rejection (Optional)'),
            maxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _updatePOStatus(currentPO, PurchaseOrderStatus.Cancelled,
                  notes: _rejectionReasonController.text.trim().isEmpty
                      ? "Rejected by Admin"
                      : "Rejected: ${_rejectionReasonController.text.trim()}");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirm Rejection',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = screenWidth > 800 ? 750 : screenWidth * 0.9;
    final poDetailsAsyncValue =
        ref.watch(poDetailsProviderFamily(widget.purchaseOrder.poId));
    final supplierNamesMapAsync = ref.watch(supplierNameMapProvider);
    final productDefinitionsAsync =
        ref.watch(productDefinitionNotifierProvider(true));
    final currentUserRole = ref.watch(userRoleProvider).asData?.value;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: modalWidth,
        height: MediaQuery.of(context).size.height * 0.85,
        child: poDetailsAsyncValue.when(
          loading: () => _buildLoadingState(modalWidth),
          error: (err, stack) => _buildErrorState(modalWidth, err.toString()),
          data: (po) {
            if (po == null) {
              return _buildErrorState(modalWidth,
                  "Purchase Order details could not be loaded or PO not found.");
            }
            bool canAdminTakeAction = currentUserRole == 'admin' &&
                (po.status == PurchaseOrderStatus.PendingApproval ||
                    po.status == PurchaseOrderStatus.Revised);

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: _getHeaderColor(po.status),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text('PO ID: ${po.poId} - Details',
                            style: const TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.of(context).pop(),
                          tooltip: "Close")
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow("Current Status:", null,
                            valueWidget: _statusChip(po.status)),
                        supplierNamesMapAsync.when(
                          data: (map) => _buildDetailRow("Supplier:",
                              map[po.supplierID] ?? 'ID: ${po.supplierID}'),
                          loading: () =>
                              _buildDetailRow("Supplier:", "Loading..."),
                          error: (e, s) => _buildDetailRow("Supplier:", "Error",
                              valueWidget: const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16)),
                        ),
                        _buildDetailRow(
                            "Order Date:",
                            DateFormat('MMMM dd, yyyy HH:mm')
                                .format(po.orderDate.toLocal())),
                        _buildDetailRow(
                            "Expected Delivery:",
                            po.expectedDeliveryDate != null
                                ? DateFormat('MMMM dd, yyyy')
                                    .format(po.expectedDeliveryDate!.toLocal())
                                : "N/A"),
                        _buildDetailRow("Created By (Employee ID):",
                            po.createdByEmployee.toString()),
                        if (po.approvedByAdmin != null)
                          _buildDetailRow("Approved By (Admin ID):",
                              po.approvedByAdmin.toString()),
                        if (po.note != null && po.note!.isNotEmpty)
                          _buildDetailRow("Notes:", po.note!),
                        const SizedBox(height: 15),
                        const Divider(),
                        const Text("Order Items",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NunitoSans')),
                        const SizedBox(height: 8),
                        productDefinitionsAsync.when(
                          data: (pdState) {
                            final Map<String, String> productNameMap = pdState
                                .productDefinitions
                                .fold<Map<String, String>>(
                              {},
                              (map, pd) {
                                if (pd.prodDefID != null) {
                                  map[pd.prodDefID!] = pd.prodDefName;
                                }
                                return map;
                              },
                            );
                            return _buildLineItemsTableWithReturnAction(context,
                                ref, po, po.items ?? [], productNameMap);
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          error: (e, s) => const Text(
                              "Error loading product names.",
                              style: TextStyle(
                                  color: Colors.red, fontFamily: 'NunitoSans')),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                              "Total Estimated Cost: ₱${(po.totalEstimatedCost ?? 0.0).toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'NunitoSans')),
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
                      if (!canAdminTakeAction)
                        TextButton(
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        )
                      else ...[
                        TextButton(
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: _isProcessing
                              ? Container()
                              : const Icon(Icons.cancel_outlined, size: 18),
                          label: _isProcessing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Reject PO'),
                          onPressed: _isProcessing
                              ? null
                              : () => _showRejectionDialog(po),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: _isProcessing
                              ? Container()
                              : const Icon(Icons.check_circle_outline,
                                  size: 18),
                          label: _isProcessing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Approve PO'),
                          onPressed: _isProcessing
                              ? null
                              : () => _updatePOStatus(
                                  po, PurchaseOrderStatus.Approved),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(double modalWidth) {
    return SizedBox(
      width: modalWidth,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator())),
          Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Loading PO Details...")),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: null, child: Text("Close")),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(double modalWidth, String errorMsg) {
    return SizedBox(
      width: modalWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error: $errorMsg',
                  style: const TextStyle(color: Colors.red))),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close")),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'NunitoSans',
                    fontSize: 13)),
          ),
          Expanded(
            child: valueWidget ??
                Text(value ?? 'N/A',
                    style: const TextStyle(
                        fontFamily: 'NunitoSans', fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsTableWithReturnAction(
      BuildContext context,
      WidgetRef ref,
      PurchaseOrderData currentPO,
      List<PurchaseOrderItemData> items,
      Map<String, String> productNameMap) {
    if (items.isEmpty) {
      return const Center(
          child: Text("No items in this purchase order.",
              style: TextStyle(fontFamily: 'NunitoSans', color: Colors.grey)));
    }

    bool canInitiateReturn = currentPO.status == PurchaseOrderStatus.Received ||
        currentPO.status == PurchaseOrderStatus.PartiallyReceived;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(2.5),
            },
            border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
            children: const [
              TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 235, 235, 235)),
                children: [
                  Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('Product',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'NunitoSans'))),
                  Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('Ordered',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'NunitoSans'),
                          textAlign: TextAlign.right)),
                  Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('Received',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'NunitoSans'),
                          textAlign: TextAlign.right)),
                  Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Text('Received Serials / Actions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              fontFamily: 'NunitoSans'),
                          textAlign: TextAlign.center)),
                ],
              ),
            ]),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final poItem = items[index];
            final productName = productNameMap[poItem.prodDefID] ??
                'ID: ${poItem.prodDefID.substring(0, 6)}...';
            final serialsForThisItemAsync = ref.watch(
                serialsByPoAndProductProvider(
                    (poId: currentPO.poId, prodDefId: poItem.prodDefID)));

            return ExpansionTile(
              key: PageStorageKey<int>(poItem.purchaseItemID ?? index),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
              title: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Text(productName,
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'NunitoSans'))),
                  Expanded(
                      flex: 1,
                      child: Text(poItem.quantityOrdered.toString(),
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'NunitoSans'),
                          textAlign: TextAlign.right)),
                  Expanded(
                      flex: 1,
                      child: Text(poItem.quantityReceived.toString(),
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'NunitoSans'),
                          textAlign: TextAlign.right)),
                  const Expanded(flex: 2, child: SizedBox()),
                ],
              ),
              subtitle: poItem.quantityReceived > 0
                  ? const Text("View/Return Received Serials ↓",
                      style: TextStyle(fontSize: 10, color: Colors.blueAccent))
                  : null,
              children: [
                if (poItem.quantityReceived > 0)
                  serialsForThisItemAsync.when(
                    data: (serials) {
                      final returnableSerials = serials
                          .where((s) =>
                                  s.status.toLowerCase() == 'available' ||
                                  s.status.toLowerCase() ==
                                      'instock' || // Common alternative to Available
                                  s.status.toLowerCase() ==
                                      'defectiveinstock' // Explicitly for defective items in stock
                              )
                          .toList();

                      if (returnableSerials.isEmpty) {
                        return const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                                "No returnable serials recorded for this item (check status or if already returned).",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontStyle: FontStyle.italic)));
                      }
                      return Column(
                        children: returnableSerials.map((serial) {
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 0),
                            title: Text("SN: ${serial.serialNumber}",
                                style: const TextStyle(fontSize: 11)),
                            subtitle: Text("Status: ${serial.status}",
                                style: const TextStyle(fontSize: 10)),
                            trailing: null,
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5)))),
                    error: (e, s) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Error loading serials: $e",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 11))),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getHeaderColor(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.PendingApproval:
        return Colors.orange.shade700;
      case PurchaseOrderStatus.Approved:
        return Colors.blue.shade700;
      case PurchaseOrderStatus.Revised:
        return Colors.purple.shade600;
      case PurchaseOrderStatus.Received:
        return Colors.green.shade700;
      case PurchaseOrderStatus.PartiallyReceived:
        return Colors.teal.shade600;
      case PurchaseOrderStatus.Cancelled:
        return Colors.red.shade700;
      default:
        return const Color(0xFF00AEEF);
    }
  }

  Widget _statusChip(PurchaseOrderStatus status) {
    Color chipColor = _getHeaderColor(status);
    String chipText = status.dbValue
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();
    Color textColor = Colors.white;
    if (status == PurchaseOrderStatus.Draft ||
        status == PurchaseOrderStatus.Unknown) {
      textColor = Colors.black87;
    }

    return Chip(
      label: Text(chipText,
          style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'NunitoSans')),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
