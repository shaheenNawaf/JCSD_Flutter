import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';



import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_services.dart'; // Assuming service provider is here

// Import the other provider for invalidation (adjust path)
// import 'package:jcsd_flutter/backend/modules/inventory/serialized_item_notifier.dart'; // We'll need this later if archiving affects serial counts

// Default items per page
const int _pdItemsPerPage = 10; // Use a specific const

/// Notifier responsible for managing the state of the Product Definitions list view.
/// Parameterized by 'isVisible' flag (true for active, false for archived definitions).
class ProductDefinitionNotifier extends AutoDisposeFamilyAsyncNotifier<ProductDefinitionState, bool> {

  // Store the visibility status for this instance
  late bool _isVisible;

  // Debouncer timer for search
  Timer? _debounce;

  // Helper to easily access the ProductDefinitionService
  // Assumes productDefinitionServiceProv exists in inventory_providers.dart
  ProductDefinitionServices get _service => ref.read(productDefinitionServiceProv);

  @override
  Future<ProductDefinitionState> build(bool arg) async {
    _isVisible = arg; // Store visibility context
    print('ProductDefinitionNotifier build: Running for isVisible = $arg');

    // Register debouncer cleanup
    ref.onDispose(() {
      _debounce?.cancel();
      print("ProductDefinitionNotifier (isVisible: $_isVisible) disposed.");
    });

    // Define initial parameters
    const currentPage = 1;
    const itemsPerPage = _pdItemsPerPage;
    const sortBy = 'prodDefName'; // Default sort
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

  // --- Helper Methods for Fetching Data ---

  /// Fetches the total count from the service.
  Future<int> _fetchTotalCount({required String searchText}) async {
    // Calls the service method, passing visibility and search query
    return _service.getTotalProductDefinitionCount(
        isVisible: _isVisible,
        searchQuery: searchText,
        // Pass other filters like itemTypeID, manufacturerID if they are applied globally
    );
  }

  /// Fetches a specific page of data from the service.
  Future<List<ProductDefinitionData>> _fetchPageData({
    required int page,
    required int itemsPerPage,
    required String sortBy,
    required bool ascending,
    required String searchText,
  }) async {
    // Calls the service method with all necessary parameters
    return _service.fetchProductDefinitions(
      isVisible: _isVisible,
      page: page,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchQuery: searchText,
      // Pass other filters if needed
    );
  }

  // --- UI Action Methods ---

  /// Navigates to a specific page number.
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull;
    if (currentState == null || page < 1 || page > currentState.totalPages) return;

    state = const AsyncValue.loading();
    // Use guard for simpler state update after single fetch
    state = await AsyncValue.guard(() async {
       final items = await _fetchPageData(
         page: page,
         itemsPerPage: currentState.itemsPerPage,
         sortBy: currentState.sortBy,
         ascending: currentState.ascending,
         searchText: currentState.searchText,
       );
       // Return the new state using copyWith
       return currentState.copyWith(
         productDefinitions: items,
         currentPage: page,
       );
    });
  }

  /// Sorts the data by the specified column.
  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newAscending = currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1; // Reset to page 1 on sort

