import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';

class InventoryState {
  final List<InventoryData> originalData;
  final List<InventoryData> filteredData;
  final String searchText;
  final SortState sortState;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final SortColumn sortedColumn;
  final bool isLoading;
  final String? error;
  final String sortBy;
  final bool ascending;

  InventoryState({
    required this.originalData,
    required this.filteredData,
    this.searchText = '',
    this.sortState = SortState.none,
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = 10,
    this.sortedColumn = SortColumn.none,
    this.isLoading = true,
    this.sortBy = 'itemID',
    this.ascending = true,
    this.error,
  }); //fuk u semi-colon kulang what the fuck

  InventoryState copyWith({
    List<InventoryData>? originalData,
    List<InventoryData>? filteredData,
    String? searchText,
    SortState? sortState,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    SortColumn? sortedColumn,
    bool? isLoading,
    String? error,
    String? sortBy,
    bool? ascending,
  }) {
    return InventoryState(
      originalData: originalData ?? this.originalData,
      filteredData: filteredData ?? this.filteredData,
      searchText: searchText ?? this.searchText,
      sortState: sortState ?? this.sortState,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortedColumn: sortedColumn ?? this.sortedColumn,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

// ----- NOTES ----- //
// ?? -- Null-aware, used to provide default values, acts like an if-else statement

enum SortState {
  itemIDAscending,
  itemIDDesending,
  itemNameAscending,
  itemNameDesending,
  itemTypeAscending,
  itemTypeDescending,
  priceAscending,
  priceDescending,
  supplierAscending,
  supplierDescending,
  quantityAscending,
  quantityDescending,
  none
}

enum SortColumn {
  itemID,
  itemName,
  supplier,
  quantity,
  none,
}
