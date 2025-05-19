// lib/view/inventory/return_orders/modals/view_return_order_detail_modal.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/view/inventory/return_orders/modals/record_replacement_modal.dart';

// Notifier for a single Return Order's details
final returnOrderDetailNotifierProvider = StateNotifierProvider.autoDispose
    .family<ReturnOrderDetailNotifier, AsyncValue<ReturnOrderData?>, int>(
  (ref, roId) => ReturnOrderDetailNotifier(ref, roId),
);

class ReturnOrderDetailNotifier
    extends StateNotifier<AsyncValue<ReturnOrderData?>> {
  final AutoDisposeRef _ref; // Changed to AutoDisposeRef for families
  final int _roId;
  ReturnOrderService get _service => _ref.read(returnOrderServiceProvider);

  ReturnOrderDetailNotifier(this._ref, this._roId)
      : super(const AsyncLoading()) {
    _fetchReturnOrderDetails();
  }

  Future<void> _fetchReturnOrderDetails() async {
    state = const AsyncLoading();
    try {
      final roData = await _service.getReturnOrderById(_roId);
      if (mounted) {
        state = AsyncData(roData?.copyWith(
            isLoading: false)); // Ensure isLoading is false initially
      }
    } catch (e, st) {
      print("Error fetching RO details for $_roId: $e\n$st");
      if (mounted) {
        state = AsyncError(e, st);
      }
    }
  }

  Future<void> updateStatus(ReturnOrderStatus newStatus,
      {String? notes}) async {
    final currentDataValue = state.asData?.value;
    if (currentDataValue == null) return;

    state = AsyncData(currentDataValue.copyWith(isLoading: true));

    final currentUserAuthId = supabaseDB.auth.currentUser?.id;
    int? adminId;
    if (currentUserAuthId != null) {
      try {
        final empRecord = await supabaseDB
            .from('employee')
            .select('employeeID')
            .eq('userID', currentUserAuthId)
            .eq('isAdmin', true)
            .maybeSingle();
        adminId = empRecord?['employeeID'] as int?;
      } catch (e) {
        print("Error fetching admin ID for status update: $e");
        // Handle error, maybe show toast from UI
      }
    }

    try {
      final updatedRO = await _service.updateReturnOrderStatus(
        roId: _roId,
        newStatus: newStatus,
        adminId: adminId,
        notes: notes,
      );
      if (mounted) {
        state = AsyncData(updatedRO?.copyWith(isLoading: false));
      }
      _ref.read(returnOrderListNotifierProvider.notifier).refresh();
    } catch (e, st) {
      print("Error updating RO status in notifier: $e\n$st");
      if (mounted) {
        state = AsyncError(e, st).copyWithPrevious(
            AsyncData(currentDataValue.copyWith(isLoading: false)));
      }
    }
  }

  Future<void> cancelRO(int cancellingEmployeeId, String? reason) async {
    final currentDataValue = state.asData?.value;
    if (currentDataValue == null) return;
    state = AsyncData(currentDataValue.copyWith(isLoading: true));
    try {
      final updatedRO = await _service.cancelReturnOrder(
          roId: _roId,
          cancellingEmployeeId: cancellingEmployeeId,
          cancellationReason: reason);
      if (mounted) {
        state = AsyncData(updatedRO?.copyWith(isLoading: false));
      }
      _ref.read(returnOrderListNotifierProvider.notifier).refresh();
    } catch (e, st) {
      if (mounted) {
        state = AsyncError(e, st).copyWithPrevious(
            AsyncData(currentDataValue.copyWith(isLoading: false)));
      }
    }
  }

  Future<void> receiveReplacement({
    required int returnOrderItemId,
    required String newSerialNumber,
    required DateTime dateReceived,
    required String originalReturnedProdDefID,
    required int originalSupplierID,
    double? actualCostOfReplacement,
  }) async {
    final currentDataValue = state.asData?.value;
    if (currentDataValue == null) return;
    state = AsyncData(currentDataValue.copyWith(isLoading: true));

    final currentUserAuthId = supabaseDB.auth.currentUser?.id;
    int? receivingEmployeeId;
    if (currentUserAuthId != null) {
      try {
        final empRecord = await supabaseDB
            .from('employee')
            .select('employeeID')
            .eq('userID', currentUserAuthId)
            .maybeSingle();
        receivingEmployeeId = empRecord?['employeeID'] as int?;
      } catch (e) {
        print("Error fetching receiving employee ID: $e");
        if (mounted) {
          state = AsyncError(
                  "Could not identify receiving employee.", StackTrace.current)
              .copyWithPrevious(
                  AsyncData(currentDataValue.copyWith(isLoading: false)));
        }
        return;
      }
    }
    if (receivingEmployeeId == null) {
      if (mounted) {
        state = AsyncError("Receiving employee could not be identified.",
                StackTrace.current)
            .copyWithPrevious(
                AsyncData(currentDataValue.copyWith(isLoading: false)));
      }
      return;
    }

    try {
      await _service.receiveReplacementForItem(
        returnOrderItemId: returnOrderItemId,
        newSerialNumber: newSerialNumber,
        dateReceived: dateReceived,
        receivingEmployeeId: receivingEmployeeId,
        originalReturnedProdDefID: originalReturnedProdDefID,
        originalSupplierID: originalSupplierID,
        actualCostOfReplacement: actualCostOfReplacement,
      );
      await _fetchReturnOrderDetails(); // Re-fetch to update items and potentially RO status
      _ref.read(returnOrderListNotifierProvider.notifier).refresh();
    } catch (e, st) {
      if (mounted) {
        state = AsyncError(e, st).copyWithPrevious(
            AsyncData(currentDataValue.copyWith(isLoading: false)));
      }
    }
  }

  Future<void> refresh() async {
    await _fetchReturnOrderDetails();
  }
}

