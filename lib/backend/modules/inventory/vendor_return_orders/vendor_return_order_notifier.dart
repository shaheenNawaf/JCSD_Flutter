//Default Imports
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_service.dart';

class VendorReturnOrderNotifier extends AsyncNotifier<VendorReturnOrderState> {
  late final VendorReturnOrderService _vroService;

  @override
  Future<VendorReturnOrderState> build() async {
    _vroService = ref.watch(vendorReturnOrderServiceProvider);
    final vroList = await _vroService.getVendorReturnOrders();
    return VendorReturnOrderState(
      vroList: AsyncValue.data(vroList),
      selectedVRO: const AsyncValue.data(null),
      defectiveSerialsForSelectedPO: const AsyncValue.data([]),
    );
  }

  Future<void> fetchVendorReturnOrders({
    String? statusFilter,
    int? supplierId,
    int? originalPoId,
  }) async {
    final currentStateValue = state.value ?? VendorReturnOrderState.initial();
    state = AsyncValue.data(
        currentStateValue.copyWith(vroList: const AsyncValue.loading()));

    try {
      final vroList = await _vroService.getVendorReturnOrders(
        statusFilter: statusFilter,
        supplierId: supplierId,
        originalPoId: originalPoId,
      );
      final newStateValue = state.value ?? VendorReturnOrderState.initial();
      state = AsyncValue.data(
          newStateValue.copyWith(vroList: AsyncValue.data(vroList)));
    } catch (e, s) {
      final newStateValue = state.value ?? VendorReturnOrderState.initial();
      state = AsyncValue.data(
          newStateValue.copyWith(vroList: AsyncValue.error(e, s)));
    }
  }

  Future<void> getVROById(int vroId) async {
    final currentStateValue = state.value ?? VendorReturnOrderState.initial();
    state = AsyncValue.data(
        currentStateValue.copyWith(selectedVRO: const AsyncValue.loading()));
    try {
      final vro = await _vroService.getVendorReturnOrderById(vroId);
      final newStateValue = state.value ?? VendorReturnOrderState.initial();
      state = AsyncValue.data(
          newStateValue.copyWith(selectedVRO: AsyncValue.data(vro)));
    } catch (e, s) {
      final newStateValue = state.value ?? VendorReturnOrderState.initial();
      state = AsyncValue.data(
          newStateValue.copyWith(selectedVRO: AsyncValue.error(e, s)));
    }
  }

  void clearSelectedVRO() {
    if (state.hasValue) {
      state = AsyncValue.data(
          state.value!.copyWith(selectedVRO: const AsyncValue.data(null)));
    }
  }

  Future<VendorReturnOrder?> createVRO({
    required VendorReturnOrder vroData,
    required List<VendorReturnOrderItem> items,
    required String initialDefectiveStatus,
    required String postCreationSerialStatus,
  }) async {
    VendorReturnOrder? newVRO;
    try {
      newVRO = await _vroService.createVendorReturnOrderWithItems(
        vroDataToInsert: vroData,
        vroItemsToInsert: items,
        defectiveItemInitialStatus: initialDefectiveStatus,
        defectiveItemPostVROCreationStatus: postCreationSerialStatus,
      );
      await fetchVendorReturnOrders(); // Refresh the list, which handles its own loading/data/error
      return newVRO;
    } catch (e) {
      // If createVRO fails, fetchVendorReturnOrders will reset vroList to its current state or error
      await fetchVendorReturnOrders();
      rethrow;
    }
  }

  Future<void> updateVRO({
    required int vroId,
    String? newVROStatus,
    DateTime? defectiveItemsShippedDate,
    String? trackingNumberToVendor,
    String? notes,
    String? oldItemFinalStatusOnShipment,
  }) async {
    try {
      await _vroService.updateVendorReturnOrder(
        vroId: vroId,
        newVROStatus: newVROStatus,
        defectiveItemsShippedDate: defectiveItemsShippedDate,
        trackingNumberToVendor: trackingNumberToVendor,
        notes: notes,
        oldItemFinalStatusOnShipment: oldItemFinalStatusOnShipment,
      );
      await fetchVendorReturnOrders();
      // If the updated VRO was the selected one, refresh it
      if (state.value?.selectedVRO.value?.vroID == vroId) {
        await getVROById(vroId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchDefectiveSerialsForPO(
      int poId, String defectiveStatus) async {
    final currentStateValue = state.value ?? VendorReturnOrderState.initial();
    state = AsyncValue.data(currentStateValue.copyWith(
        defectiveSerialsForSelectedPO: const AsyncValue.loading()));
    try {
      final serials = await _vroService.fetchDefectiveSerialsForPO(
        poId: poId,
        defectiveStatus: defectiveStatus,
      );
      final newStateValue = state.value ?? VendorReturnOrderState.initial();
      state = AsyncValue.data(newStateValue.copyWith(
          defectiveSerialsForSelectedPO: AsyncValue.data(serials)));
    } catch (e, s) {
      final newStateValue = state.value ?? VendorReturnOrderState.initial();
      state = AsyncValue.data(newStateValue.copyWith(
          defectiveSerialsForSelectedPO: AsyncValue.error(e, s)));
    }
  }

  void clearDefectiveSerials() {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!
          .copyWith(defectiveSerialsForSelectedPO: const AsyncValue.data([])));
    }
  }

  Future<bool> processReplacement({
    required int vroId,
    required int vroItemId,
    required String originalReturnedSerialNumber,
    required String newReplacementSerialNumber,
    required DateTime replacementReceivedDate,
    required String productDefID,
    required double costAtTimeOfPurchase,
    required int supplierID,
    required int originalPoID,
    required int originalPoItemID,
    required String newSerialAvailableStatus,
  }) async {
    try {
      final success = await _vroService.processReplacementReceiptViaRPC(
        vroId: vroId,
        vroItemId: vroItemId,
        originalReturnedSerialNumber: originalReturnedSerialNumber,
        newReplacementSerialNumber: newReplacementSerialNumber,
        replacementReceivedDate: replacementReceivedDate,
        productDefID: productDefID,
        costAtTimeOfPurchase: costAtTimeOfPurchase,
        supplierID: supplierID,
        originalPoID: originalPoID,
        originalPoItemID: originalPoItemID,
        newSerialAvailableStatus: newSerialAvailableStatus,
      );
      if (success) {
        await fetchVendorReturnOrders();
        if (state.value?.selectedVRO.value?.vroID == vroId) {
          await getVROById(vroId);
        }
        // Invalidate other providers if necessary, e.g., PO list, item serials list
        ref.invalidate(purchaseOrderListNotifierProvider);
        ref.invalidate(serializedItemNotifierProvider);
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }
}
