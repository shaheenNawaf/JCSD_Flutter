import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_services.dart';

// Default items per page (consider moving to a config file later)
const int _pdItemsPerPage = 10;

/// Notifier provider for managing Product Definitions (Active/Archived). Family param bool: true=Active, false=Archived.
final productDefinitionNotifierProvider =
    AutoDisposeAsyncNotifierProviderFamily<ProductDefinitionNotifier,
        ProductDefinitionState, bool>(
  () => ProductDefinitionNotifier(),
);

/// Manages state for the product definition list view (active or archived).
class ProductDefinitionNotifier
    extends AutoDisposeFamilyAsyncNotifier<ProductDefinitionState, bool> {
  late bool
      _isVisible; // Stores visibility context (true=active, false=archived)
  Timer? _debounce; // Timer for debouncing search input

  // Helper to easily access the ProductDefinitionService
  ProductDefinitionServices get _service =>
      ref.read(productDefinitionServiceProv); // Reads the service provider

  @override
  Future<ProductDefinitionState> build(bool arg) async {
    _isVisible =
        arg; // Stores the family parameter (true for active, false for archived)
    print(
        'ProductDefinitionNotifier build: isVisible = $_isVisible'); // Debug log

    // Cleans up the debounce timer when the notifier is disposed
    ref.onDispose(() {
      _debounce?.cancel();
      print(
          "ProductDefinitionNotifier (isVisible: $_isVisible) disposed."); // Debug log
    });

    // Initial state parameters when the notifier is first built
    const currentPage = 1;
    const itemsPerPage = _pdItemsPerPage;
    const sortBy = 'prodDefName'; // Default sort field
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
    return ProductDefinitionState(
      productDefinitions: items,
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
    return _service.getTotalProductDefinitionCount(
      isVisible: _isVisible,
      searchQuery: searchText,
      // Pass other filters like itemTypeID, manufacturerID if needed later
    );
  }

  /// Helper: Fetches a specific page of data from the service.
  Future<List<ProductDefinitionData>> _fetchPageData({
    required int page,
    required int itemsPerPage,
    required String sortBy,
    required bool ascending,
    required String searchText,
  }) async {
    // Calls service with all necessary parameters
    return _service.fetchProductDefinitions(
      isVisible: _isVisible,
      page: page,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchQuery: searchText,
      // Pass other filters if needed later
    );
  }

  // --- UI Action Methods ---

  /// Action: Navigates to the specified page number.
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull; // Get current state data safely
    // Prevents navigation if state is invalid or page is out of bounds
    if (currentState == null || page < 1 || page > currentState.totalPages) {
      return;
    }

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
        productDefinitions: items,
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
        productDefinitions: items,
        currentPage: newPage,
        sortBy: newSortBy,
        ascending: newAscending,
      );
    });
  }

  void search(String newSearchText) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state.valueOrNull;

      // Avoids search if state is invalid or search text hasn't changed
      if (currentState == null || currentState.searchText == newSearchText) {
        return;
      }

      const newPage = 1;

      // Shows loading but keeps previous data visible for better UX
      state =
          const AsyncLoading<ProductDefinitionState>().copyWithPrevious(state);

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
          productDefinitions: items,
          currentPage: newPage,
          searchText: newSearchText,
          totalPages: calculatedTotalPages,
        ));
      } catch (e, s) {
        print("Error during search($newSearchText): $e"); // Logs search error
        state = AsyncValue.error(e, s); // Sets error state
      }
    });
  }

  /// Helper Function: for force refreshing of the page and then the state
  Future<void> _refreshCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf(); // Forces rebuild if state is somehow invalid
      return;
    }

    final previousState = currentState; // Holds state for copyWith later

    // Shows loading, keeping previous data visible
    state =
        const AsyncLoading<ProductDefinitionState>().copyWithPrevious(state);

    try {
      final totalItems =
          await _fetchTotalCount(searchText: currentState.searchText);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      // Auto-adjust page number based on the actions done; if naay mag-delete ensuring it doesn't go over the index
      int pageToFetch = currentState.currentPage;
      if (pageToFetch > calculatedTotalPages) {
        pageToFetch = calculatedTotalPages;
      }
      if (pageToFetch < 1) pageToFetch = 1; // Ensures page doesn't go below 1

      // Fetches potentially updated data for the (possibly adjusted) current page
      final items = await _fetchPageData(
        page: pageToFetch,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
      );

      //For updating the state
      state = AsyncValue.data(previousState.copyWith(
        productDefinitions: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
        searchText: currentState.searchText,
      ));
    } catch (e, s) {
      print("Error refreshing current page: $e");
      state = AsyncValue.error(e, s);
    }
  }

  // CRUD Functionalities (Auto-refresh after adding)

  Future<void> addProductDefinition(
      ProductDefinitionData newProductDefinition) async {
    state = const AsyncValue.loading(); // Set global loading (optional)

    // Uses guard for async operation and error handling
    state = await AsyncValue.guard(() async {
      await _service
          .addProductDefinition(newProductDefinition); // Calls service
      ref.invalidateSelf(); // Invalidates self to trigger rebuild and fetch fresh data
      return state.value!; // Return previous state conceptually for guard
    });

    // replace with `await _refreshCurrentPage();` for smoother UI
  }

  Future<void> updateProductDefinition(
      ProductDefinitionData updatedProduct) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateProductDefinition(updatedProduct); // Calls service
      ref.invalidateSelf();
      return state.value!;
    });
    // NOTE: Could use `await _refreshCurrentPage();` instead
  }

  Future<void> updateProductDefinitionVisibility(
      String prodDefID, bool newVisibility) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state =
        const AsyncLoading<ProductDefinitionState>().copyWithPrevious(state);

    try {
      await _service.updateProductDefinitionVisibility(
          prodDefID, newVisibility);

      //Force refresh again
      ref.invalidate(productDefinitionNotifierProvider(!_isVisible));

      //Force refresh ni for the page to ensure fresh state is displayed
      await _refreshCurrentPage();
    } catch (e, s) {
      print("Error setting PD visibility for $prodDefID: $e"); // Log error
      state = AsyncValue.error(e, s); // Set error state
    }
  }
}
