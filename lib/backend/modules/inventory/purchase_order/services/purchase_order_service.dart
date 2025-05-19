// Base Imports
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';

// Potentially import item_serials_service if receiving items updates serials directly here.

const int defaultPOItemsPerPage = 10;

class PurchaseOrderService {
  //Default List for Handling Statuses
  final List<PurchaseOrderStatus> _editableStatuses = const [
    PurchaseOrderStatus.Draft,
    PurchaseOrderStatus.PendingApproval,
    PurchaseOrderStatus.Revised,
  ];

  Future<PurchaseOrderData?> createPurchaseOrder({
    required int supplierID,
    required int createdByEmployee,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? note,
    required List<PurchaseOrderItemData> items,
  }) async {
    try {
      double totalCost =
          items.fold(0.0, (sum, item) => sum + item.lineTotalCost);

      final poDataForInsert = {
        'supplierID': supplierID,
        'createdByEmployee': createdByEmployee,
        'status': PurchaseOrderStatus.PendingApproval.dbValue,
        'orderDate': orderDate.toIso8601String(),
        'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
        'totalEstimatedCost': totalCost,
        'note': note,
      };

      final insertedPO = await supabaseDB
          .from('purchase_order')
          .insert(poDataForInsert)
          .select()
          .single();

      final int newPoId = insertedPO['po_id'];

      final itemsDataForInsert = items
          .map((item) => {
                'purchaseOrderID': newPoId,
                'prodDefID': item.prodDefID,
                'quantityOrdered': item.quantityOrdered,
                'quantityReceived': 0,
                'unitCostPrice': item.unitCostPrice,
                'lineTotalCost': item.lineTotalCost,
              })
          .toList();

      if (itemsDataForInsert.isNotEmpty) {
        await supabaseDB
            .from('purchase_order_items')
            .insert(itemsDataForInsert);
      }

      // Refetch the full PO with items to return
      return getPurchaseOrderById(newPoId);
    } catch (e, st) {
      print('Error creating purchase order: $e\n$st');
      rethrow;
    }
  }

  Future<PurchaseOrderData?> getPurchaseOrderById(int poId) async {
    try {
      final data = await supabaseDB
          .from('purchase_order')
          .select(
              '*, purchase_order_items(*, product_definitions(prodDefName))') // Join with items and product name
          .eq('po_id', poId)
          .maybeSingle();

      if (data == null) return null;
      return PurchaseOrderData.fromJson(data);
    } catch (e, st) {
      print('Error fetching PO by ID $poId: $e\n$st');
      rethrow;
    }
  }

  Future<List<PurchaseOrderData>> fetchPurchaseOrders({
    String? status,
    int? supplierID,
    String sortBy = 'orderDate',
    bool ascending = false, // latest first
    int page = 1,
    int itemsPerPage = defaultPOItemsPerPage,
    String? searchQuery,
  }) async {
    try {
      // In Supabase v2, start with select to build the query
      var query = supabaseDB
          .from('purchase_order')
          .select('*, suppliers(supplierName)'); // Join supplier name

      // Apply filters
      if (status != null) {
        query = query.eq('status', status);
      }
      if (supplierID != null) {
        query = query.eq('supplierID', supplierID);
      }

      // Handle search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        searchQuery = searchQuery.trim();
        print(int.parse(searchQuery));
        query = query.or('po_id.eq.${int.parse(searchQuery)}');
        query = query.or('note.ilike.$searchQuery');
        //query = query.or('suppliers.supplierName.ilike.$searchQuery');
      }

      // Apply pagination
      final offset = (page - 1) * itemsPerPage;

      // Execute query
      final response = await query
          .order(sortBy, ascending: ascending)
          .range(offset, offset + itemsPerPage - 1);

      return response.map((data) => PurchaseOrderData.fromJson(data)).toList();
    } catch (e, st) {
      print('Error fetching purchase orders: $e\n$st');
      return [];
    }
  }

  Future<int> getTotalPurchaseOrderCount({
    String? status,
    int? supplierID,
    String? searchQuery,
  }) async {
    try {
      var totalPOCount = supabaseDB.from('purchase_order').select('po_id');

      if (status != null) {
        totalPOCount = totalPOCount.eq('status', status);
      }
      if (supplierID != null) {
        totalPOCount = totalPOCount.eq('supplierID', supplierID);
      }

      //Improved search queries, basically gi-one line ra. but the same function gihapon bea
      if (searchQuery != null && searchQuery.isNotEmpty) {
        totalPOCount = totalPOCount.or(
            'note.ilike.%$searchQuery%,po_number.ilike.%$searchQuery%,reference.ilike.%$searchQuery%');
      }

      //Count here
      final totalPurchaseOrders = await totalPOCount.count(CountOption.exact);

      return totalPurchaseOrders.count ?? 0;
    } catch (e, st) {
      print('Error fetching PO count: $e\n$st');
      return 0;
    }
  }

  Future<PurchaseOrderData?> updatePurchaseOrderStatus({
    required int poId,
    required PurchaseOrderStatus newStatus,
    int? approvedByAdminId,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.dbValue,
        'updatedDate':
            DateTime.now().toIso8601String(), // Explicitly set update time
      };
      if (newStatus == PurchaseOrderStatus.Approved &&
          approvedByAdminId != null) {
        updates['approvedByAdmin'] = approvedByAdminId;
      }
      if (notes != null) {
        updates['note'] = notes;
      }

      final updatedPO = await supabaseDB
          .from('purchase_order')
          .update(updates)
          .eq('po_id', poId)
          .select()
          .single();
      return PurchaseOrderData.fromJson(updatedPO);
    } catch (e, st) {
      print('Error updating PO status for $poId: $e\n$st');
      rethrow;
    }
  }

