//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_item_data.dart';

//Default Imports
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/api/global_variables.dart';

class VendorReturnOrderService {
  final SupabaseClient _client = supabaseDB;

  static const String _vroTable = 'vendor_return_orders';
  static const String _vroItemTable = 'vendor_return_order_items';
  static const String _itemSerialsTable = 'item_serials';

  Future<VendorReturnOrder?> createVendorReturnOrderWithItems({
    required VendorReturnOrder vroDataToInsert, // Model now has Enum for status
    required List<VendorReturnOrderItem> vroItemsToInsert,
    required String defectiveItemInitialStatus,
    required String defectiveItemPostVROCreationStatus,
  }) async {
    try {
      final List<Map<String, dynamic>> insertedVROs = await _client
          .from(_vroTable)
          .insert(vroDataToInsert.toJsonForInsert())
          .select('*, vendor_return_order_items(*)');

      if (insertedVROs.isEmpty) {
        return null;
      }

      final createdVRO = VendorReturnOrder.fromJson(insertedVROs.first);
      final int newVroID = createdVRO.vroID;

      final List<Map<String, dynamic>> itemsToInsertJson =
          vroItemsToInsert.map((item) {
        return item.copyWith(vroID: newVroID).toJsonForInsert();
      }).toList();

      if (itemsToInsertJson.isNotEmpty) {
        await _client.from(_vroItemTable).insert(itemsToInsertJson);
      }

      for (var item in vroItemsToInsert) {
        await _client
            .from(_itemSerialsTable)
            .update({'status': defectiveItemPostVROCreationStatus})
            .eq('serialNumber', item.returnedSerialNumber)
            .eq('status', defectiveItemInitialStatus);
      }

      return getVendorReturnOrderById(newVroID);
    } catch (e) {
      rethrow;
    }
  }

  Future<VendorReturnOrder?> getVendorReturnOrderById(int vroId) async {
    try {
      final response = await _client
          .from(_vroTable)
          .select('*, vendor_return_order_items(*)')
          .eq('vroID', vroId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return VendorReturnOrder.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VendorReturnOrder>> getVendorReturnOrders({
    String? statusFilter,
    int? supplierId,
    int? originalPoId,
  }) async {
    try {
      var query =
          _client.from(_vroTable).select('*, vendor_return_order_items(*)');

      dynamic intermediateQuery = query;

      if (statusFilter != null) {
        intermediateQuery = intermediateQuery.eq('status', statusFilter);
      }
      if (supplierId != null) {
        intermediateQuery = intermediateQuery.eq('supplierID', supplierId);
      }
      if (originalPoId != null) {
        intermediateQuery = intermediateQuery.eq('originalPoID', originalPoId);
      }

      final orderedQuery =
          intermediateQuery.order('createdAt', ascending: false);

      final response = await orderedQuery;

      return (response.data as List)
          .map((item) =>
              VendorReturnOrder.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<VendorReturnOrder?> updateVendorReturnOrder({
    required int vroId,
    String? newVROStatus, // Takes String
    DateTime? defectiveItemsShippedDate,
    String? trackingNumberToVendor,
    String? notes,
    String? oldItemFinalStatusOnShipment, // Takes String
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (newVROStatus != null) {
        updates['status'] = newVROStatus; // Use String status
      }
      if (defectiveItemsShippedDate != null) {
        updates['defectiveItemsShippedDate'] =
            defectiveItemsShippedDate.toIso8601String();
      }
      if (trackingNumberToVendor != null) {
        updates['trackingNumberToVendor'] = trackingNumberToVendor;
      }
      if (notes != null) updates['notes'] = notes;

      if (updates.isEmpty) return getVendorReturnOrderById(vroId);

      updates['updatedAt'] = DateTime.now().toIso8601String();

      final List<Map<String, dynamic>> updatedVROs = await _client
          .from(_vroTable)
          .update(updates)
          .eq('vroID', vroId)
          .select('*, vendor_return_order_items(*)');

      if (updatedVROs.isEmpty) {
        return null;
      }

      final updatedVRO = VendorReturnOrder.fromJson(updatedVROs.first);

      // Use your actual string constant for this status
      if (updatedVRO.status == 'ShippedToVendor_AwaitingReplacement' &&
          oldItemFinalStatusOnShipment != null &&
          updatedVRO.items != null) {
        for (var item in updatedVRO.items!) {
          await _client.from(_itemSerialsTable).update(
                  {'status': oldItemFinalStatusOnShipment}) // Use String status
              .eq('serialNumber', item.returnedSerialNumber);
        }
      }
      return updatedVRO;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> processReplacementReceiptViaRPC({
    required int vroId,
    required int vroItemId,
    required String originalReturnedSerialNumber,
    required String newReplacementSerialNumber,
    required DateTime replacementReceivedDate,
    required String productDefID,
    required double costAtTimeOfPurchase,
    required int supplierID,
    required int originalPoID,
    required int
        originalPoItemID, // This is purchase_order_items."purchaseItemID"
    required String newSerialAvailableStatus,
  }) async {
    try {
      await _client.rpc('process_replacement_receipt', params: {
        'p_vro_id': vroId,
        'p_vro_item_id': vroItemId,
        'p_original_returned_serial_number': originalReturnedSerialNumber,
        'p_new_replacement_serial_number': newReplacementSerialNumber,
        'p_replacement_received_date':
            replacementReceivedDate.toIso8601String(),
        'p_product_def_id': productDefID,
        'p_cost_at_time_of_purchase': costAtTimeOfPurchase,
        'p_supplier_id': supplierID,
        'p_original_po_id': originalPoID,
        'p_original_po_item_id': originalPoItemID,
        'p_new_serial_available_status': newSerialAvailableStatus
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SerializedItem>> fetchDefectiveSerialsForPO({
    required int poId,
    required String defectiveStatus,
  }) async {
    try {
      final List<dynamic> response = await _client
          .from(_itemSerialsTable)
          .select()
          .eq('purchaseOrderID', poId)
          .eq('status', defectiveStatus);

      return response
          .map((data) => SerializedItem.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<VendorReturnOrderItem?> addVROItem({
    required VendorReturnOrderItem vroItemDataToInsert,
    required String itemPostAddStatus,
  }) async {
    try {
      final List<Map<String, dynamic>> insertedItems = await _client
          .from(_vroItemTable)
          .insert(vroItemDataToInsert.toJsonForInsert())
          .select();

      if (insertedItems.isEmpty) {
        return null;
      }

      await _client
          .from(_itemSerialsTable)
          .update({'status': itemPostAddStatus}).eq(
              'serialNumber', vroItemDataToInsert.returnedSerialNumber);

      return VendorReturnOrderItem.fromJson(insertedItems.first);
    } catch (e) {
      rethrow;
    }
  }
}
