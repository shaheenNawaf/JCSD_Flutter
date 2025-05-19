// lib/backend/modules/inventory/return_orders/return_order_service.dart

import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For FetchOptions and CountOption
// import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart'; // Uncomment when ready for audit logs

const int defaultReturnOrderItemsPerPage = 10;

class ReturnOrderService {
  final SerialitemService _serialItemService = SerialitemService();
  // final AuditLogService _auditLogService = AuditLogService(); // Uncomment if used

  /// Base select query for fetching detailed Return Order with its relations.
  static const String _baseReturnOrderSelectWithRelations = '''
    returnOrderID, 
    purchaseOrderID, 
    employeeID, 
    returnDate, 
    status, 
    adminActionDate, 
    notes, 
    createdDate, 
    adminID, 
    supplierID,
    purchase_order!inner (po_id, orderDate), 
    suppliers!inner (supplierName),
    employee_creator:employeeID!inner (
        userID, 
        accounts!inner(firstName, lastName)
    ),
    employee_admin:adminID (
        userID, 
        accounts!inner(firstName, lastName)
    ),
    return_order_items (
      *,
      product_definitions!inner (prodDefName),
      original_serial:returnedSerialID!inner(serialNumber, status, prodDefID), 
      replacement_serial:replacementSerialID (serialNumber, status, prodDefID)
    )
  ''';

  /// Base select query for fetching a list of Return Orders with essential relations.
  static const String _baseReturnOrderListSelect = '''
    returnOrderID, 
    purchaseOrderID, 
    employeeID, 
    returnDate, 
    status, 
    adminID, 
    supplierID, 
    createdDate,
    suppliers!inner (supplierName),
    employee_creator:employeeID!inner (
        userID, 
        accounts!inner(firstName, lastName)
    )
  ''';

  Future<ReturnOrderData?> getReturnOrderById(int roId) async {
    try {
      final response = await supabaseDB
          .from('return_order')
          .select(_baseReturnOrderSelectWithRelations)
          .eq('returnOrderID', roId)
          .maybeSingle();

      if (response == null) return null;
      return ReturnOrderData.fromJson(response);
    } catch (e, st) {
      print('Error fetching Return Order by ID $roId: $e\n$st');
      rethrow;
    }
  }

