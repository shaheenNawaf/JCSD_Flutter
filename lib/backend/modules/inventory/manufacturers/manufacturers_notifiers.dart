import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import state, data, service and providers
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart'; // Import providers

// Default items per page (should match service default)
const int _mfgItemsPerPage = 10;

/// Manages state for the manufacturers list view (active or archived).
class ManufacturersNotifier
    extends AutoDisposeFamilyAsyncNotifier<ManufacturersState, bool> {
  late bool _isActive; // Stores visibility context (true=active, false=archived)
  Timer? _debounce; // Timer for debouncing search input

  // Helper to access the service provider
  ManufacturersService get _service => ref.read(manufacturersServiceProvider);

  @override
  Future<ManufacturersState> build(bool arg) async {
    _isActive = arg; // Set visibility context for this notifier instance
    print('ManufacturersNotifier build: isActive = $_isActive'); // Debug log

    // Cleanup debounce timer when the notifier is disposed
    ref.onDispose(() {
      _debounce?.cancel();
      print("ManufacturersNotifier (isActive: $_isActive) disposed."); // Debug log
    });

    // Initial state parameters when the notifier is first built
    const currentPage = 1;
    const itemsPerPage = _mfgItemsPerPage;
    const sortBy = 'manufacturerName'; // Default sort field
    const ascending = true;
    const searchText = '';

    // Fetches the initial total count based on visibility and search
    final totalItems = await _fetchTotalCount(searchText: searchText);
    // Calculates the total number of pages
    final totalPages = (totalItems / itemsPerPage).ceil();
    // Ensures totalPages is at least 1, even if totalItems is 0
    final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

    // Fetches the data for the first page
    final items = await _fetchPageData(
      page: currentPage,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
    );

    // Returns the initial state object
    return ManufacturersState(
      manufacturers: items,
      currentPage: currentPage,
      totalPages: calculatedTotalPages,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
    );
  }

  // --- Helper Methods ---

  /// Helper: Fetches total item count from the service.
  Future<int> _fetchTotalCount({required String searchText}) async {
    // Calls service, passing visibility and search query
    return _service.getTotalManufacturerCount(
      isActive: _isActive,
      searchQuery: searchText,
    );
  }

  /// Helper: Fetches a specific page of data from the service.
  Future<List<ManufacturersData>> _fetchPageData({
    required int page,
    required int itemsPerPage,
    required String sortBy,
    required bool ascending,
    required String searchText,
  }) async {
    // Calls service with all necessary parameters
    return _service.fetchAllManufacturers(
      isActive: _isActive,
      page: page,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchQuery: searchText,
    );
  }

  // --- UI Action Methods ---

  /// Action: Navigates to the specified page number.
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull; // Get current state data safely
    // Prevents navigation if state is invalid or page is out of bounds
    if (currentState == null || page < 1 || page > currentState.totalPages) return;

    state = const AsyncValue.loading(); // Set loading state
    // Fetches data for the new page and updates state; handles errors
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: page, // Target page
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
      );
      // Updates state with new items and current page number
      return currentState.copyWith(
        manufacturers: items,
        currentPage: page,
      );
    });
  }

  /// Action: Sorts the list by a column, toggling direction if needed.
  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Toggles ascending state if sorting by the same column, else defaults to true
    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1; // Resets to page 1 on sort change

    state = const AsyncValue.loading(); // Set loading state
    // Fetches sorted data and updates state; handles errors
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: newSortBy, // Use the new sort column
        ascending: newAscending, // Use the new sort direction
        searchText: currentState.searchText,
      );
      // Updates state with sorted items, new page, and sort info
      return currentState.copyWith(
        manufacturers: items,
        currentPage: newPage,
        sortBy: newSortBy,
        ascending: newAscending,
      );
    });
  }

  /// Action: Updates search text and fetches results after a debounce period.
  void search(String newSearchText) {
    _debounce?.cancel(); // Cancels any existing debounce timer
    // Sets a new timer to delay the search execution
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;
      // Avoids search if state is invalid or search text hasn't changed
      if (currentState == null || currentState.searchText == newSearchText) return;

      const newPage = 1; // Resets to page 1 on search
      // Shows loading but keeps previous data visible for better UX
      state = const AsyncLoading<ManufacturersState>().copyWithPrevious(state);

      try {
        // Fetches the total count for the *new* search query first
        final totalItems = await _fetchTotalCount(searchText: newSearchText);
        final totalPages = (totalItems / currentState.itemsPerPage).ceil();
        final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

        // Fetches the first page of data based on the new search query
        final items = await _fetchPageData(
          page: newPage,
          itemsPerPage: currentState.itemsPerPage,
          sortBy: currentState.sortBy, // Keeps the current sort order
          ascending: currentState.ascending,
          searchText: newSearchText, // Uses the new search text
        );

        // Updates the state with the new items, page, search text, and total pages
        state = AsyncValue.data(currentState.copyWith(
          manufacturers: items,
          currentPage: newPage,
          searchText: newSearchText,
          totalPages: calculatedTotalPages,
        ));
      } catch (e, s) {
        print("Error during manufacturer search($newSearchText): $e"); // Log search error
        state = AsyncValue.error(e, s); // Sets error state
      }
    });
  }

  /// Helper: Refreshes the data for the currently viewed page. Crucial after mutations.
  Future<void> _refreshCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf(); // Forces rebuild if state is somehow invalid
      return;
    }

    final previousState = currentState; // Holds state for copyWith later
    // Shows loading, keeping previous data visible
    state = const AsyncLoading<ManufacturersState>().copyWithPrevious(state);

    try {
      // Recalculates total items based on current search/filters
      final totalItems = await _fetchTotalCount(searchText: currentState.searchText);
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
      );

      // Updates state with potentially new items, total pages, and adjusted current page
      state = AsyncValue.data(previousState.copyWith(
        manufacturers: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
        searchText: currentState.searchText, // Preserve search text
      ));
    } catch (e, s) {
      print("Error refreshing manufacturers page: $e"); // Log refresh error
      state = AsyncValue.error(e, s); // Set error state
    }
  }

  // --- Mutation Methods ---

  /// Action: Adds a new manufacturer and refreshes the list.
  Future<void> addManufacturer({
    required String manufacturerName,
    required String manufacturerEmail,
    required String contactNumber,
    required String address,
  }) async {
    state = const AsyncValue.loading(); // Indicate loading
    // Uses guard for simple async operation + error handling
    state = await AsyncValue.guard(() async {
      // Calls service method
      await _service.addNewManufacturer(
          manufacturerName: manufacturerName,
          manufacturerEmail: manufacturerEmail,
          contactNumber: contactNumber,
          address: address);
      ref.invalidateSelf(); // Invalidates self to trigger rebuild and fetch fresh data
      return state.value!; // return previous state conceptually for guard
    });
    // NOTE: Could use `await _refreshCurrentPage();` instead of invalidateSelf for potentially smoother UI
  }

  /// Action: Updates an existing manufacturer and refreshes the list.
  Future<void> updateManufacturer({
    required int manufacturerID,
    required String manufacturerName,
    required String manufacturerEmail,
    required String contactNumber,
    required String address,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateManufacturer( // Call service
          manufacturerID: manufacturerID,
          manufacturerName: manufacturerName,
          manufacturerEmail: manufacturerEmail,
          contactNumber: contactNumber,
          address: address);
      ref.invalidateSelf(); // Invalidate to refresh
      return state.value!;
    });
    // NOTE: Could use `await _refreshCurrentPage();` instead
  }

  /// Action: Updates visibility (archives/unarchives) and refreshes relevant lists.
  Future<void> updateManufacturerVisibility({
    required int manufacturerID,
    required bool newIsActive,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return; // Safety check

    // Set loading state, keeping previous data
    state = const AsyncLoading<ManufacturersState>().copyWithPrevious(state);
    try {
      // Perform the update via the service
      await _service.updateManufacturerVisibility(
          manufacturerID: manufacturerID, isActive: newIsActive);

      // Crucially, invalidate the *other* family instance
      ref.invalidate(manufacturersNotifierProvider(!_isActive)); // Use !_isActive for the opposite context

      // Refresh the *current* state's view
      await _refreshCurrentPage();
    } catch (e, s) {
      print("Error setting manufacturer visibility for ID $manufacturerID: $e"); // Log error
      state = AsyncValue.error(e, s); // Set error state
    }
  }
}