// Item Methods

  Future<PurchaseOrderItemData?> updatePurchaseOrderItemQuantityReceived({
    required int poItemId,
    required int quantityReceivedNow,
  }) async {
    try {
      // Fetch current item to update its quantityReceived
      final currentItemData = await supabaseDB
          .from('purchase_order_items')
          .select()
          .eq('purchaseItemID', poItemId)
          .single();

      final currentReceived = currentItemData['quantityReceived'] as int? ?? 0;
      final newQuantityReceived = currentReceived + quantityReceivedNow;
      final quantityOrdered = currentItemData['quantityOrdered'] as int;

      if (newQuantityReceived > quantityOrdered) {
        throw Exception('Cannot receive more items than ordered.');
      }

      final updatedItem = await supabaseDB
          .from('purchase_order_items')
          .update({
            'quantityReceived': newQuantityReceived,
            'updatedAt': DateTime.now().toIso8601String()
          })
          .eq('purchaseItemID', poItemId)
          .select()
          .single();

      final poId = updatedItem['purchaseOrderID'] as int;
      await _checkAndUpdatePOStatusAfterReceiving(poId);

      return PurchaseOrderItemData.fromJson(updatedItem);
    } catch (e, st) {
      print('Error updating PO item quantity received for $poItemId: $e\n$st');
      rethrow;
    }
  }

  // Helper to update PO status based on item receipts
  Future<void> _checkAndUpdatePOStatusAfterReceiving(int poId) async {
    final poItems = await supabaseDB
        .from('purchase_order_items')
        .select('quantityOrdered, quantityReceived')
        .eq('purchaseOrderID', poId);

    bool allReceived = true;
    bool anyReceived = false;

    for (var item in poItems) {
      final ordered = item['quantityOrdered'] as int;
      final received = item['quantityReceived'] as int? ?? 0;
      if (received < ordered) {
        allReceived = false;
      }
      if (received > 0) {
        anyReceived = true;
      }
    }

    PurchaseOrderStatus newStatus;
    if (allReceived) {
      newStatus = PurchaseOrderStatus.Received;
    } else if (anyReceived) {
      newStatus = PurchaseOrderStatus.PartiallyReceived;
    } else {
      return;
    }

    await updatePurchaseOrderStatus(poId: poId, newStatus: newStatus);
  }

  Future<PurchaseOrderItemData?> addLineItemToPO({
    required int poId,
    required String prodDefID,
    required int quantityOrdered,
    required double unitCostPrice,
  }) async {
    final po =
        await getPurchaseOrderById(poId); // Fetches PO with current items
    if (po == null || !_editableStatuses.contains(po.status)) {
      throw Exception(
          "PO $poId cannot be modified in its current status: ${po?.status.dbValue}");
    }

    final lineTotalCost = quantityOrdered * unitCostPrice;
    final newItemJson = {
      'purchaseOrderID': poId,
      'prodDefID': prodDefID,
      'quantityOrdered': quantityOrdered,
      'quantityReceived': 0,
      'unitCostPrice': unitCostPrice,
      'lineTotalCost': lineTotalCost,
    };

    try {
      final insertedItem = await supabaseDB
          .from('purchase_order_items')
          .insert(newItemJson)
          .select() // Select all columns of the inserted item
          .single();

      await _recalculateAndUpdatePOTotalCost(poId);
      return PurchaseOrderItemData.fromJson(insertedItem);
    } catch (e, st) {
      print('Error adding line item to PO $poId: $e\n$st');
      rethrow;
    }
  }

  Future<void> removeLineItemFromPO(int poItemId) async {
    // Fetch the item to get its poId for status check and total recalculation
    final itemMap = await supabaseDB
        .from('purchase_order_items')
        .select('purchaseOrderID')
        .eq('purchaseItemID', poItemId)
        .maybeSingle();

    if (itemMap == null) {
      throw Exception("Purchase Order Item with ID $poItemId not found.");
    }
    final poId = itemMap['purchaseOrderID'] as int;

    final po = await getPurchaseOrderById(poId);
    if (po == null || !_editableStatuses.contains(po.status)) {
      throw Exception(
          "PO $poId cannot be modified in its current status: ${po?.status.dbValue}");
    }

    try {
      await supabaseDB
          .from('purchase_order_items')
          .delete()
          .eq('purchaseItemID', poItemId);

      await _recalculateAndUpdatePOTotalCost(poId);
    } catch (e, st) {
      print('Error removing line item $poItemId from PO $poId: $e\n$st');
      rethrow;
    }
  }

  Future<PurchaseOrderItemData?> updateLineItemOnPO({
    required int poItemId,
    int? newQuantityOrdered,
    double? newUnitCostPrice,
  }) async {
    final currentItemMap = await supabaseDB
        .from('purchase_order_items')
        .select('purchaseOrderID, quantityOrdered, unitCostPrice')
        .eq('purchaseItemID', poItemId)
        .maybeSingle();

    if (currentItemMap == null) {
      throw Exception(
          "Purchase Order Item with ID $poItemId not found for update.");
    }
    final poId = currentItemMap['purchaseOrderID'] as int;

    final po = await getPurchaseOrderById(poId);
    if (po == null || !_editableStatuses.contains(po.status)) {
      throw Exception(
          "PO $poId cannot be modified in its current status: ${po?.status.dbValue}");
    }

    final updates = <String, dynamic>{};
    int quantity =
        newQuantityOrdered ?? currentItemMap['quantityOrdered'] as int;
    double unitCost =
        newUnitCostPrice ?? currentItemMap['unitCostPrice'] as double;

    if (newQuantityOrdered != null) {
      updates['quantityOrdered'] = newQuantityOrdered;
    }
    if (newUnitCostPrice != null) updates['unitCostPrice'] = newUnitCostPrice;

    updates['lineTotalCost'] =
        quantity * unitCost; // Recalculate the total coast

    if (updates.length == 1 && updates.containsKey('lineTotalCost')) {
      return PurchaseOrderItemData.fromJson(
          currentItemMap); // Return current item if no actual data changed
    }

    try {
      final updatedItem = await supabaseDB
          .from('purchase_order_items')
          .update(updates)
          .eq('purchaseItemID', poItemId)
          .select()
          .single();

      await _recalculateAndUpdatePOTotalCost(poId);
      return PurchaseOrderItemData.fromJson(updatedItem);
    } catch (e, st) {
      print('Error updating line item $poItemId on PO $poId: $e\n$st');
      rethrow;
    }
  }

  Future<PurchaseOrderItemData?> getPurchaseOrderItemById(int poItemId) async {
    try {
      final data = await supabaseDB
          .from('purchase_order_items')
          .select(
              '*, product_definitions(prodDefName)') // Optionally join product name
          .eq('purchaseItemID', poItemId)
          .maybeSingle();
      if (data == null) return null;
      return PurchaseOrderItemData.fromJson(data);
    } catch (e, st) {
      print('Error fetching PO Item by ID $poItemId: $e\n$st');
      return null;
    }
  }

  // Helper to recalculate and update PO's total cost
  Future<void> _recalculateAndUpdatePOTotalCost(int poId) async {
    final items = await supabaseDB
        .from('purchase_order_items')
        .select('lineTotalCost')
        .eq('purchaseOrderID', poId);

    double newTotalCost = items.fold(
        0.0,
        (sum, item) =>
            sum + ((item['lineTotalCost'] as num?)?.toDouble() ?? 0.0));

    await supabaseDB.from('purchase_order').update({
      'totalEstimatedCost':
          newTotalCost /*, 'updatedDate': DateTime.now().toIso8601String() - DB handles this */
    }).eq('po_id', poId);
  }
}
