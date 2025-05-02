import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_data.dart';

class InventoryState {
  final List<InventoryData> filteredData;
  final String searchText;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final String sortBy;
  final bool ascending;

  InventoryState({
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
    String? sortBy,
    bool? ascending,
  }) {
    return InventoryState(
      filteredData: filteredData ?? this.filteredData,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}
