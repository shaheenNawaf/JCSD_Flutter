import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_item_status.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// '''
//           id, created_at, purchase_order_id, employee_id, return_date, status, admin_id, admin_action_date, notes, supplier_id,
//           purchase_orders (id, po_number),
//           employees:employee_id (id, full_name),
//           admin_profiles:admin_id (id, full_name),
//           suppliers (id, name),
//           return_order_items (
//             id, product_definition_id, returned_serial_id, reason_for_return, replacement_serial_id, item_status,
//             product_definitions (id, name, item_code),
//             returned_serialized_items:returned_serial_id (id, serial_number, status)
//           )
//         '''

// '''
//             *,
//             purchase_orders (id, po_number),
//             employees:employee_id (id, full_name),
//             admin_profiles:admin_id (id, full_name),
//             suppliers (id, name)
//           '''

class ReturnOrderService {
  final SerialitemService
      _serializedItemService; // For updating serial item statuses

  ReturnOrderService(this._serializedItemService);

  Future<ReturnOrderData> createReturnOrder({
    required ReturnOrderData returnOrder,
    required List<ReturnOrderItemData> items,
  }) async {
    try {
      // 1. Insert the ReturnOrderData
      final roMap = returnOrder.toJson();
      // Remove id if it's null, as it's auto-generated
      roMap.removeWhere((key, value) => key == 'id' && value == null);

      final List<Map<String, dynamic>> roResponse = await supabaseDB
          .from('return_order')
          .insert(roMap)
          .select(); // Select to get the created RO with generated ID and joined data

      if (roResponse.isEmpty) {
        throw Exception('Failed to create return order header.');
      }

      final createdRO = ReturnOrderData.fromJson(roResponse.first);
      if (createdRO.id == null) {
        throw Exception('Return order created without an ID.');
      }

      // 2. Insert ReturnOrderItems
      List<ReturnOrderItemData> createdItems = [];
      for (var item in items) {
        final itemMap = item.copyWith(returnOrderId: createdRO.id!).toJson();
        itemMap.removeWhere((key, value) => key == 'id' && value == null);

        final List<Map<String, dynamic>> itemResponse = await supabaseDB
            .from('return_order_items')
            .insert(itemMap)
            .select();

        if (itemResponse.isEmpty) {
          // Potentially roll back the RO header or mark it as errored
          throw Exception(
              'Failed to create return order item for product ID: ${item.productDefinitionId}');
        }
        createdItems.add(ReturnOrderItemData.fromJson(itemResponse.first));

        await _serializedItemService.updateSerializedItemStatus(
          item.returnedSerialId,
          "Pending Return",
        );
      }

      return createdRO.copyWith(items: createdItems);
    } catch (e) {
      print('Error creating return order: $e');
      rethrow; // Propagate the error to be handled by the notifier/UI
    }
  }

  /// Fetches a list of Return Orders with optional filters.
  Future<List<ReturnOrderData>> fetchReturnOrders({
    ReturnOrderStatus? status,
    int? supplierId,
    String? searchTerm, // For searching by RO ID or notes
    DateTime? startDate,
    DateTime? endDate,
    String? orderByColumn = 'created_at',
    bool ascending = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Create the base query
      var query = supabaseDB.from('return_orders').select().limit(limit);

      // Use dynamic type for intermediate query to handle type transitions
      dynamic filtered = query;

      // Apply filters conditionally
      if (status != null) {
        filtered = filtered.eq('status', status.name);
      }
      if (supplierId != null) {
        filtered = filtered.eq('supplier_id', supplierId);
      }
      if (searchTerm != null && searchTerm.isNotEmpty) {
        if (int.tryParse(searchTerm) != null) {
          filtered = filtered.or('id.eq.$searchTerm,notes.ilike.%$searchTerm%');
        } else {
          filtered =
              filtered.textSearch('notes', searchTerm, config: 'english');
        }
      }
      if (startDate != null) {
        filtered = filtered.gte('return_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        filtered = filtered.lte('return_date', endDate.toIso8601String());
      }

      // Apply ordering at the end
      final result = await filtered.order(orderByColumn!, ascending: ascending);

      // In Supabase v2, need to access data property from response
      final data = result.data as List;

      return data.map((map) => ReturnOrderData.fromJson(map)).toList();
    } catch (e) {
      print('Error fetching return orders: $e');
      rethrow;
    }
  }

  /// Fetches a single Return Order by its ID, including its items.
  Future<ReturnOrderData?> getReturnOrderById(int roId) async {
    try {
      final response = await supabaseDB
          .from('return_order')
          .select()
          .eq('returnOrderID', roId)
          .single(); // Use .single() if you expect exactly one record or null

      return ReturnOrderData.fromJson(response);
    } catch (e) {
      print('Error fetching return order by ID $roId: $e');
      if (e is PostgrestException && e.code == 'PGRST116') {
        final countResponse = await supabaseDB
            .from('return_order')
            .select('returnOrderID')
            .eq('returnOrderID', roId)
            .count();
        if (countResponse.count == 0) return null;
      }
      rethrow;
    }
  }

  /// Updates the status of a Return Order (e.g., admin approval/rejection).
  Future<ReturnOrderData> updateReturnOrderStatus({
    required int roId,
    required ReturnOrderStatus newStatus,
    String? adminId,
    DateTime? adminActionDate,
    String? notes,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': newStatus.name,
      };
      if (adminId != null) {
        updates['adminID'] = adminId;
        updates['adminActionDate'] =
            (adminActionDate ?? DateTime.now()).toIso8601String();
      }
      if (notes != null) {
        updates['notes'] = notes; // Append or overwrite based on preference
      }

      final response = await supabaseDB
          .from('return_order')
          .update(updates)
          .eq('returnOrderID', roId)
          .select()
          .single();

      // If admin rejected, update associated serialized items' status back to 'Defective' (or original problem status)
      if (newStatus == ReturnOrderStatus.adminRejected) {
        final roWithItems = ReturnOrderData.fromJson(response);
        if (roWithItems.items != null) {
          for (var item in roWithItems.items!) {
            await _serializedItemService.updateSerializedItemStatus(
              item.returnedSerialId,
              "Defective", // Or fetch original status before 'PendingReturn'
            );
            // Also update the return_order_item status
            await updateReturnOrderItemStatus(
                returnOrderItemId: item.id!,
                newItemStatus: ReturnOrderItemStatus.returnRejectedByAdmin);
          }
        }
      }
      // Add more logic here if other statuses require updates to serialized_items or return_order_items
      return ReturnOrderData.fromJson(response);
    } catch (e) {
      print('Error updating return order status for RO ID $roId: $e');
      rethrow;
    }
  }

