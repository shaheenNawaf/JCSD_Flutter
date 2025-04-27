import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import state, data, service and providers
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart'; // Import providers

// Default items per page
const int _serialItemsPerPage = 10; // Adjust as needed

/// Manages state for the list of serialized items belonging to a specific Product Definition.
class SerializedItemNotifier
    extends AutoDisposeFamilyAsyncNotifier<SerializedItemState, String> {
  // arg (String) is the prodDefID for this instance
  late String _prodDefID;
  Timer? _debounce; // Timer for debouncing search input

  // Helper to access the service provider
  SerialitemService get _service => ref.read(serialitemServiceProvider);

  @override
  Future<SerializedItemState> build(String arg) async {
    _prodDefID = arg; // Store the Product Definition ID for this instance
    print('SerializedItemNotifier build: prodDefID = $_prodDefID'); // Debug log

    // Cleanup debounce timer when the notifier is disposed
    ref.onDispose(() {
      _debounce?.cancel();
      print("SerializedItemNotifier (prodDefID: $_prodDefID) disposed."); // Debug log
    });

    // Initial state parameters
    const currentPage = 1;
    const itemsPerPage = _serialItemsPerPage;
    const sortBy = 'serialNumber'; // Default sort field for serials
    const ascending = true;
    const searchText = '';
    const String? statusFilter = null; // No initial status filter

    // Fetches the initial total count based on prodDefID and filters
    final totalItems = await _fetchTotalCount(
        searchText: searchText, statusFilter: statusFilter);
    final totalPages = (totalItems / itemsPerPage).ceil();
    final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

    // Fetches the data for the first page
    final items = await _fetchPageData(
      page: currentPage,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
      statusFilter: statusFilter,
    );

    // Returns the initial state object
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

  // --- Helper Methods ---

  /// Helper: Fetches total item count from the service for the current prodDefID.
  Future<int> _fetchTotalCount(
      {required String searchText, String? statusFilter}) async {
    // Calls service, passing prodDefID and other filters
    return _service.getTotalSerializedItemCount(
      prodDefID: _prodDefID,
      searchQuery: searchText,
      status: statusFilter,
      // Note: isVisible filter removed based on earlier discussion
    );
  }

  /// Helper: Fetches a specific page of data from the service for the current prodDefID.
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
      // Note: isVisible filter removed
    );
  }

  // --- UI Action Methods ---

  /// Action: Navigates to the specified page number.
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull; // Get current state data safely
    if (currentState == null || page < 1 || page > currentState.totalPages) return; // Basic validation

    // Use copyWithPrevious for smoother loading transition
    state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);
    // Use guard for cleaner async operation and error handling
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: page, // Target page
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
        statusFilter: currentState.statusFilter,
      );
      // Updates state with new items and current page number
      return currentState.copyWith(
        serializedItems: items,
        currentPage: page,
      );
    });
  }

  /// Action: Sorts the list by a column, toggling direction if needed.
  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Toggle sort direction or default to ascending for new column
    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1; // Reset page on sort

    // Use copyWithPrevious for smoother loading transition
    state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);
    // Use guard for cleaner async operation and error handling
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: newSortBy, // Use new sort column
        ascending: newAscending, // Use new sort direction
        searchText: currentState.searchText,
        statusFilter: currentState.statusFilter,
      );
      // Updates state with sorted items, new page, and sort info
      return currentState.copyWith(
        serializedItems: items,
        currentPage: newPage,
        sortBy: newSortBy,
        ascending: newAscending,
      );
    });
  }

  /// Action: Filters the list by status.
  Future<void> filterByStatus(String? newStatusFilter) async {
    final currentState = state.valueOrNull;
    // Avoid refetch if filter hasn't changed or state is invalid
    if (currentState == null || currentState.statusFilter == newStatusFilter) return;

    const newPage = 1; // Reset page on filter change
    // Use copyWithPrevious for smoother loading transition
    state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);

    try {
      // Fetch total count with the new filter
      final totalItems = await _fetchTotalCount(
          searchText: currentState.searchText, statusFilter: newStatusFilter);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      // Fetch page data with the new filter
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy, // Keep current sort
        ascending: currentState.ascending,
        searchText: currentState.searchText, // Keep current search
        statusFilter: newStatusFilter, // Apply new status filter
      );

      // Update state with new filter, items, and pagination
      state = AsyncData(currentState.copyWith( // Use AsyncData to wrap the state
        serializedItems: items,
        currentPage: newPage,
        totalPages: calculatedTotalPages,
        // Use ValueGetter trick to allow setting null
        statusFilter: () => newStatusFilter,
      ));
    } catch (e, s) {
      print("Error filtering by status ($newStatusFilter): $e"); // Log error
      // Set error state, preserving previous state if possible
      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
    }
  }

  /// Action: Updates search text and fetches results after a debounce period.
  void search(String newSearchText) {
    _debounce?.cancel(); // Cancels any existing debounce timer
    // Sets a new timer to delay the search execution
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;
      // Avoids search if state is invalid or search text hasn't changed
      if (currentState == null || currentState.searchText == newSearchText) return;

      const newPage = 1; // Reset to page 1 on search
      // Shows loading but keeps previous data visible for better UX
      state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);

      try {
        // Fetches the total count for the *new* search query first
        final totalItems = await _fetchTotalCount(
            searchText: newSearchText, statusFilter: currentState.statusFilter);
        final totalPages = (totalItems / currentState.itemsPerPage).ceil();
        final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

        // Fetches the first page of data based on the new search query
        final items = await _fetchPageData(
          page: newPage,
          itemsPerPage: currentState.itemsPerPage,
          sortBy: currentState.sortBy, // Keeps the current sort order
          ascending: currentState.ascending,
          searchText: newSearchText, // Uses the new search text
          statusFilter: currentState.statusFilter, // Keep current status filter
        );

        // Updates the state with the new items, page, search text, and total pages
        state = AsyncData(currentState.copyWith( // Use AsyncData to wrap state
          serializedItems: items,
          currentPage: newPage,
          searchText: newSearchText,
          totalPages: calculatedTotalPages,
        ));
      } catch (e, s) {
        print("Error during serial search($newSearchText): $e"); // Log search error
        // Set error state, preserving previous state if possible
        state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
      }
    });
  }

  /// Helper: Refreshes the data for the currently viewed page. Crucial after mutations.
  Future<void> refreshCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf(); // Forces rebuild if state is somehow invalid
      return;
    }

    final previousState = currentState; // Holds state for copyWith later
    // Shows loading, keeping previous data visible
    state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);

    try {
      // Recalculates total items based on current search/filters
      final totalItems = await _fetchTotalCount(
          searchText: currentState.searchText,
          statusFilter: currentState.statusFilter);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      // Adjusts page number if it becomes invalid (e.g., deleting last item)
      int pageToFetch = currentState.currentPage;
      if (pageToFetch > calculatedTotalPages) pageToFetch = calculatedTotalPages;
      if (pageToFetch < 1) pageToFetch = 1; // Ensures page doesn't go below 1

      // Fetches potentially updated data for the (possibly adjusted) current page
      final items = await _fetchPageData(
        page: pageToFetch,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
        statusFilter: currentState.statusFilter,
      );

      // Updates state with potentially new items, total pages, and adjusted current page
      state = AsyncData(previousState.copyWith( // Use AsyncData to wrap state
        serializedItems: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
        searchText: currentState.searchText, // Preserve search text
        statusFilter: () => currentState.statusFilter, // Preserve status filter
      ));
    } catch (e, s) {
      print("Error refreshing serial items page: $e"); // Log refresh error
      // Set error state, preserving previous state if possible
      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
    }
  }

  // --- Mutation Methods ---

  /// Action: Adds a new serialized item and refreshes the list.
  Future<void> addSerializedItem(SerializedItem newItem) async {
    // Ensure the newItem has the correct prodDefID before saving
    if (newItem.prodDefID != _prodDefID) {
       print("Error: Attempting to add serial with mismatched prodDefID.");
       state = AsyncError<SerializedItemState>(
               "Mismatched Product ID", StackTrace.current)
           .copyWithPrevious(state);
       return;
    }

    // Show loading indicator, keep previous data if available
    state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);
    try {
      await _service.addSerializedItem(newItem); // Call service method
      await refreshCurrentPage(); // Refresh the list view after adding
    } catch (e, s) {
      print("Error adding serialized item: $e \n$s");
      // Set error state, preserving previous state if possible
      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
      rethrow; // Re-throw to allow UI to potentially handle it further
    }
  }

  /// Action: Updates an existing serialized item (e.g., status, notes) and refreshes.
  Future<void> updateSerializedItem(SerializedItem updatedItem) async {
    // Ensure the update is for an item belonging to the current product definition
    if (updatedItem.prodDefID != _prodDefID) {
      print("Error: Attempting to update serial with mismatched prodDefID.");
      state = AsyncError<SerializedItemState>(
              "Mismatched Product ID during update", StackTrace.current)
          .copyWithPrevious(state);
      return;
    }

    // Show loading indicator, keep previous data if available
    state = AsyncLoading<SerializedItemState>().copyWithPrevious(state);
    try {
      await _service.updateSerializedItem(updatedItem); // Call service
      await refreshCurrentPage(); // Refresh the list view after updating
    } catch (e, s) {
      print("Error updating serialized item (${updatedItem.serialNumber}): $e \n$s");
      // Set error state, preserving previous state if possible
      state = AsyncError<SerializedItemState>(e, s).copyWithPrevious(state);
      rethrow; // Re-throw to allow UI to potentially handle it further
    }
  }

  /// Action: Updates the status of a specific serialized item. Convenience method.
  Future<void> updateItemStatus(String serialNumber, String newStatus) async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
       print("Cannot update status: current state is null");
       return; // Or handle error appropriately
    }

    // Find the item in the current state to update
    SerializedItem? itemToUpdate;
    try {
       itemToUpdate = currentState.serializedItems.firstWhere(
         (item) => item.serialNumber == serialNumber
       );
    } catch (e) {
       print("Item with serial $serialNumber not found in current state.");
       state = AsyncError<SerializedItemState>(
               "Item not found for status update", StackTrace.current)
           .copyWithPrevious(state);
       return; // Item not found
    }


    // Create the updated item object using copyWith
    final updatedItem = itemToUpdate.copyWith(status: newStatus);

    // Call the generic update method
    await updateSerializedItem(updatedItem);
  }

  // Note: updateSerializedItemVisibility method is removed as the 'isVisible'
  // field was removed from the data model and service.
  // Deletion/removal should be handled by updating the status (e.g., to 'Disposed').
}