import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart';

// Provider for the ReturnOrderService
final returnOrderServiceProvider = Provider<ReturnOrderService>((ref) {
  return ReturnOrderService();
});

// Notifier Provider for the Return Order List
final returnOrderListNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ReturnOrderListNotifier, ReturnOrderListState>(
  ReturnOrderListNotifier.new,
);

class ReturnOrderListNotifier
    extends AutoDisposeAsyncNotifier<ReturnOrderListState> {
  Timer? _searchDebounce;
  ReturnOrderService get _service => ref.read(returnOrderServiceProvider);

  /// Core private method to fetch data and update state.
  /// This method is called by build, goToPage, sort, search, applyFilters, and refresh.
  Future<ReturnOrderListState> _fetchAndUpdateState(
      ReturnOrderListState targetStateConfig) async {
    // Indicate loading, but preserve previous data for a smoother UI update if available
    final previousData = state.asData?.value;
    state = const AsyncLoading<ReturnOrderListState>().copyWithPrevious(state);

    try {
      final totalItems = await _service.getTotalReturnOrderCount(
        searchQuery: targetStateConfig.searchText,
        statusFilter: targetStateConfig.statusFilter,
        supplierIdFilter: targetStateConfig.supplierFilter,
        purchaseOrderIdFilter: targetStateConfig.purchaseOrderFilter,
      );

      final totalPages = (totalItems / targetStateConfig.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;
      // Ensure currentPage is valid after totalPages might have changed
      final currentPage =
          targetStateConfig.currentPage.clamp(1, calculatedTotalPages);

      final items = await _service.fetchReturnOrders(
        searchQuery: targetStateConfig.searchText,
        statusFilter: targetStateConfig.statusFilter,
        supplierIdFilter: targetStateConfig.supplierFilter,
        purchaseOrderIdFilter: targetStateConfig.purchaseOrderFilter,
        sortBy: targetStateConfig.sortBy,
        ascending: targetStateConfig.ascending,
        page: currentPage,
        itemsPerPage: targetStateConfig.itemsPerPage,
      );

      return targetStateConfig.copyWith(
        returnOrders: items,
        totalPages: calculatedTotalPages,
        currentPage: currentPage,
        isLoading: false, // Explicitly set isLoading to false
        errorMessage: () => null, // Clear previous errors
      );
    } catch (e, st) {
      print("Error in _fetchAndUpdateState (ReturnOrderNotifier): $e\n$st");
      // Return the previous state with an error message, or a new state with error
      if (previousData != null) {
        return previousData.copyWith(
            isLoading: false, errorMessage: () => e.toString());
      }
      return targetStateConfig.copyWith(
          isLoading: false, errorMessage: () => e.toString(), returnOrders: []);
    }
  }

  @override
  Future<ReturnOrderListState> build() async {
    ref.onDispose(() => _searchDebounce?.cancel());
    return _fetchAndUpdateState(const ReturnOrderListState()); // Initial load
  }

  Future<void> goToPage(int page) async {
    final currentState = state.asData?.value;
    if (currentState == null ||
        page < 1 ||
        page > currentState.totalPages ||
        page == currentState.currentPage ||
        currentState.isLoading) {
      return;
    }
    state = await AsyncValue.guard(
        () => _fetchAndUpdateState(currentState.copyWith(currentPage: page)));
  }

  Future<void> sort(String newSortBy) async {
    final currentState = state.asData?.value;
    if (currentState == null || currentState.isLoading) return;

    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;

    state =
        await AsyncValue.guard(() => _fetchAndUpdateState(currentState.copyWith(
              sortBy: newSortBy,
              ascending: newAscending,
              currentPage: 1, // Reset to first page on sort
            )));
  }

  void search(String newSearchText) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      // Slightly shorter debounce
      final currentState = state.asData?.value;
      // Allow search even if current text is same, to re-trigger if needed, but check loading.
      if (currentState == null || currentState.isLoading) return;

      state = await AsyncValue.guard(
          () => _fetchAndUpdateState(currentState.copyWith(
                searchText: newSearchText,
                currentPage: 1,
              )));
    });
  }

  Future<void> applyFilters({
    ReturnOrderStatus? status,
    int? supplierId,
    int? purchaseOrderId,
    bool clearStatus = false,
    bool clearSupplier = false,
    bool clearPurchaseOrder = false,
  }) async {
    final currentState = state.asData?.value;
    if (currentState == null || currentState.isLoading) return;

    final newStatusFilter =
        clearStatus ? null : (status ?? currentState.statusFilter);
    final newSupplierFilter =
        clearSupplier ? null : (supplierId ?? currentState.supplierFilter);
    final newPoFilter = clearPurchaseOrder
        ? null
        : (purchaseOrderId ?? currentState.purchaseOrderFilter);

    if (newStatusFilter == currentState.statusFilter &&
        newSupplierFilter == currentState.supplierFilter &&
        newPoFilter == currentState.purchaseOrderFilter) {
      return;
    }

    state =
        await AsyncValue.guard(() => _fetchAndUpdateState(currentState.copyWith(
              statusFilter: () => newStatusFilter,
              supplierFilter: () => newSupplierFilter,
              purchaseOrderFilter: () => newPoFilter,
              currentPage: 1,
            )));
  }

  Future<void> refresh() async {
    final currentState = state.asData?.value;
    if (currentState == null || currentState.isLoading) {
      // If no current state or already loading, just rebuild from scratch
      state = const AsyncLoading(); // Show loading
      state = await AsyncValue.guard(() => build());
      return;
    }
    // Re-fetch data for the current filters but reset to page 1 for a full refresh
    state = await AsyncValue.guard(
        () => _fetchAndUpdateState(currentState.copyWith(currentPage: 1)));
  }
}