class ViewReturnOrderDetailModal extends ConsumerWidget {
  final int roId;

  const ViewReturnOrderDetailModal({super.key, required this.roId});

  void _showRejectionDialog(BuildContext context, WidgetRef ref,
      ReturnOrderData currentRO, bool isProcessing) {
    final rejectionReasonController = TextEditingController(
        text: currentRO.notes?.contains("Rejected:") ?? false
            ? currentRO.notes!.split("Rejected:").last.trim()
            : "");

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Return Order'),
        content: Form(
          child: TextFormField(
            controller: rejectionReasonController,
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
            onPressed: isProcessing
                ? null
                : () async {
                    Navigator.of(dialogContext).pop();
                    String reason = rejectionReasonController.text.trim();
                    final currentUserAuthId = supabaseDB.auth.currentUser?.id;
                    int? adminId;
                    if (currentUserAuthId != null) {
                      try {
                        final empRecord = await supabaseDB
                            .from('employee')
                            .select('employeeID')
                            .eq('userID', currentUserAuthId)
                            .eq('isAdmin', true)
                            .maybeSingle();
                        adminId = empRecord?['employeeID'] as int?;
                      } catch (e) {
                        ToastManager().showToast(
                            context,
                            "Error fetching admin details for rejection: $e",
                            Colors.red);
                        return;
                      }
                    }
                    if (adminId == null) {
                      ToastManager().showToast(
                          context,
                          "Admin privileges required or employee not found for rejection.",
                          Colors.red);
                      return;
                    }

                    ref
                        .read(returnOrderDetailNotifierProvider(roId).notifier)
                        .cancelRO(
                            adminId,
                            reason.isEmpty
                                ? "Rejected by Admin"
                                : "Rejected: $reason");
                  },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Confirm Rejection',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecordReplacementModal(
    BuildContext context,
    WidgetRef ref,
    ReturnOrderItemData roItem,
    ReturnOrderData currentRO,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RecordReplacementModal(
        productName: roItem.productName ?? 'Item',
        originalSerial: roItem.returnedSerialID,
      ),
    );

    if (result != null) {
      final String newSerial = result['newSerialNumber'];
      final DateTime dateReceived = result['dateReceived'];
      final double? cost = result['cost'];

      try {
        await ref
            .read(returnOrderDetailNotifierProvider(roId).notifier)
            .receiveReplacement(
              returnOrderItemId: roItem.returnOrderItemID,
              newSerialNumber: newSerial,
              dateReceived: dateReceived,
              originalReturnedProdDefID: roItem.prodDefID,
              originalSupplierID: currentRO.supplierID,
              actualCostOfReplacement: cost,
            );
        ToastManager().showToast(
            context,
            "Replacement for ${roItem.returnedSerialID} recorded.",
            Colors.green);
      } catch (e) {
        ToastManager()
            .showToast(context, "Failed to record replacement: $e", Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    double modalWidth = screenWidth > 800 ? 750 : screenWidth * 0.9;
    final roDetailAsync = ref.watch(returnOrderDetailNotifierProvider(roId));
    final currentUserRole = ref.watch(userRoleProvider).asData?.value;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: modalWidth,
        height: MediaQuery.of(context).size.height * 0.8,
        child: roDetailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(
              child: Text("Error loading RO: $err",
                  style: const TextStyle(color: Colors.red))),
          data: (roData) {
            if (roData == null) {
              return const Center(child: Text("Return Order not found."));
            }
            final ro = roData; // Use the data directly
            final bool isProcessing =
                ro.isLoading; // Get loading state from the data

            bool canAdminApproveReject = currentUserRole == 'admin' &&
                ro.status == ReturnOrderStatus.PendingApproval;
            bool canMarkSent =
                (currentUserRole == 'admin' || currentUserRole == 'employee') &&
                    ro.status == ReturnOrderStatus.Approved;
            bool canReceiveReplacement =
                (currentUserRole == 'admin' || currentUserRole == 'employee') &&
                    (ro.status == ReturnOrderStatus.ItemsSentToSupplier ||
                        ro.status == ReturnOrderStatus.AwaitingReplacement ||
                        ro.status == ReturnOrderStatus.Approved);
            bool canMarkCompleted = currentUserRole == 'admin' &&
                ro.status == ReturnOrderStatus.ReplacementReceived;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ro.status),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text('RO ID: ${ro.returnOrderID} - Details',
                            style: const TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: isProcessing
                            ? null
                            : () => Navigator.of(context).pop(false),
                        tooltip: "Close",
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow("Current Status:", null,
                            valueWidget: _statusChip(ro.status)),
                        _buildDetailRow(
                            "Original PO ID:", ro.purchaseOrderID.toString()),
                        _buildDetailRow("Supplier:",
                            ro.supplierName ?? "ID: ${ro.supplierID}"),
                        _buildDetailRow(
                            "Return Date:",
                            DateFormat('MMMM dd, yyyy')
                                .format(ro.returnDate.toLocal())),
                        _buildDetailRow("Created By:",
                            ro.employeeName ?? "ID: ${ro.employeeID}"),
                        if (ro.adminID != null)
                          _buildDetailRow("Actioned By Admin:",
                              ro.adminName ?? "ID: ${ro.adminID}"),
                        if (ro.adminActionDate != null)
                          _buildDetailRow(
                              "Admin Action Date:",
                              DateFormat('MMMM dd, yyyy HH:mm')
                                  .format(ro.adminActionDate!.toLocal())),
                        if (ro.notes != null && ro.notes!.isNotEmpty)
                          _buildDetailRow("Overall Notes:", ro.notes!),
                        const SizedBox(height: 15),
                        const Divider(),
                        const Text("Returned Items",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'NunitoSans')),
                        const SizedBox(height: 8),
                        _buildLineItemsList(
                            context, ref, ro, canReceiveReplacement),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      TextButton(
                          onPressed: isProcessing
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: const Text('Close')),
                      if (canAdminApproveReject) ...[
                        ElevatedButton.icon(
                          icon: isProcessing
                              ? const SizedBox.shrink()
                              : const Icon(Icons.cancel_outlined, size: 16),
                          label: isProcessing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Reject'),
                          onPressed: isProcessing
                              ? null
                              : () => _showRejectionDialog(
                                  context, ref, ro, isProcessing),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white),
                        ),
                        ElevatedButton.icon(
                          icon: isProcessing
                              ? const SizedBox.shrink()
                              : const Icon(Icons.check_circle_outline,
                                  size: 16),
                          label: isProcessing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Approve'),
                          onPressed: isProcessing
                              ? null
                              : () => ref
                                  .read(returnOrderDetailNotifierProvider(roId)
                                      .notifier)
                                  .updateStatus(ReturnOrderStatus.Approved),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white),
                        ),
                      ],
                      if (canMarkSent)
                        ElevatedButton.icon(
                          icon: isProcessing
                              ? const SizedBox.shrink()
                              : const Icon(Icons.send_outlined, size: 16),
                          label: isProcessing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Mark Sent to Supplier'),
                          onPressed: isProcessing
                              ? null
                              : () => ref
                                  .read(returnOrderDetailNotifierProvider(roId)
                                      .notifier)
                                  .updateStatus(
                                      ReturnOrderStatus.ItemsSentToSupplier),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white),
                        ),
                      if (canMarkCompleted)
                        ElevatedButton.icon(
                          icon: isProcessing
                              ? const SizedBox.shrink()
                              : const Icon(Icons.task_alt, size: 16),
                          label: isProcessing
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('Mark RO Completed'),
                          onPressed: isProcessing
                              ? null
                              : () => ref
                                  .read(returnOrderDetailNotifierProvider(roId)
                                      .notifier)
                                  .updateStatus(ReturnOrderStatus.Completed),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white),
                        ),
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

  Widget _buildDetailRow(String label, String? value, {Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  Widget _buildLineItemsList(BuildContext context, WidgetRef ref,
      ReturnOrderData ro, bool canReceiveReplacement) {
    final items = ro.items ?? [];
    if (items.isEmpty) {
      return const Center(
          child: Text("No items in this return order.",
              style: TextStyle(fontFamily: 'NunitoSans', color: Colors.grey)));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        bool itemAwaitingReplacement = (item.itemStatus.toLowerCase() ==
                    "awaitingreplacement" ||
                (ro.status == ReturnOrderStatus.Approved &&
                    item.itemStatus.toLowerCase() ==
                        "pendingapproval") || // Can receive if RO is approved and item is pending
                (ro.status == ReturnOrderStatus.ItemsSentToSupplier &&
                    item.itemStatus.toLowerCase() ==
                        "awaitingreplacement") // Standard case
            ) &&
            item.replacementSerialID == null;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    item.productName ??
                        "Product ID: ${item.prodDefID.substring(0, 6)}...",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12.5)),
                _buildModalInfoRow("Returned Serial:", item.returnedSerialID,
                    isSubtle: true),
                if (item.reasonForReturn != null &&
                    item.reasonForReturn!.isNotEmpty)
                  _buildModalInfoRow("Item Reason:", item.reasonForReturn!,
                      isSubtle: true),
                _buildModalInfoRow("Item Status:", item.itemStatus,
                    isSubtle: true),
                if (item.replacementSerialID != null)
                  _buildModalInfoRow(
                      "Replacement Serial:", item.replacementSerialID!,
                      isSubtle: true),
                if (canReceiveReplacement && itemAwaitingReplacement)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showRecordReplacementModal(context, ref, item, ro),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            textStyle: const TextStyle(fontSize: 11)),
                        child: const Text("Record Replacement"),
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalInfoRow(String label, String value,
      {bool isSubtle = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isSubtle ? FontWeight.normal : FontWeight.w600,
                fontFamily: 'NunitoSans',
                fontSize: 11,
                color: isSubtle ? Colors.grey[700] : Colors.black87,
              )),
          const SizedBox(width: 6),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontSize: 11,
                      color: isSubtle ? Colors.grey[800] : Colors.black))),
        ],
      ),
    );
  }

  Color _getStatusColor(ReturnOrderStatus status) {
    switch (status) {
      case ReturnOrderStatus.PendingApproval:
        return Colors.orange.shade700;
      case ReturnOrderStatus.Approved:
        return Colors.blue.shade700;
      case ReturnOrderStatus.ItemsSentToSupplier:
        return Colors.cyan.shade700;
      case ReturnOrderStatus.AwaitingReplacement:
        return Colors.deepPurple.shade400;
      case ReturnOrderStatus.ReplacementReceived:
        return Colors.teal.shade400;
      case ReturnOrderStatus.Completed:
        return Colors.green.shade700;
      case ReturnOrderStatus.Cancelled:
      case ReturnOrderStatus.Rejected:
        return Colors.red.shade700;
      default:
        return Colors.black54;
    }
  }

  Widget _statusChip(ReturnOrderStatus status) {
    Color chipColor = _getStatusColor(status);
    String chipText = status.name;
    Color textColor =
        (chipColor.computeLuminance() > 0.5) ? Colors.black87 : Colors.white;

    return Chip(
      label: Text(chipText,
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