    state = const AsyncValue.loading();
    // Use guard for simpler state update after single fetch
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        page: newPage,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: newSortBy, // Use new sort field
        ascending: newAscending, // Use new sort direction
        searchText: currentState.searchText,
      );
      // Return the new state using copyWith
      return currentState.copyWith(
        productDefinitions: items,
        currentPage: newPage,
        sortBy: newSortBy,
        ascending: newAscending,
      );
    });
  }

   /// Searches items based on the provided query with debouncing.
  void search(String newSearchText) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () async {
          final currentState = state.valueOrNull;
          if (currentState == null || currentState.searchText == newSearchText) return;

          const newPage = 1;
          // Keep previous data while loading new search for smoother UX
          state = AsyncLoading<ProductDefinitionState>().copyWithPrevious(state);

          try {
              // Fetch total count FIRST for the new search
              final totalItems = await _fetchTotalCount(searchText: newSearchText);
              final totalPages = (totalItems / currentState.itemsPerPage).ceil();
              final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

              // Fetch page data based on the new search
              final items = await _fetchPageData(
                  page: newPage,
                  itemsPerPage: currentState.itemsPerPage,
                  sortBy: currentState.sortBy, // Keep current sort
                  ascending: currentState.ascending,
                  searchText: newSearchText,
              );

              // Update state with results
              state = AsyncValue.data(currentState.copyWith(
                  productDefinitions: items,
                  currentPage: newPage,
                  searchText: newSearchText,
                  totalPages: calculatedTotalPages,
              ));
          } catch (e, s) {
              print("Error in search($newSearchText): $e");
              state = AsyncValue.error(e, s);
          }
      });
  }

  /// Refreshes the data for the current page.
  Future<void> _refreshCurrentPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf(); // Trigger rebuild if state is invalid
      return;
    }

    final previousState = currentState; // Keep for copyWith
    // Show loading but keep previous data visible if possible
    state = AsyncLoading<ProductDefinitionState>().copyWithPrevious(state);

    try {
      // Recalculate total items based on current search
      final totalItems = await _fetchTotalCount(searchText: currentState.searchText);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;

      // Adjust page number if current page becomes invalid
      int pageToFetch = currentState.currentPage;
      if (pageToFetch > calculatedTotalPages) pageToFetch = calculatedTotalPages;
      if (pageToFetch < 1) pageToFetch = 1;

      // Fetch data for the correct page
      final items = await _fetchPageData(
        page: pageToFetch,
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy,
        ascending: currentState.ascending,
        searchText: currentState.searchText,
      );

      // Update state using copyWith on previous state
      state = AsyncValue.data(previousState.copyWith(
        productDefinitions: items,
        totalPages: calculatedTotalPages,
        currentPage: pageToFetch,
      ));
    } catch (e, s) {
      print("Error refreshing current page: $e");
      state = AsyncValue.error(e, s); // Set error state
    }
  }

  // --- Mutation Methods ---

  /// Adds a new product definition and refreshes the list.
  Future<void> addProductDefinition(ProductDefinitionData newProduct) async {
     // Using guard might be okay here if success doesn't require complex state merge
     state = const AsyncValue.loading(); // Optional: show global loading
     state = await AsyncValue.guard(() async {
        await _service.addProductDefinition(newProduct);
        // After adding, trigger a full refresh to ensure correct sorting/pagination
        // Or could try optimistic update + targeted refresh, but full refresh is simpler
        ref.invalidateSelf(); // Invalidate self to trigger build and fetch fresh data
        return state.value!; // Need to return the previous state conceptually for guard
        // NOTE: Invalidating might feel abrupt. Manual refresh might be better UX.
     });
     // Alternative: Manual refresh for potentially better UX
     // try {
     //   await _service.addProductDefinition(newProduct);
     //   await _refreshCurrentPage(); // Refresh the view
     // } catch (e, s) { state = AsyncValue.error(e, s); }
  }

  /// Updates an existing product definition and refreshes.
  Future<void> updateProductDefinition(ProductDefinitionData updatedProduct) async {
     // Similar logic to add - invalidate or refresh
     state = const AsyncValue.loading();
     state = await AsyncValue.guard(() async {
        await _service.updateProductDefinition(updatedProduct);
        ref.invalidateSelf();
        return state.value!;
     });
     // Or: Manual refresh
     // try {
     //   await _service.updateProductDefinition(updatedProduct);
     //   await _refreshCurrentPage();
     // } catch (e, s) { state = AsyncValue.error(e, s); }
  }

  /// Updates the visibility of a product definition and refreshes/invalidates.
  Future<void> updateProductDefinitionVisibility(String prodDefID, bool newVisibility) async {
     final currentState = state.valueOrNull;
     if (currentState == null) return;
     state = AsyncLoading<ProductDefinitionState>().copyWithPrevious(state);
     try {
        await _service.updateProductDefinitionVisibility(prodDefID, newVisibility);
        // Invalidate the *other* visibility state's notifier
        ref.invalidate(productDefinitionNotifierProvider(!_isVisible)); // Use the correct provider name
        // Refresh the current state
        await _refreshCurrentPage();
     } catch (e, s) {
        print("Error setting product definition visibility for $prodDefID: $e");
        state = AsyncValue.error(e, s);
     }
  }

}