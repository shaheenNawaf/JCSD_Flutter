import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import state, data, service and providers
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';

// Default items per page/hardcoded pa
const int _serialItemsPerPage = 10;

class SerializedItemNotifier
    extends AutoDisposeFamilyAsyncNotifier<SerializedItemState, String> {
  late String _prodDefID;
  Timer? _debounce;

  SerialitemService get _service => ref.read(serialitemServiceProvider);

  @override
  Future<SerializedItemState> build(String arg) async {
    _prodDefID = arg;
    print('SerializedItemNotifier build: prodDefID = $_prodDefID');

    ref.onDispose(() {
      _debounce?.cancel();
      print("SerializedItemNotifier (prodDefID: $_prodDefID) disposed.");
    });

    // Initial state parameters
    const currentPage = 1;
    const itemsPerPage = _serialItemsPerPage;
    const sortBy = 'serialNumber';
    const ascending = true;
    const searchText = '';
    const String? statusFilter = null;

    final totalItems = await _fetchTotalCount(
        searchText: searchText, statusFilter: statusFilter);
    final totalPages = (totalItems / itemsPerPage).ceil();
    final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

    final items = await _fetchPageData(
      page: currentPage,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
      statusFilter: statusFilter,
    );

    return SerializedItemState(
      serializedItems: items,
      currentPage: currentPage,
      totalPages: calculatedTotalPages,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
      statusFilter: statusFilter,
    );
  }

  // Helper Methods for pagination, and state management

  Future<int> _fetchTotalCount(
      {required String searchText, String? statusFilter}) async {
    // Calls service, passing prodDefID and other filters
    return _service.getTotalSerializedItemCount(
      prodDefID: _prodDefID,
      searchQuery: searchText,
      status: statusFilter,
    );
  }

  Future<List<SerializedItem>> _fetchPageData({
    required int page,
    required int itemsPerPage,
    required String sortBy,
    required bool ascending,
    required String searchText,
    String? statusFilter,
  }) async {
    // Calls service with all necessary parameters including prodDefID
    return _service.fetchSerializedItems(
      prodDefID: _prodDefID,
      page: page,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchQuery: searchText,
      status: statusFilter,
    );
  }

  // UI Action Methods dito

  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull; // Get current state data safely
    if (currentState == null || page < 1 || page > currentState.totalPages) {
      return; // Basic validation
    }

    state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: page, // Target page
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
        statusFilter: currentState.statusFilter,
      );
      return currentState.copyWith(
        serializedItems: items,
        currentPage: page,
      );
    });
  }

  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1;

    state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);

    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: newSortBy,
        ascending: newAscending,
        searchText: currentState.searchText,
        statusFilter: currentState.statusFilter,
      );
      return currentState.copyWith(
        serializedItems: items,
        currentPage: newPage,
        sortBy: newSortBy,
        ascending: newAscending,
      );
    });
  }

  Future<void> filterByStatus(String? newStatusFilter) async {
    final currentState = state.valueOrNull;

    if (currentState == null || currentState.statusFilter == newStatusFilter) {
      return;
    }

    const newPage = 1;
    state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);

    try {
      final totalItems = await _fetchTotalCount(
          searchText: currentState.searchText, statusFilter: newStatusFilter);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
        statusFilter: newStatusFilter,
      );

      state = AsyncData(currentState.copyWith(
        serializedItems: items,
        currentPage: newPage,
        totalPages: calculatedTotalPages,
        statusFilter: () => newStatusFilter,
      ));
    } catch (e, s) {
      print("Error filtering by status ($newStatusFilter): $e");

      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
    }
  }

  void search(String newSearchText) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;

      if (currentState == null || currentState.searchText == newSearchText) {
        return;
      }

      const newPage = 1;

      state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);

      try {
        final totalItems = await _fetchTotalCount(
            searchText: newSearchText, statusFilter: currentState.statusFilter);
        final totalPages = (totalItems / currentState.itemsPerPage).ceil();
        final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

        final items = await _fetchPageData(
          page: newPage,
          itemsPerPage: currentState.itemsPerPage,
          sortBy: currentState.sortBy,
          ascending: currentState.ascending,
          searchText: newSearchText,
          statusFilter: currentState.statusFilter,
        );

        state = AsyncData(currentState.copyWith(
          serializedItems: items,
          currentPage: newPage,
          searchText: newSearchText,
          totalPages: calculatedTotalPages,
        ));
      } catch (e, s) {
        print("Error during serial search($newSearchText): $e");

        state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
      }
    });
  }

  Future<void> refreshCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }

    final previousState = currentState;

    state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);

    try {
      final totalItems = await _fetchTotalCount(
          searchText: currentState.searchText,
          statusFilter: currentState.statusFilter);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      int pageToFetch = currentState.currentPage;
      if (pageToFetch > calculatedTotalPages) {
        pageToFetch = calculatedTotalPages;
      }
      if (pageToFetch < 1) pageToFetch = 1;

      final items = await _fetchPageData(
        page: pageToFetch,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
        statusFilter: currentState.statusFilter,
      );

      state = AsyncData(previousState.copyWith(
        serializedItems: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
        searchText: currentState.searchText,
        statusFilter: () => currentState.statusFilter,
      ));
    } catch (e, s) {
      print("Error refreshing serial items page: $e");
      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
    }
  }

  // CRUD

  Future<void> addSerializedItem(SerializedItem newItem) async {
    if (newItem.prodDefID != _prodDefID) {
      print("Error: Attempting to add serial with mismatched prodDefID.");
      state = AsyncError<SerializedItemState>(
              "Mismatched Product ID", StackTrace.current)
          .copyWithPrevious(state);
      return;
    }

    state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);
    try {
      await _service.addSerializedItem(newItem);
      await refreshCurrentPage();
    } catch (e, s) {
      print("Error adding serialized item: $e \n$s");

      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
      rethrow;
    }
  }

  Future<void> updateSerializedItem(SerializedItem updatedItem) async {
    if (updatedItem.prodDefID != _prodDefID) {
      print("Error: Attempting to update serial with mismatched prodDefID.");
      state = AsyncError<SerializedItemState>(
              "Mismatched Product ID during update", StackTrace.current)
          .copyWithPrevious(state);
      return;
    }

    state = const AsyncLoading<SerializedItemState>().copyWithPrevious(state);
    try {
      await _service.updateSerializedItem(updatedItem);
      await refreshCurrentPage();
    } catch (e, s) {
      print(
          "Error updating serialized item (${updatedItem.serialNumber}): $e \n$s");

      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
      rethrow;
    }
  }

  Future<void> updateItemStatus(String serialNumber, String newStatus) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      print("Cannot update status: current state is null");
      return;
    }

    SerializedItem? itemToUpdate;
    try {
      itemToUpdate = currentState.serializedItems
          .firstWhere((item) => item.serialNumber == serialNumber);
    } catch (e) {
      print("Item with serial $serialNumber not found in current state.");
      state = AsyncError<SerializedItemState>(
              "Item not found for status update", StackTrace.current)
          .copyWithPrevious(state);
      return;
    }

    final updatedItem = itemToUpdate.copyWith(status: newStatus);

    await updateSerializedItem(updatedItem);
  }
}
