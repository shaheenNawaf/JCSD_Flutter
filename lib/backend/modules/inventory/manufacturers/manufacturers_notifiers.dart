import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Default Imports
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';

const int _mfgItemsPerPage = 10; //Default Limit

class ManufacturersNotifier
    extends AutoDisposeFamilyAsyncNotifier<ManufacturersState, bool> {
  late bool _isActive;
  Timer? _debounce;

  ManufacturersService get _service => ref.read(manufacturersServiceProvider);

  @override
  Future<ManufacturersState> build(bool arg) async {
    _isActive = arg; // Set visibility context for this notifier instance
    print('ManufacturersNotifier build: isActive = $_isActive'); // Debug log

    // Cleanup debounce timer when the notifier is disposed
    ref.onDispose(() {
      _debounce?.cancel();
      print(
          "ManufacturersNotifier (isActive: $_isActive) disposed."); // Debug log
    });

    // Initial state parameters when the notifier is first built
    const currentPage = 1;
    const itemsPerPage = _mfgItemsPerPage;
    const sortBy = 'manufacturerName'; // Default sort field
    const ascending = true;
    const searchText = '';

    final totalItems = await _fetchTotalCount(searchText: searchText);
    final totalPages = (totalItems / itemsPerPage).ceil();
    final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

    final items = await _fetchPageData(
      page: currentPage,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
    );

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

  // Helper Methods

  Future<int> _fetchTotalCount({required String searchText}) async {
    return _service.getTotalManufacturerCount(
      isActive: _isActive,
      searchQuery: searchText,
    );
  }

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

  // UI Action Methods

  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull;

    if (currentState == null || page < 1 || page > currentState.totalPages) {
      return;
    }

    state = const AsyncValue.loading(); // Set loading state

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

  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Ascending state conditional
    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1; // resets on page one, every time it changes

    state = const AsyncValue.loading();

    //Used guard for proper data handling
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: newSortBy, // update for the new sort column
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

  /// Action: Search functionality, always active
  void search(String newSearchText) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;
      // Avoids search if state is invalid or search text hasn't changed
      if (currentState == null || currentState.searchText == newSearchText) {
        return;
      }

      const newPage = 1;
      state = const AsyncLoading<ManufacturersState>().copyWithPrevious(state);

      try {
        final totalItems = await _fetchTotalCount(searchText: newSearchText);
        final totalPages = (totalItems / currentState.itemsPerPage).ceil();
        final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

        final items = await _fetchPageData(
          page: newPage,
          itemsPerPage: currentState.itemsPerPage,
          sortBy: currentState.sortBy,
          ascending: currentState.ascending,
          searchText: newSearchText,
        );

        state = AsyncValue.data(currentState.copyWith(
          manufacturers: items,
          currentPage: newPage,
          searchText: newSearchText,
          totalPages: calculatedTotalPages,
        ));
      } catch (e, s) {
        print(
            "Error during manufacturer search($newSearchText): $e"); // Log search error
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
      final totalItems =
          await _fetchTotalCount(searchText: currentState.searchText);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      // Adjusts page number if it becomes invalid (e.g., deleting last item)
      int pageToFetch = currentState.currentPage;
      if (pageToFetch > calculatedTotalPages) {
        pageToFetch = calculatedTotalPages;
      }
      if (pageToFetch < 1) pageToFetch = 1; // Ensures page doesn't go below 1

      final items = await _fetchPageData(
        page: pageToFetch,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
      );

      state = AsyncValue.data(previousState.copyWith(
        manufacturers: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
        searchText: currentState.searchText, // Preserve search text
      ));
    } catch (e, s) {
      print("Error refreshing manufacturers page: $e"); // Log refresh error
      state = AsyncValue.error(e, s);
    }
  }

  // Action Methods

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
      await _service.updateManufacturer(
          // Call service
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
      ref.invalidate(manufacturersNotifierProvider(
          !_isActive)); // Use !_isActive for the opposite context

      // Refresh the *current* state's view
      await _refreshCurrentPage();
    } catch (e, s) {
      print(
          "Error setting manufacturer visibility for ID $manufacturerID: $e"); // Log error
      state = AsyncValue.error(e, s); // Set error state
    }
  }
}
