// lib/backend/modules/inventory/return_orders/return_order_notifier.dart
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
  () => ReturnOrderListNotifier(),
);

class ReturnOrderListNotifier
    extends AutoDisposeAsyncNotifier<ReturnOrderListState> {
  Timer? _searchDebounce;
  ReturnOrderService get _service => ref.read(returnOrderServiceProvider);

  @override
  Future<ReturnOrderListState> build() async {
    ref.onDispose(() => _searchDebounce?.cancel());
    // Initial state with default filters/sorting
    const initialState = ReturnOrderListState();
    return _fetchDataForState(initialState);
  }

  Future<ReturnOrderListState> _fetchDataForState(
      ReturnOrderListState stateToFetch,
      {bool isLoadMore = false}) async {
    if (!isLoadMore) {
      // For initial load or filter change, update isLoading
      state = AsyncData(
          stateToFetch.copyWith(isLoading: true, errorMessage: () => null));
    } else {
      // For load more, update isLoadingMore
      state = AsyncData(
          stateToFetch.copyWith(isLoadingMore: true, errorMessage: () => null));
    }

    try {
      final totalItems = await _service.getTotalReturnOrderCount(
        searchQuery: stateToFetch.searchText,
        statusFilter: stateToFetch.statusFilter,
        supplierIdFilter: stateToFetch.supplierFilter,
        purchaseOrderIdFilter: stateToFetch.purchaseOrderFilter,
      );

      final totalPages = (totalItems / stateToFetch.itemsPerPage).ceil();
      final currentPage =
          stateToFetch.currentPage.clamp(1, totalPages > 0 ? totalPages : 1);

      final items = await _service.fetchReturnOrders(
        searchQuery: stateToFetch.searchText,
        statusFilter: stateToFetch.statusFilter,
        supplierIdFilter: stateToFetch.supplierFilter,
        purchaseOrderIdFilter: stateToFetch.purchaseOrderFilter,
        sortBy: stateToFetch.sortBy,
        ascending: stateToFetch.ascending,
        page: currentPage,
        itemsPerPage: stateToFetch.itemsPerPage,
      );

      List<ReturnOrderData> combinedItems;
      if (isLoadMore) {
        final currentItems = stateToFetch.returnOrders;
        // Avoid duplicates if re-fetching same page due to some logic error
        final newItems = items
            .where((newItem) => !currentItems.any(
                (oldItem) => oldItem.returnOrderID == newItem.returnOrderID))
            .toList();
        combinedItems = [...currentItems, ...newItems];
      } else {
        combinedItems = items;
      }

      return stateToFetch.copyWith(
        returnOrders: combinedItems,
        totalPages: totalPages > 0 ? totalPages : 1,
        currentPage: currentPage,
        isLoading: false,
        isLoadingMore: false,
      );
    } catch (e, st) {
      print("Error in _fetchDataForState (ReturnOrderNotifier): $e\n$st");
      // Preserve existing data on error if possible, or clear it
      final previousData = state.asData?.value.returnOrders ?? [];
      return stateToFetch.copyWith(
          returnOrders: previousData, // Keep old data on error
          isLoading: false,
          isLoadingMore: false,
          errorMessage: () => e.toString());
    }
  }

  Future<void> goToPage(int page) async {
    final currentState = state.asData?.value;
    if (currentState == null ||
        page < 1 ||
        page > currentState.totalPages ||
        page == currentState.currentPage) {
      return;
    }
    // If loading more, current page in state is already updated
    if (page > currentState.currentPage && !currentState.isLoadingMore) {
      // Load More
      ref.read(_modalProductDefinitionsCurrentPageProvider.notifier).state =
          page; // Using a modal provider as an example, create a specific one if needed
      state = await _fetchDataForState(currentState.copyWith(currentPage: page),
          isLoadMore: true);
    } else if (page < currentState.currentPage) {
      // Navigating to a previous page or specific page
      state =
          await _fetchDataForState(currentState.copyWith(currentPage: page));
    }
  }

  Future<void> sort(String newSortBy) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    state = await _fetchDataForState(currentState.copyWith(
      sortBy: newSortBy,
      ascending: newAscending,
      currentPage: 1, // Reset to first page on sort
      returnOrders: [], // Clear current items before fetching sorted
      isLoadingMore: false,
      totalPages: 1, // Reset total pages until fetched
    ));
  }

  void search(String newSearchText) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.asData?.value;
      if (currentState == null || currentState.searchText == newSearchText)
        return;

      state = await _fetchDataForState(currentState.copyWith(
        searchText: newSearchText,
        currentPage: 1,
        returnOrders: [],
        isLoadingMore: false,
        totalPages: 1,
      ));
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
    if (currentState == null) return;

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
      return; // No change in filters
    }

    state = await _fetchDataForState(currentState.copyWith(
      statusFilter: () => newStatusFilter,
      supplierFilter: () => newSupplierFilter,
      purchaseOrderFilter: () => newPoFilter,
      currentPage: 1,
      returnOrders: [],
      isLoadingMore: false,
      totalPages: 1,
    ));
  }

  Future<void> refresh() async {
    final currentState = state.asData?.value;
    if (currentState == null) {
      state = const AsyncLoading(); // Go to loading if no previous state
      state = await AsyncValue.guard(() => build()); // Re-run build
      return;
    }
    // Re-fetch data for the current state (current page, filters, etc.)
    state = await _fetchDataForState(
        currentState.copyWith(returnOrders: [], isLoadingMore: false));
  }
}
