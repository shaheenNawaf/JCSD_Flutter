import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

class InventoryNotifier extends StateNotifier<InventoryState> {
  final Ref ref;
  bool isVisible =
      true; //Default state, unless stated for archived items display

  InventoryNotifier(this.ref, this.isVisible)
      : super(InventoryState(
          originalData: [],
          filteredData: [],
          searchText: '',
          sortState: SortState.none,
          isLoading: true,
          error: null,
        )) {
    _init();
  }

  Future<void> _init() async {
    await _fetchInventoryData();
  }

  //Update - 03/18 - Now simplified and handling both active states para isa ray method oy!
  Future<void> _fetchInventoryData(
      {int page = 1, String? sortBy, bool? ascending}) async {
    try {
      final items = await ref.read(inventoryServiceProv).fetchItems(
          isVisible: isVisible,
          page: page,
          sortBy: sortBy ?? state.sortBy,
          ascending: ascending ?? state.ascending,
          itemsPerPage: state.itemsPerPage);

      final totalItems;

      if (isVisible) {
        totalItems =
            await ref.read(inventoryServiceProv).totalActiveItemCount();
      } else {
        totalItems =
            await ref.read(inventoryServiceProv).totalArchivedItemCount();
      }

      final totalPages = (totalItems / state.itemsPerPage).ceil();
      //.ceil - auto-round UP to the whole number

      state = state.copyWith(
        originalData: items,
        filteredData: items,
        currentPage: page,
        totalPages: totalPages,
        isLoading: false,
        sortBy: state.sortBy,
        ascending: state.ascending,
      );
    } catch (error, stackTrace) {
      print(
          'Trouble accessing active inventory items. Error: $error \n Traced to: $stackTrace');
      state = state.copyWith(isLoading: false, error: "Error fetching data.");
    }
  }

  void sortItems(String sortBy) {
    bool ascending = state.ascending;
    if (state.sortBy == sortBy) {
      ascending = !state.ascending;
    }

    state = state.copyWith(sortBy: sortBy, ascending: ascending);

    _fetchInventoryData(
      page: state.currentPage,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  void searchItems(String searchText) async {
    state =
        state.copyWith(searchText: searchText, isLoading: true, error: null);

    try {
      List<InventoryData> searchedItems =
          await ref.read(inventoryServiceProv).searchItems(
                isVisible: isVisible,
                ascending: state.ascending,
                sortBy: state.sortBy,
                itemName: searchText,
                itemID: int.tryParse(searchText),
                itemType: searchText,
                page: state.currentPage,
                itemsPerPage: state.itemsPerPage,
              );

      //Just to display the visible items -- active items -- hardcoded muna
      searchedItems =
          searchedItems.where((items) => items.isVisible == true).toList();

      state = state.copyWith(filteredData: searchedItems, isLoading: false);
    } catch (error, stackTrace) {
      print(
          'Trouble searching the item. Error: $error \n Traced to: $stackTrace');
      state = state.copyWith(isLoading: false, error: 'Erro searching ');
    }
  }

  // Pagination Functions - don't touch pls
  void goToPage(int page) {
    _fetchInventoryData(
        page: page, sortBy: state.sortBy, ascending: state.ascending);
  }

  void goToNextPage(int page) {
    if (state.currentPage < state.totalPages) {
      goToPage(state.currentPage + 1);
    }
  }

  void goToPreviousPage(int page) {
    if (state.currentPage > 1) {
      goToPage(state.currentPage - 1);
    }
  }
}

// Ignore
// void sortItems(SortState sortState) {
  //   //Param is used inside the copyWith method to be processed (broken down) and accessible here
  //   state = state.copyWith(sortState: sortState);

  //   final sortedData = [...state.filteredData];

  //   switch (sortState) {
  //     case SortState.quantityAscending:
  //       sortedData.sort((a, b) => a.itemQuantity.compareTo(b.itemQuantity));
  //     case SortState.quantityDescending:
  //       sortedData.sort((a, b) => b.itemQuantity.compareTo(a.itemQuantity));
  //     case SortState.itemNameAscending:
  //       sortedData.sort((a, b) => a.itemName.compareTo(b.itemName));
  //     case SortState.itemNameDesending:
  //       sortedData.sort((a, b) => b.itemName.compareTo(a.itemName));
  //     case SortState.supplierAscending:
  //       sortedData.sort((a, b) => a.supplierID.compareTo(b.supplierID));
  //     case SortState.supplierDescending:
  //       sortedData.sort((a, b) => b.supplierID.compareTo(a.supplierID));
  //     default:
  //       break;
  //   }
  //   state = state.copyWith(filteredData: sortedData); //For viewing
  // }

