//General Note for Shaheen:

import 'dart:async';
import 'dart:core';

import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports, handling the state
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/unused_forcleaning/inventory_state.dart';

const int _defaultItemsPerPage = 10;

class InventoryNotifier extends AutoDisposeFamilyAsyncNotifier<InventoryState, bool> {
  Timer? _debounce; //Mainly for performance, iwas continuous activity especially on search na persistent ang textfield

  late bool _isVisible; //Just to store which to access, based on property
  InventoryService get _accessServices => ref.read(inventoryServiceProv);

  @override
  Future<InventoryState> build(bool arg) async {
    _isVisible = arg;

    ref.onDispose((){
    _debounce?.cancel();
    print('Debounce timer cancelled.');
    });

    //initial parameters for the loaded state
    const currentPage = 1;
    const itemsPerPage = _defaultItemsPerPage;
    const searchText = '';
    const sortBy = 'itemID';
    const ascending = true;

    //Fetching the total item count
    final totalItems = await fetchTotalItemCount(searchText: searchText);

    //Calculating the total pages bbased on set items to be displayed
    final totalPages = totalItems <= 0 ? 1 : (totalItems/itemsPerPage).ceil();

    //Diri mabutang ang data for the first page
    final fetchedItemsForDisplay = await fetchPageData(
     page: currentPage,
     itemsPerPage: itemsPerPage,
     sortBy: sortBy,
     ascending: ascending,
     searchText: searchText,
    );

    //Returning the initial state = meaning naa na diria ang data to be displayed by our UI Widgets
    return InventoryState(
      filteredData: fetchedItemsForDisplay,
      searchText: searchText,
      currentPage: currentPage,
      totalPages: totalPages,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  //Page Navigation Functions

  //Fetch Total Item Count; but based on both searchText and isVisible (bale pwede for both Archived and Active items)
  Future<int> fetchTotalItemCount({required String searchText}) async {
    if(_isVisible){
      return _accessServices.totalActiveItemCount(searchQuery: searchText);
    }else{
      return _accessServices.totalArchivedItemCount(searchQuery: searchText);
    }
  }

  //Data na stored here, are the data from the database based on the amount of rows/items na kukunin
  Future<List<InventoryData>> fetchPageData({
    required int page,
    required int itemsPerPage,
    required String sortBy,
    required bool ascending,
    required String searchText,
  }) async {
    print('Fetching data for the following parameters: $_isVisible - $page - $sortBy'); //Visibility lang, for my debugging
    return _accessServices.fetchItems(
      isVisible: _isVisible,
      page: page,
      itemsPerPage: itemsPerPage,
      sortBy: sortBy,
      ascending: ascending,
      searchQuery: searchText,
    );
  }
  
  //Page Navigation - Updating the state just to contain the data to be present on that page
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull;
    print('Displaying data for page: $page'); //Debug Control lang, so I'll see if it works. 
    if(currentState == null) {
      ref.invalidateSelf(); //Force rebuilds the state, iwas corrupt
      return;
    }
    
    //Page Value Checker; Iwas wrong value
    if(page  < 1 || page > currentState.totalPages) {
      print('Page is out of bounds.');
      return ;
    }
    
    state = const AsyncValue.loading();

    try {
      final items = await fetchPageData(
        page: page, 
        itemsPerPage: currentState.itemsPerPage, 
        sortBy: currentState.sortBy, 
        ascending: currentState.ascending, 
        searchText: currentState.searchText
      );

      state = AsyncValue.data(currentState.copyWith(
        filteredData: items,
        currentPage: page,
      ));
    }catch(error, stackTrace){
      print('Error in going to this page: $page');
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> sort(String sortBy) async {
    bool newAscending;
    final currentState = state.valueOrNull;
    if(currentState == null) return;

    //Literally, compares the sortBy param if it's the same or not.
    if(currentState.sortBy == sortBy){
      newAscending = !currentState.ascending;
    }else{
      newAscending = true;
    }
    
    //Default = back to Page 1 when sorting
    const newPage = 1;

    state = const AsyncValue.loading();

    try{
      final sortedItemsForDisplay = await fetchPageData(
        page: newPage, 
        itemsPerPage: currentState.itemsPerPage, 
        sortBy: sortBy, 
        ascending: newAscending, 
        searchText: currentState.searchText
      );
      state = AsyncValue.data(currentState.copyWith(
        filteredData: sortedItemsForDisplay,
        currentPage: newPage,
        sortBy: sortBy,
        ascending: newAscending,
      ));
    }catch(error, stackTrace){
      print('Error fetching and storing the data based on sort.');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void searchItems(String searchQuery){
    //Checking _debounce's integrity, para sure lang na it exists
    if(_debounce != null){
      if(_debounce!.isActive){
        _debounce!.cancel();
      }
    }

    _debounce = Timer(const Duration(milliseconds: 750), () async {
      final currentState = state.valueOrNull;
      if(currentState == null) return ;

      if (currentState.searchText == searchQuery) return ;

      const newPage = 1; //resets the page back to 1 kada search!
      state = const AsyncValue.loading();

      try {
       //Fetch Total Item Count -> Total Pages 
       final totalItemsFetched = await fetchTotalItemCount(searchText: searchQuery);
       final totalPages = (totalItemsFetched / currentState.itemsPerPage).ceil(); //Whole number ang return
       final finalTotalPages = totalPages > 0 ? totalPages: 1;

       final itemsFetched  = await fetchPageData(
        page: newPage, 
        itemsPerPage: currentState.itemsPerPage,
        sortBy: currentState.sortBy, 
        ascending: currentState.ascending, 
        searchText: searchQuery,
        );

        state = AsyncValue.data(currentState.copyWith(
          filteredData: itemsFetched,
          currentPage: newPage,
          searchText: searchQuery,
          totalPages: finalTotalPages,
        ));

      }catch(error, stackTrace){
        print('Error fetching and storing the data based on search.');
      state = AsyncValue.error(error, stackTrace);
      }

    });

  }
  
  //Handling both inActive and active items
  Future<void> setItemVisibility(int itemID, bool itemVisibility) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = const AsyncValue.loading();

    try{
      await _accessServices.updateVisibility(itemID, itemVisibility);
      await refreshCurrentPage(); //Force refresh page!
    }catch(error, stackTrace){
      print('Error updating the visibility of the item $itemID : $itemVisibility');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  //Refresh Helper: Same function as ref.invalidate nako sauna, but this one triggers for ANY actionable updates meaning mga ADD, UPDATE, ARCHIVE and if needed.

  Future<void> refreshCurrentPage() async {
    final currentState = state.valueOrNull;

    //Checks for data corruption, pag corrupt - force rebuild
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }

    final previousState = currentState; //Holding previous state, just in case
    state = const AsyncValue.loading();

    try{
      final totalItemsFetched = await fetchTotalItemCount(searchText: currentState.searchText);
      final totalPages = (totalItemsFetched / currentState.itemsPerPage).ceil(); //Whole number ang return
      final finalTotalPages = totalPages > 0 ? totalPages: 1;
      
      int pageToFetch = currentState.currentPage;
      //Page to fetch becomes the new last page.
      if (pageToFetch > finalTotalPages) pageToFetch = finalTotalPages;

      //Checker for invalid page size
      if (pageToFetch < 1) pageToFetch = 1;

      //Fetch the entire data again, just to make sure that it's correctly displayed
      final fetchedItems = await fetchPageData(
        page: pageToFetch, 
        itemsPerPage: currentState.itemsPerPage, 
        sortBy: currentState.sortBy, 
        ascending: currentState.ascending, 
        searchText: currentState.searchText
      );

      state = AsyncValue.data(previousState.copyWith(
        filteredData: fetchedItems,
        totalPages: finalTotalPages,
        currentPage: pageToFetch,
      ));
    }catch(error, stackTrace){
      print('Error refreshing current page.');
      state = AsyncValue.error(error, stackTrace);
    }
  }
// Functions that handle actual actions: ADD/UPDATE/ARCHIVE

  //Add Function
  Future<void> addNewItem (InventoryData newItem) async {
    state = const AsyncValue.loading();

    try{
      await _accessServices.addItem(
        newItem.itemName, newItem.itemTypeID, newItem.itemDescription, newItem.itemQuantity, newItem.supplierID, newItem.itemPrice);
      await refreshCurrentPage();
    }catch(error, stackTrace){
      print('Error adding new item. -- Notifier');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  //Update Item Function
  Future<void> updateItemDetails (InventoryData updateItem) async {
    state = const AsyncValue.loading();

    try{
      await _accessServices.updateItem(
        updateItem.itemID, updateItem.itemName, updateItem.itemTypeID, updateItem.supplierID, updateItem.itemDescription, updateItem.itemPrice);

      await refreshCurrentPage();
    }catch(error, stackTrace){
      print('Error updating item details. -- Notifier');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> stockInItem(int itemID, int addedQuantity) async {
    state = const AsyncValue.loading();

    try{
      await _accessServices.updateItemQuantity(itemID, addedQuantity);
      await refreshCurrentPage();
    }catch(error, stackTrace){
      print('Error stocking in item. --notifier');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