  Future<List<ReturnOrderData>> fetchReturnOrders({
    String? searchQuery,
    ReturnOrderStatus? statusFilter,
    int? supplierIdFilter,
    int? purchaseOrderIdFilter,
    String sortBy = 'returnDate',
    bool ascending = false,
    int page = 1,
    int itemsPerPage = defaultReturnOrderItemsPerPage,
  }) async {
    try {
      var query =
          supabaseDB.from('return_order').select(_baseReturnOrderListSelect);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';
        query = query.or('notes.ilike.$searchTerm,'
            'returnOrderID::text.ilike.$searchTerm,'
            'purchaseOrderID::text.ilike.$searchTerm,'
            'suppliers.supplierName.ilike.$searchTerm');
      }
      if (statusFilter != null && statusFilter != ReturnOrderStatus.Unknown) {
        query = query.eq('status', statusFilter.dbValue);
      }
      if (supplierIdFilter != null) {
        query = query.eq('supplierID', supplierIdFilter);
      }
      if (purchaseOrderIdFilter != null) {
        query = query.eq('purchaseOrderID', purchaseOrderIdFilter);
      }

      final offset = (page - 1) * itemsPerPage;
      final results = await query
          .order(sortBy, ascending: ascending)
          .range(offset, offset + itemsPerPage - 1);

      return results.map((data) => ReturnOrderData.fromJson(data)).toList();
    } catch (e, st) {
      print('Error fetching Return Orders: $e\n$st');
      rethrow;
    }
  }

  Future<int> getTotalReturnOrderCount({
    String? searchQuery,
    ReturnOrderStatus? statusFilter,
    int? supplierIdFilter,
    int? purchaseOrderIdFilter,
  }) async {
    try {
      // Start with the base query
      var query = supabaseDB.from('return_order').select();

      // Apply filters first
      if (statusFilter != null && statusFilter != ReturnOrderStatus.Unknown) {
        query = query.eq('status', statusFilter.dbValue);
      }
      if (supplierIdFilter != null) {
        query = query.eq('supplierID', supplierIdFilter);
      }
      if (purchaseOrderIdFilter != null) {
        query = query.eq('purchaseOrderID', purchaseOrderIdFilter);
      }

      // Handle search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';

        // Determine if search might involve supplier names
        bool searchMightInvolveJoins =
            searchQuery.contains(RegExp(r'[a-zA-Z]'));

        if (searchMightInvolveJoins) {
          // For search involving supplier names, use a more complex query
          return await supabaseDB
              .rpc('count_return_orders_with_search', params: {
                'search_term': searchTerm,
                'status_filter': statusFilter?.dbValue,
                'supplier_id_filter': supplierIdFilter,
                'purchase_order_id_filter': purchaseOrderIdFilter,
              })
              .single()
              .then((response) => response['count'] as int);
        } else {
          // For ID-based searches, use filter builder with or conditions
          query = query.or(
              'returnOrderID.ilike.$searchTerm,purchaseOrderID.ilike.$searchTerm,notes.ilike.$searchTerm');
        }
      }

      // Get count
      final response = await query.count();
      return response.count;
    } catch (e, st) {
      print('Error fetching Return Order count: $e\n$st');
      return 0;
    }
  }

  Future<ReturnOrderData?> createReturnOrder({
    required int purchaseOrderId,
    required int supplierId,
    required int createdByEmployeeId,
    required DateTime returnDate,
    required String reasonForReturn,
    String? notes,
    required List<
            ({String returnedSerialID, String prodDefID, String? itemReason})>
        itemsToReturn,
  }) async {
    if (itemsToReturn.isEmpty) {
      throw ArgumentError("Cannot create a return order with no items.");
    }

    final roDataForInsert = {
      'purchaseOrderID': purchaseOrderId,
      'supplierID': supplierId,
      'employeeID': createdByEmployeeId,
      'returnDate': returnDate.toIso8601String(),
      'status': ReturnOrderStatus.PendingApproval.dbValue,
      'reason_for_return': reasonForReturn,
      'notes': notes,
      // createdDate and updatedDate will use DB defaults
    };

    try {
      final insertedRO = await supabaseDB
          .from('return_order')
          .insert(roDataForInsert)
          .select() // Select all columns of the newly inserted RO
          .single();

      final int newRoId = insertedRO['returnOrderID'] as int;

      final roItemsDataForInsert = itemsToReturn
          .map((item) => {
                'returnOrderID': newRoId,
                'returnedSerialID': item.returnedSerialID,
                'prodDefID': item.prodDefID, // Ensure this is the UUID string
                'reasonForReturn': item.itemReason,
                'itemStatus':
                    'PendingApproval', // Initial status for the return item line
                // replacementSerialID is null on insert
              })
          .toList();

      if (roItemsDataForInsert.isNotEmpty) {
        await supabaseDB
            .from('return_order_items')
            .insert(roItemsDataForInsert);
      }

      for (var item in itemsToReturn) {
        await _serialItemService.updateSerializedItemStatus(
            item.returnedSerialID, 'PendingReturnApproval');
      }

      // _auditLogService.addReturnOrderCreation(roId: newRoId, employeeId: createdByEmployeeId);
      return getReturnOrderById(newRoId);
    } catch (e, st) {
      print('Error creating Return Order: $e\n$st');
      rethrow;
    }
  }

  Future<ReturnOrderData?> updateReturnOrderDetails({
    required int roId,
    DateTime? newReturnDate,
    String? newNotes,
    String? newReasonForReturn,
  }) async {
    final ReturnOrderData? currentRO = await getReturnOrderById(roId);
    if (currentRO == null) throw Exception("Return Order $roId not found.");

    if (currentRO.status != ReturnOrderStatus.PendingApproval &&
        currentRO.status != ReturnOrderStatus.Approved) {
      throw Exception(
          "Return Order cannot be modified in its current status: ${currentRO.status.dbValue}");
    }

    final updates = <String, dynamic>{
      'updatedDate': DateTime.now().toUtc().toIso8601String(),
    };
    if (newReturnDate != null)
      updates['returnDate'] = newReturnDate.toIso8601String();
    if (newNotes != null) updates['notes'] = newNotes;
    if (newReasonForReturn != null)
      updates['reason_for_return'] = newReasonForReturn;

    if (updates.length == 1) return currentRO; // Only updatedDate changed

    try {
      await supabaseDB
          .from('return_order')
          .update(updates)
          .eq('returnOrderID', roId);
      // _auditLogService.addReturnOrderUpdate(roId: roId, employeeId: /* current user's emp ID */);
      return getReturnOrderById(roId);
    } catch (e, st) {
      print('Error updating Return Order $roId details: $e\n$st');
      rethrow;
    }
  }

  Future<ReturnOrderData?> updateReturnOrderStatus({
    required int roId,
    required ReturnOrderStatus newStatus,
    int? adminId,
    String? notes,
  }) async {
    final ReturnOrderData? currentRO = await getReturnOrderById(roId);
    if (currentRO == null) throw Exception("Return Order $roId not found.");

    final updates = <String, dynamic>{
      'status': newStatus.dbValue,
      'updatedDate': DateTime.now().toUtc().toIso8601String(),
    };

    if (adminId != null) updates['adminID'] = adminId;
    if (notes != null) updates['notes'] = notes;
    if ([
      ReturnOrderStatus.Approved,
      ReturnOrderStatus.Cancelled,
      ReturnOrderStatus.Completed
    ].contains(newStatus)) {
      updates['adminActionDate'] = DateTime.now().toUtc().toIso8601String();
    }

    try {
      await supabaseDB
          .from('return_order')
          .update(updates)
          .eq('returnOrderID', roId);

      if (newStatus == ReturnOrderStatus.Approved) {
        for (var item in currentRO.items ?? []) {
          await _serialItemService.updateSerializedItemStatus(
              item.returnedSerialID, 'ReturnedToSupplier');
          await supabaseDB.from('return_order_items').update({
            'itemStatus': 'AwaitingReplacement',
            'updatedAt': DateTime.now().toUtc().toIso8601String()
          }).eq('returnOrderItemID', item.returnOrderItemID);
        }
      } else if (newStatus == ReturnOrderStatus.Cancelled) {
        // Rejected maps to Cancelled
        for (var item in currentRO.items ?? []) {
          await _serialItemService.updateSerializedItemStatus(
              item.returnedSerialID, 'Available'); // Or previous status
          await supabaseDB.from('return_order_items').update({
            'itemStatus': 'Cancelled',
            'updatedAt': DateTime.now().toUtc().toIso8601String()
          }).eq('returnOrderItemID', item.returnOrderItemID);
        }
      }
      // _auditLogService.addReturnOrderStatusChange(roId: roId, newStatus: newStatus.dbValue, employeeId: adminId ?? currentRO.employeeID);
      return getReturnOrderById(roId);
    } catch (e, st) {
      print('Error updating Return Order $roId status to $newStatus: $e\n$st');
      rethrow;
    }
  }

  Future<ReturnOrderData?> cancelReturnOrder({
    required int roId,
    required int cancellingEmployeeId,
    String? cancellationReason,
  }) async {
    final ReturnOrderData? currentRO = await getReturnOrderById(roId);
    if (currentRO == null) throw Exception("Return Order $roId not found.");

    final cancellableStatuses = [
      ReturnOrderStatus.PendingApproval,
      ReturnOrderStatus.Approved,
    ];
    if (!cancellableStatuses.contains(currentRO.status)) {
      throw Exception(
          "Return Order cannot be cancelled in its current status: ${currentRO.status.dbValue}");
    }

    String finalNotes = currentRO.notes ?? "";
    if (cancellationReason != null && cancellationReason.isNotEmpty) {
      finalNotes =
          "${finalNotes.isNotEmpty ? "$finalNotes\n" : ""}Cancelled by Employee ID $cancellingEmployeeId: $cancellationReason";
    } else {
      finalNotes =
          "${finalNotes.isNotEmpty ? "$finalNotes\n" : ""}Cancelled by Employee ID $cancellingEmployeeId.";
    }

    return updateReturnOrderStatus(
      roId: roId,
      newStatus: ReturnOrderStatus.Cancelled,
      adminId: cancellingEmployeeId,
      notes: finalNotes,
    );
  }

  Future<ReturnOrderItemData?> receiveReplacementForItem({
    required int returnOrderItemId,
    required String newSerialNumber,
    required DateTime dateReceived,
    required int receivingEmployeeId,
    required String originalReturnedProdDefID,
    required int originalSupplierID,
    double? actualCostOfReplacement,
  }) async {
    try {
      final newReplacementItem = SerializedItem(
        serialNumber: newSerialNumber,
        prodDefID: originalReturnedProdDefID,
        supplierID: originalSupplierID,
        costPrice: actualCostOfReplacement ?? 0.00,
        purchaseDate: dateReceived,
        status: 'Available',
        employeeID: receivingEmployeeId, // Employee who processed the receipt
        notes: 'Replacement for returned item (ROI ID: $returnOrderItemId)',
      );
      await _serialItemService.addSerializedItem(newReplacementItem);

      final updatedRoiData = await supabaseDB
          .from('return_order_items')
          .update({
            'replacementSerialID': newSerialNumber,
            'replacementReceivedDate': dateReceived.toIso8601String(),
            'itemStatus': 'ReplacementReceived',
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('returnOrderItemID', returnOrderItemId)
          .select(
              _baseReturnOrderItemSelectWithProductName) // Use a consistent select
          .single();

      final int roId = updatedRoiData['returnOrderID'] as int;
      await _checkAndUpdateROStatusAfterAllItemsReplaced(roId);

      // _auditLogService.addReplacementReceived(roiId: returnOrderItemId, newSerial: newSerialNumber, employeeId: receivingEmployeeId);
      return ReturnOrderItemData.fromJson(updatedRoiData);
    } catch (e, st) {
      print('Error receiving replacement for ROI $returnOrderItemId: $e\n$st');
      rethrow;
    }
  }

  /// Helper for selecting return_order_item data with product name
  static const String _baseReturnOrderItemSelectWithProductName = '''
    *, product_definitions!inner(prodDefName)
  ''';

  Future<ReturnOrderItemData?> updateReturnOrderItemDetails({
    required int returnOrderItemId,
    String? newReasonForItemReturn,
    String? newItemStatus,
  }) async {
    final Map<String, dynamic>? currentItemMap = await supabaseDB
        .from('return_order_items')
        .select('*, return_order!inner(status)')
        .eq('returnOrderItemID', returnOrderItemId)
        .maybeSingle();

    if (currentItemMap == null)
      throw Exception("Return Order Item $returnOrderItemId not found.");

    final String parentRoStatusString =
        currentItemMap['return_order']['status'] as String;
    final ReturnOrderStatus parentRoStatus =
        ReturnOrderStatusExtension.fromDbValue(parentRoStatusString);

    if (parentRoStatus != ReturnOrderStatus.PendingApproval &&
        parentRoStatus != ReturnOrderStatus.Approved) {
      throw Exception(
          "Return Order Item cannot be modified when parent RO status is: ${parentRoStatus.dbValue}");
    }

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (newReasonForItemReturn != null)
      updates['reasonForReturn'] = newReasonForItemReturn;
    if (newItemStatus != null) updates['itemStatus'] = newItemStatus;

    if (updates.length == 1) {
      // Only updatedAt changed, refetch to ensure consistency but no real data change
      final refetchedData = await supabaseDB
          .from('return_order_items')
          .select(_baseReturnOrderItemSelectWithProductName)
          .eq('returnOrderItemID', returnOrderItemId)
          .single();
      return ReturnOrderItemData.fromJson(refetchedData);
    }

    try {
      final updatedData = await supabaseDB
          .from('return_order_items')
          .update(updates)
          .eq('returnOrderItemID', returnOrderItemId)
          .select(_baseReturnOrderItemSelectWithProductName)
          .single();
      // _auditLogService.addReturnOrderItemUpdate(roiId: returnOrderItemId, employeeId: /* current user's emp ID */);
      return ReturnOrderItemData.fromJson(updatedData);
    } catch (e, st) {
      print('Error updating Return Order Item $returnOrderItemId: $e\n$st');
      rethrow;
    }
  }

  Future<void> _checkAndUpdateROStatusAfterAllItemsReplaced(int roId) async {
    final roItems = await supabaseDB
        .from('return_order_items')
        .select('itemStatus')
        .eq('returnOrderID', roId);

    if (roItems.isEmpty) return; // No items to check

    bool allReplacementsProcessed = roItems.every((item) =>
        item['itemStatus'] == 'ReplacementReceived' ||
        item['itemStatus'] == 'Cancelled');

    if (allReplacementsProcessed) {
      // Check if there's at least one 'ReplacementReceived' to move to ReplacementReceived vs Completed
      bool anyActuallyReplaced =
          roItems.any((item) => item['itemStatus'] == 'ReplacementReceived');
      if (anyActuallyReplaced) {
        await updateReturnOrderStatus(
            roId: roId, newStatus: ReturnOrderStatus.ReplacementReceived);
      } else {
        // If all were cancelled, perhaps move to Cancelled or a specific "Closed-NoReplacements" status
        await updateReturnOrderStatus(
            roId: roId, newStatus: ReturnOrderStatus.Completed); // Or Cancelled
      }
    }
    // If not all are processed, the RO status might remain as is or be Partial based on other logic
  }
}
