import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For FetchOptions

// Import state, data, service and providers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // Updated state file
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // Import the providers defined in the state file

// Default items per page
const int _supplierItemsPerPage = 10; // Adjust as needed

/// Manages state for the suppliers list view (active or archived).
class SuppliersNotifier
    extends AutoDisposeFamilyAsyncNotifier<SuppliersState, bool> {
  late bool _isActive; // Stores visibility context (true=active, false=archived)
  Timer? _debounce; // Timer for debouncing search input

  // Helper to access the service provider
  SuppliersService get _service => ref.read(suppliersServiceProvider);

  // --- Build Method ---
  @override
  Future<SuppliersState> build(bool arg) async {
    _isActive = arg; // Set visibility context
    print('SuppliersNotifier build: isActive = $_isActive');

    ref.onDispose(() {
      _debounce?.cancel();
      print("SuppliersNotifier (isActive: $_isActive) disposed.");
    });

    // Initial state parameters
    const currentPage = 1;
    const itemsPerPage = _supplierItemsPerPage;
    const sortBy = 'supplierName'; // Default sort
    const ascending = true;
    const searchText = '';

    // Fetch initial count and data
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

    // Return the initial state
    return SuppliersState(
      suppliers: items,
      currentPage: currentPage,
      totalPages: calculatedTotalPages,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchText: searchText,
    );
  }

  // --- Helper Methods ---

  /// Helper: Fetches total supplier count from the service.
  Future<int> _fetchTotalCount({required String searchText}) async {
    // Adapting service call - getTotalSupplierCount needs filters similar to Manufacturers
    // TEMPORARY: Using fetch + length until service is updated
    // TODO: Update SuppliersService to have an efficient getTotalCount method with filters
     try {
      final results = await _service.fetchSuppliersFiltered( // Assumes fetchSuppliersFiltered exists/is added
        isActive: _isActive,
        searchQuery: searchText,
      );
      return results.length;
     } catch(e) {
       print("Error getting supplier count (using fetch): $e");
       return 0;
     }
     // Ideal (after updating service):
     // return _service.getTotalSupplierCount(isActive: _isActive, searchQuery: searchText);
  }

  /// Helper: Fetches a specific page of supplier data from the service.
  Future<List<SuppliersData>> _fetchPageData({
    required int page,
    required int itemsPerPage,
    required String sortBy,
    required bool ascending,
    required String searchText,
  }) async {
    // Adapt service call - Needs a method similar to fetchAllManufacturers
    // TODO: Update SuppliersService to have a fetch method with search/sort/pagination
    return _service.fetchSuppliersFiltered( // Assumes fetchSuppliersFiltered exists/is added
      isActive: _isActive,
      page: page,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchQuery: searchText,
    );
    // Ideal (after updating service):
    // return _service.fetchAllSuppliers(
    //   isActive: _isActive,
    //   page: page,
    //   itemsPerPage: itemsPerPage,
    //   sortBy: sortBy,
    //   ascending: ascending,
    //   searchQuery: searchText,
    // );
  }

  // --- UI Action Methods (Adapted from ManufacturersNotifier) ---

  /// Action: Navigates to the specified page number.
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull;
    if (currentState == null || page < 1 || page > currentState.totalPages) return;

    state = AsyncLoading<SuppliersState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: page,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
      );
      return currentState.copyWith(
        suppliers: items,
        currentPage: page,
      );
    });
  }

  /// Action: Sorts the list by a column, toggling direction if needed.
  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1;

    state = AsyncLoading<SuppliersState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: newSortBy,
        ascending: newAscending,
        searchText: currentState.searchText,
      );
      return currentState.copyWith(
        suppliers: items,
        currentPage: newPage,
        sortBy: newSortBy,
        ascending: newAscending,
      );
    });
  }

  /// Action: Updates search text and fetches results after a debounce period.
  void search(String newSearchText) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;
      if (currentState == null || currentState.searchText == newSearchText) return;

      const newPage = 1;
      state = AsyncLoading<SuppliersState>().copyWithPrevious(state);

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

        state = AsyncData(currentState.copyWith(
          suppliers: items,
          currentPage: newPage,
          searchText: newSearchText,
          totalPages: calculatedTotalPages,
        ));
      } catch (e, s) {
        print("Error during supplier search($newSearchText): $e");
        state = AsyncError<SuppliersState>(e, s).copyWithPrevious(state);
      }
    });
  }

  /// Helper: Refreshes the data for the currently viewed page.
  Future<void> _refreshCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }

    final previousState = currentState;
    state = AsyncLoading<SuppliersState>().copyWithPrevious(state);

    try {
      final totalItems = await _fetchTotalCount(searchText: currentState.searchText);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      int pageToFetch = currentState.currentPage;
      if (pageToFetch > calculatedTotalPages) pageToFetch = calculatedTotalPages;
      if (pageToFetch < 1) pageToFetch = 1;

      final items = await _fetchPageData(
        page: pageToFetch,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
      );

      state = AsyncData(previousState.copyWith(
        suppliers: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
        searchText: currentState.searchText,
      ));
    } catch (e, s) {
      print("Error refreshing suppliers page: $e");
      state = AsyncError<SuppliersState>(e, s).copyWithPrevious(state);
    }
  }

  // --- Mutation Methods ---

  /// Action: Adds a new supplier and refreshes the list.
  Future<void> addSupplier({
    required String supplierName,
    required String supplierEmail,
    required String contactNumber,
    required String address,
  }) async {
    state = const AsyncLoading<SuppliersState>().copyWithPrevious(state);
    try {
      await _service.addSupplier( // Assuming service method name
          supplierName: supplierName,
          supplierEmail: supplierEmail,
          contactNumber: contactNumber,
          address: address);
      await _refreshCurrentPage();
    } catch (e, s) {
       print("Error adding supplier: $e \n$s");
       state = AsyncError<SuppliersState>(e, s).copyWithPrevious(state);
       rethrow;
    }
  }

  /// Action: Updates an existing supplier and refreshes the list.
  Future<void> updateSupplier({
    required int supplierID,
    required String supplierName,
    required String supplierEmail,
    required String contactNumber,
    required String address,
  }) async {
    state = const AsyncLoading<SuppliersState>().copyWithPrevious(state);
    try {
      await _service.updateSupplier( // Assuming service method name
          supplierID: supplierID,
          supplierName: supplierName,
          supplierEmail: supplierEmail,
          contactNumber: contactNumber,
          address: address);
      await _refreshCurrentPage();
    } catch (e, s) {
       print("Error updating supplier ($supplierID): $e \n$s");
       state = AsyncError<SuppliersState>(e, s).copyWithPrevious(state);
       rethrow;
    }
  }

  /// Action: Updates visibility (archives/unarchives) and refreshes relevant lists.
  Future<void> updateSupplierVisibility({
    required int supplierID,
    required bool newIsActive,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncLoading<SuppliersState>().copyWithPrevious(state);
    try {
      await _service.updateSupplierVisbility( // Assuming service method name
          supplierID: supplierID, isActive: newIsActive);

      // Invalidate the *other* family instance
      ref.invalidate(suppliersNotifierProvider(!_isActive));

      // Refresh the *current* state's view
      await _refreshCurrentPage();
    } catch (e, s) {
      print("Error setting supplier visibility for ID $supplierID: $e");
      state = AsyncError<SuppliersState>(e, s).copyWithPrevious(state);
      rethrow;
    }
  }
}