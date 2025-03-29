import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';

class InventoryState {
<<<<<<< HEAD
  final List<InventoryData> filteredData;
  final String searchText;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
=======
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
>>>>>>> 49dc13d8939539466207ab9f7a016d3ee4ca401c
  final String sortBy;
  final bool ascending;

  InventoryState({
<<<<<<< HEAD
    this.filteredData = const [],
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = 10,
    this.sortBy = 'itemID',
    this.ascending = true,
  }); //fuk u semi-colon kulang what the fuck

  InventoryState copyWith({
    List<InventoryData>? filteredData,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
=======
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
>>>>>>> 49dc13d8939539466207ab9f7a016d3ee4ca401c
    String? sortBy,
    bool? ascending,
  }) {
    return InventoryState(
<<<<<<< HEAD
      filteredData: filteredData ?? this.filteredData,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
=======
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
>>>>>>> 49dc13d8939539466207ab9f7a016d3ee4ca401c
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

// ----- NOTES ----- //
// ?? -- Null-aware, used to provide default values, acts like an if-else statement

<<<<<<< HEAD
// enum SortState {
//   itemIDAscending,
//   itemIDDesending,
//   itemNameAscending,
//   itemNameDesending,
//   itemTypeAscending,
//   itemTypeDescending,
//   priceAscending,
//   priceDescending,
//   supplierAscending,
//   supplierDescending,
//   quantityAscending,
//   quantityDescending,
//   none
// }

// enum SortColumn {
//   itemID,
//   itemName,
//   supplier,
//   quantity,
//   none,
// }
=======
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
>>>>>>> 49dc13d8939539466207ab9f7a016d3ee4ca401c
