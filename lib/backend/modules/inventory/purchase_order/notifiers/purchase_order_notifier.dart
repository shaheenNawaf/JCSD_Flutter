//Default Imports
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
//Purchase Sub-System
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/purchase_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/services/purchase_order_service.dart';

//Serialized Items
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';

//Providers for both PO and Serial Items
final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  return PurchaseOrderService();
});

final serialItemServiceProviderForPO = Provider<SerialitemService>((ref) {
  return SerialitemService();
});

// Notifier Provider
final purchaseOrderListNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PurchaseOrderListNotifier, PurchaseOrderListState>(
  () => PurchaseOrderListNotifier(),
);

class PurchaseOrderListNotifier
    extends AutoDisposeAsyncNotifier<PurchaseOrderListState> {
  Timer? _debounce;
  PurchaseOrderService get _poService => ref.read(purchaseOrderServiceProvider);
  SerialitemService get _serialService =>
      ref.read(serialItemServiceProviderForPO);

  @override
  Future<PurchaseOrderListState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    const initialState =
        PurchaseOrderListState(); // Default filters, sort, page
    return _fetchDataForState(initialState);
  }

  Future<PurchaseOrderListState> _fetchDataForState(
      PurchaseOrderListState stateToFetch) async {
    final totalItems = await _poService.getTotalPurchaseOrderCount(
      status: stateToFetch.statusFilter?.dbValue, // Use .dbValue for enum
      supplierID: stateToFetch.supplierFilter,
      searchQuery: stateToFetch.searchText,
    );

    //for pagination
    final totalPages = (totalItems / stateToFetch.itemsPerPage).ceil();

    final items = await _poService.fetchPurchaseOrders(
      status: stateToFetch.statusFilter?.dbValue, // Use .dbValue
      supplierID: stateToFetch.supplierFilter,
      sortBy: stateToFetch.sortBy,
      ascending: stateToFetch.ascending,
      page: stateToFetch.currentPage,
      itemsPerPage: stateToFetch.itemsPerPage,
      searchQuery: stateToFetch.searchText,
    );

    print("Notifier: Fetched ${items.length} POs. Total pages: $totalPages");

    return stateToFetch.copyWith(
      purchaseOrders: items,
      totalPages: totalPages > 0 ? totalPages : 1,
    );
  }

  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        page < 1 ||
        page > currentState.totalPages ||
        page == currentState.currentPage) {
      return;
    }

    state =
        const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      return _fetchDataForState(currentState.copyWith(currentPage: page));
    });
  }

  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    state =
        const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      return _fetchDataForState(currentState.copyWith(
          sortBy: newSortBy, ascending: newAscending, currentPage: 1));
    });
  }

  void search(String newSearchText) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;
      if (currentState == null || currentState.searchText == newSearchText) {
        return;
      }

      state =
          const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
      state = await AsyncValue.guard(() async {
        return _fetchDataForState(
            currentState.copyWith(searchText: newSearchText, currentPage: 1));
      });
    });
  }

  Future<void> applyFilters({
    PurchaseOrderStatus? status,
    int? supplierId,
    bool clearStatus = false,
    bool clearSupplier = false,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newStatusFilter =
        clearStatus ? null : (status ?? currentState.statusFilter);
    final newSupplierFilter =
        clearSupplier ? null : (supplierId ?? currentState.supplierFilter);

    // Avoid refetch if filters haven't actually changed
    if (newStatusFilter == currentState.statusFilter &&
        newSupplierFilter == currentState.supplierFilter) {
      return;
    }

    state =
        const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      return _fetchDataForState(currentState.copyWith(
          statusFilter: () => newStatusFilter,
          supplierFilter: () => newSupplierFilter,
          currentPage: 1));
    });
  }

  Future<void> refresh() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }
    state =
        const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final totalItems = await _poService.getTotalPurchaseOrderCount(
        status: currentState.statusFilter?.dbValue,
        supplierID: currentState.supplierFilter,
        searchQuery: currentState.searchText,
      );
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;
      final currentPageToFetch =
          currentState.currentPage.clamp(1, calculatedTotalPages);

      return _fetchDataForState(
          currentState.copyWith(currentPage: currentPageToFetch));
    });
  }

  // Actual Action Methods

  Future<void> createNewPurchaseOrder({
    required int supplierID,
    required int createdByEmployee,
    required DateTime orderDate,
    DateTime? expectedDeliveryDate,
    String? note,
    required List<PurchaseOrderItemData> items,
  }) async {
    //Immediate Loading Feedback, esp after adding
    state =
        const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
    await _poService.createPurchaseOrder(
      supplierID: supplierID,
      createdByEmployee: createdByEmployee,
      orderDate: orderDate,
      expectedDeliveryDate: expectedDeliveryDate,
      note: note,
      items: items,
    );
    await refresh(); //Mga invalidates
  }

  Future<void> updatePOStatus(int poId, PurchaseOrderStatus newStatus,
      {int? adminId, String? notes}) async {
    state =
        const AsyncLoading<PurchaseOrderListState>().copyWithPrevious(state);
    await _poService.updatePurchaseOrderStatus(
      poId: poId,
      newStatus: newStatus,
      approvedByAdminId: adminId, // Pass adminId if approving
      notes: notes,
    );
    await refresh();
  }

  Future<void> receiveItemsForPOItem({
    required int poId,
    required int poItemId,
    required int quantityReceivedNow,
    required List<String> serialNumbers,
    required int employeeId,
    DateTime? dateReceived,
    double? actualUnitCost,
  }) async {
    if (serialNumbers.length != quantityReceivedNow) {
      throw ArgumentError("Number of serials must match quantity received.");
    }
    if (quantityReceivedNow <= 0) {
      throw ArgumentError("Quantity received must be greater than zero.");
    }

    state = const AsyncLoading<PurchaseOrderListState>()
        .copyWithPrevious(state); // For list loading

    try {
      final poItem = await _poService.getPurchaseOrderItemById(poItemId);
      if (poItem == null) throw Exception("PO Item $poItemId not found.");
      if ((poItem.quantityReceived + quantityReceivedNow) >
          poItem.quantityOrdered) {
        throw Exception(
            "Cannot receive more than ordered for PO Item ID $poItemId.");
      }

      final purchaseOrder =
          await _poService.getPurchaseOrderById(poItem.purchaseOrderID);
      if (purchaseOrder == null) {
        throw Exception("Parent PO ${poItem.purchaseOrderID} not found.");
      }
      if (purchaseOrder.status != PurchaseOrderStatus.Approved &&
          purchaseOrder.status != PurchaseOrderStatus.PartiallyReceived) {
        throw Exception(
            "Items can only be received for 'Approved' or 'Partially Received' POs. Current status: ${purchaseOrder.status.dbValue}");
      }

      await _poService.updatePurchaseOrderItemQuantityReceived(
        poItemId: poItemId,
        quantityReceivedNow: quantityReceivedNow,
      );

      // Create item_serials records
      final List<Map<String, dynamic>> newSerialsJsonToInsert = [];
      for (String sn in serialNumbers) {
        newSerialsJsonToInsert.add({
          'serialNumber': sn,
          'prodDefID': poItem.prodDefID,
          'supplierID': purchaseOrder.supplierID,
          'costPrice': poItem.unitCostPrice,
          'purchaseDate': DateTime.now().toIso8601String(), // Defaulting to now
          'status': 'Available', // Default in-stock status
          'employeeID': employeeId,
          'notes': 'Received via PO #${purchaseOrder.poId}',
        });
      }

      if (newSerialsJsonToInsert.isNotEmpty) {
        await _serialService.bulkAddSerializedItems(newSerialsJsonToInsert);
      }

      await refresh();
      ref.invalidate(serializedItemNotifierProvider(poItem.prodDefID));
    } catch (e, st) {
      print(
          'Notifier Error - receiveItemsForPOItem for PO Item $poItemId: $e\n$st');
      // If state handles errors: state = AsyncError(e, st).copyWithPrevious(state);
      rethrow;
    }
  }
}
