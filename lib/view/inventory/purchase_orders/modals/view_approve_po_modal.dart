// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

//Default Imports
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/api/global_variables.dart';

//Backend Imports
//Accounts
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart'; // For userRoleProvider

//Suppliers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // For supplierNameMapProvider

//Inventory
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart'; // For product names
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';

// UI Imports
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

//Provider for fetching the entire PO Details
final poDetailsProviderFamily = FutureProvider.autoDispose
    .family<PurchaseOrderData?, int>((ref, poId) async {
  final service = ref.watch(purchaseOrderServiceProvider);
  return service.getPurchaseOrderById(poId);
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
  final _formKey = GlobalKey<FormState>(); // For rejection reason

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _updatePOStatus(
      PurchaseOrderData currentPO, PurchaseOrderStatus newStatus,
      {String? notes}) async {
    setState(() => _isProcessing = true);
    final currentAuthUserId = supabaseDB.auth.currentUser?.id;
    int? adminIdForApproval;

    if (currentAuthUserId == null) {
      ToastManager()
          .showToast(context, "User not authorized/authenticated", Colors.red);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
      return;
    }

    if (newStatus == PurchaseOrderStatus.Approved) {
      if (currentAuthUserId != null) {
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
              context, 'Error: Admin employee record not found.', Colors.red);
          setState(() => _isProcessing = false);
          return;
        }
      } else {
        ToastManager().showToast(
            context, 'Error: User not authenticated for approval.', Colors.red);
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

      ToastManager().showToast(
          context,
          'Purchase Order ${newStatus.dbValue.toLowerCase()} successfully!',
          Colors.green);
      ref.invalidate(poDetailsProviderFamily(currentPO.poId));
      ref.read(purchaseOrderListNotifierProvider.notifier).refresh();
      Navigator.of(context)
          .pop(true); // Return true to indicate an update occurred
    } catch (e) {
      print('Error updating PO status: $e');
      ToastManager().showToast(
          context, 'Failed to update PO status: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showRejectionDialog(PurchaseOrderData currentPO) {
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
              Navigator.of(dialogContext).pop(); // Close this dialog
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
    double modalMaxHeight = MediaQuery.of(context).size.height * 0.85;

    final supplierNamesMapAsync = ref.watch(supplierNameMapProvider);
    final productDefinitionsAsync =
        ref.watch(productDefinitionNotifierProvider(true)); // For product names
    final currentUserRole = ref.watch(userRoleProvider).asData?.value;

    //Grabs the complete details inside the db, since this is where the freaking line items are stored not on our data models/state
    final poDetailsAsync =
        ref.watch(poDetailsProviderFamily(widget.purchaseOrder.poId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: modalWidth,
        child: poDetailsAsync.when(
          loading: () => SizedBox(
            width: modalWidth,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Loading PO Details..."),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: null,
                      child: Text("Close"),
                    ),
                  ),
                )
              ],
            ),
          ),
          error: (err, stack) => SizedBox(
            width: modalWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error loading PO: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (po) {
            if (po == null) {
              return SizedBox(
                width: modalWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                          'Purchase Order with ID ${widget.purchaseOrder.poId} not found.'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Close"),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Use the fully fetched 'po' object from here onwards
            final supplierNamesMapAsync = ref.watch(supplierNameMapProvider);
            final productDefinitionsAsync =
                ref.watch(productDefinitionNotifierProvider(true));
            bool canAdminTakeAction = currentUserRole == 'admin' &&
                (po.status == PurchaseOrderStatus.PendingApproval ||
                    po.status == PurchaseOrderStatus.Revised);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: _getHeaderColor(po.status),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
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
                        tooltip: "Close",
                      )
                    ],
                  ),
                ),
                Flexible(
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
                        if (po.defaultSupplierID != null)
                          _buildDetailRow(
                              "Default Supplier ID:", po.supplierID.toString()),
                        if (po.defaultReorderQuantity != null)
                          _buildDetailRow("Default Reorder Qty:",
                              po.defaultReorderQuantity.toString()),
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
                                  map[pd.prodDefID!] = pd
                                      .prodDefName; // Use null assertion `!` as it's checked
                                }
                                return map;
                              },
                            );
                            return _buildLineItemsTable(
                                po.items ?? [], productNameMap);
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
                if (canAdminTakeAction)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                              : () => _showRejectionDialog(
                                  po), // Pass the fetched po
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
                                  po,
                                  PurchaseOrderStatus
                                      .Approved), // Pass the fetched po
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
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

  Widget _buildLineItemsTable(
      List<PurchaseOrderItemData> items, Map<String, String> productNameMap) {
    if (items.isEmpty) {
      return const Center(
          child: Text("No items in this purchase order.",
              style: TextStyle(fontFamily: 'NunitoSans', color: Colors.grey)));
    }
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3), // Product Name
        1: IntrinsicColumnWidth(), // Quantity
        2: IntrinsicColumnWidth(), // Unit Cost
        3: IntrinsicColumnWidth(), // Line Total
      },
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color.fromARGB(255, 235, 235, 235)),
          children: [
            Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('Product',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'NunitoSans'))),
            Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('Qty',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'NunitoSans'),
                    textAlign: TextAlign.right)),
            Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('Unit Cost',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'NunitoSans'),
                    textAlign: TextAlign.right)),
            Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('Line Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'NunitoSans'),
                    textAlign: TextAlign.right)),
          ],
        ),
        ...items.map((item) {
          final productName = productNameMap[item.prodDefID] ??
              'ID: ${item.prodDefID.substring(0, 6)}...';
          return TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(productName,
                      style: const TextStyle(
                          fontSize: 12, fontFamily: 'NunitoSans'))),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(item.quantityOrdered.toString(),
                      style: const TextStyle(
                          fontSize: 12, fontFamily: 'NunitoSans'),
                      textAlign: TextAlign.right)),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text('₱${item.unitCostPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 12, fontFamily: 'NunitoSans'),
                      textAlign: TextAlign.right)),
              Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text('₱${item.lineTotalCost.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 12, fontFamily: 'NunitoSans'),
                      textAlign: TextAlign.right)),
            ],
          );
        }).toList(),
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
        return const Color(0xFF00AEEF); // Default
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