  // --- Return Order Item Operations ---

  /// Updates the status of a specific item within a return order.
  Future<ReturnOrderItemData> updateReturnOrderItemStatus({
    required int returnOrderItemId,
    required ReturnOrderItemStatus newItemStatus,
    String? reason, // Optional reason for this item status update
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': newItemStatus.name,
      };
      if (reason != null) {
        updates['notes'] = reason; // Could be appending to existing or new
      }

      final response = await supabaseDB
          .from('return_order_items')
          .update(updates)
          .eq('returnOrderItemID', returnOrderItemId)
          .select()
          .single();
      return ReturnOrderItemData.fromJson(response);
    } catch (e) {
      print(
          'Error updating return order item status for item ID $returnOrderItemId: $e');
      rethrow;
    }
  }

  /// Links a new replacement serial ID to a returned item and updates statuses.
  Future<ReturnOrderItemData> receiveReplacementForItem({
    required int returnOrderItemId,
    required String
        originalReturnedSerialId, // To update its status if needed (e.g. to Disposed)
    required SerializedItem
        newReplacementSerialItemData, // Full data for the new serial
  }) async {
    try {
      final newSerializedItem = await _serializedItemService.addSerializedItem(
        newReplacementSerialItemData.copyWith(
            status: "Available"), // Ensure it's available
      );
      if (newSerializedItem.serialNumber.isEmpty) {
        throw Exception("Failed to add new replacement serial to inventory.");
      }

      await _serializedItemService.updateSerializedItemStatus(
        originalReturnedSerialId,
        "Disposed", // Example status
      );

      final updates = {
        'replacementSerialID': newSerializedItem.serialNumber,
        'itemStatus': ReturnOrderItemStatus.replacementReceived.name,
      };

      final response = await supabaseDB
          .from('return_order_items')
          .update(updates)
          .eq('returnOrderItemID', returnOrderItemId)
          .select()
          .single();

      return ReturnOrderItemData.fromJson(response);
    } catch (e) {
      print('Error receiving replacement for item ID $returnOrderItemId: $e');
      rethrow;
    }
  }

  // --- Helper/Utility Methods ---

  Future<List<SerializedItem>> getReturnableSerialsForPO(
      int purchaseOrderId) async {
    try {
      final poSerialsResponse = await supabaseDB
          .from('item_serials')
          .select()
          .eq('purchaseOrderID', purchaseOrderId);

      final poSerials = poSerialsResponse
          .map((data) => SerializedItem.fromJson(data))
          .toList();

      if (poSerials.isEmpty) return [];

      // Fetch IDs of serials already in active return orders
      final returnedSerialIdsResponse = await supabaseDB
          .from('return_order_items')
          .select('returnOrderItemID')
          .filter('serialNumber', 'not.in',
              '("${ReturnOrderItemStatus.replacementReceived.name}","${ReturnOrderItemStatus.completed.name}")'); // Adjust active statuses as needed

      final returnedSerialIds = returnedSerialIdsResponse
          .map<String>((item) => item['returnedSerialID'])
          .toSet();

      // Filter out serials that are already being returned
      final returnableSerials = poSerials.where((serial) {
        return !returnedSerialIds.contains(serial.serialNumber);
      }).toList();

      return returnableSerials;
    } catch (e) {
      print('Error fetching returnable serials for PO ID $purchaseOrderId: $e');
      rethrow;
    }
  }

  // Optional: Method to update general RO details (e.g., notes)
  Future<ReturnOrderData> updateReturnOrderDetails({
    required int roId,
    String? notes,
    // Add other updatable fields as needed
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (notes != null) updates['notes'] = notes;
      // Add other fields to 'updates' map

      if (updates.isEmpty) {
        // If nothing to update, just fetch and return current data
        return (await getReturnOrderById(roId))!;
      }

      final response = await supabaseDB
          .from('return_order')
          .update(updates)
          .eq('returnOrderID', roId)
          .select()
          .single();
      return ReturnOrderData.fromJson(response);
    } catch (e) {
      print('Error updating return order details for RO ID $roId: $e');
      rethrow;
    }
  }
}
