//General Note for Shaheen:

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports, handling the state
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

const int _defaultItemsPerPage = 10;

class InventoryNotifier extends FamilyAsyncNotifier<InventoryState, bool> {
  late bool _isVisible; //Just to store which to access, based on property
  InventoryService get _accessServices => ref.read(inventoryServiceProv);

  @override
  Future<InventoryState> build(bool arg) async {
    _isVisible = arg;

    //initial parameters for the loaded state
    const currentPage = 1;
    const itemsPerPage = _defaultItemsPerPage;
    const searchText = '';
    const sortBy = 'itemID';
    const ascending = true;

    //Fetching the total item count
    final totalItems = await _fetchTotalItemCount(searchText: searchText);
  }
  

  //Fetch Items from the Inventory; Can just easily sort the data got if active ba or achived. EZZZZ
  Future<void> fetchInventoryItems() async {
    final allItems = await _handleInventoryOperation<List<InventoryData>>(
        () => _inventoryService.allItems(),
        'Failed to fetch all of the items inside the database.');

    if (allItems!.isNotEmpty) {
      _defaultState = _defaultState.copyWith(
          originalData: allItems, filteredData: allItems);
    } else {
      _defaultState =
          _defaultState.copyWith(originalData: [], filteredData: []);
    }
  }

  //Add
  Future<void> addInventoryItem(InventoryData newItem) async {
    final addedItem = await _handleInventoryOperation<InventoryData>(
        () => _inventoryService.addItem(
            newItem.itemName,
            newItem.itemTypeID,
            newItem.itemDescription,
            newItem.itemQuantity,
            newItem.supplierID,
            newItem.itemPrice),
        'Failed to perform on the inventory: New Item');

    if (addedItem != null) {
      //Add to original
      final updatedOriginal =
          List<InventoryData>.from(_defaultState.originalData)..add(addedItem);

      //Add to filtered
      final updatedFiltered =
          List<InventoryData>.from(_defaultState.filteredData)..add(addedItem);

      //Reflect the added data to the state
      _defaultState = _defaultState.copyWith(
          originalData: updatedOriginal, filteredData: updatedFiltered);

      //Basically tells all the UI connected to this notifier to refresh to reflect any changes
      notifyListeners();
    }
  }

  //Update
  Future<void> updateInventoryItem(InventoryData currentItem) async {
    final updatedItem = await _handleInventoryOperation<InventoryData>(
        () => _inventoryService.updateItem(
            currentItem.itemID,
            currentItem.itemName,
            currentItem.itemTypeID,
            currentItem.itemDescription,
            currentItem.supplierID,
            currentItem.itemPrice),
        'Failed to perform on the inventory: Update Item');

    if (updatedItem != null) {
      final updatedOriginal = _defaultState.originalData.map((item) {
        return item.itemID == currentItem.itemID ? updatedItem : item;
      }).toList();

      final updatedFiltered = _defaultState.filteredData.map((item) {
        return item.itemID == currentItem.itemID ? updatedItem : item;
      }).toList();

      _defaultState = _defaultState.copyWith(
          originalData: updatedOriginal, filteredData: updatedFiltered);
      notifyListeners();
    }
  }

  //Update Visibility - Archive/Unarchive
  Future<void> unarchiveItem(int itemID) async {
    //Essentially all of the codes here prior to Try/Catch are for validation/error handling, therefore simplifying the code inside my service
    final currentItem = _defaultState.originalData.firstWhere((item) => item.itemID == itemID);

    if(currentItem == null){
      throw Exception('Cannot unarchive: $itemID not found in the current state.');
    }

    if(currentItem.isVisible){
      print('Item: $itemID is already visible.');
    }

    //Updating the state
    final updatedItemToState = currentItem.copyWith(isVisible: true);

    _defaultState = _defaultState.copyWith(isLoading: true, error: null);
    notifyListeners();

    //Fully Updating the data inside the state
    try{
      //dude this is the actual service call HAHAH yawa literally ONE line, I love it
      await _inventoryService.updateVisibility(itemID, true);

      final updatedOriginal = _defaultState.originalData.map((item){
        return item.itemID == itemID ? updatedItemToState : item;
      }).toList();

      final updatedFiltered = _defaultState.filteredData.map((item){
        return item.itemID == itemID ? updatedItemToState : item;
      }).toList();

      _defaultState = _defaultState.copyWith(
        originalData: updatedOriginal,
        filteredData: updatedFiltered,
        isLoading: false,
        error: null,
      );
    }catch(error){
      print('Error unarchiving item $itemID via this notifier. ');
      _defaultState = _defaultState.copyWith(isLoading: false, error: 'Failed to unarchive. $itemID -- $error');
      throw Exception('Database updated failed during Unarchived Notifier.');
    }finally{
      if(_defaultState.isLoading){
        _defaultState = _defaultState.copyWith(isLoading: false);
      }
      notifyListeners();
    }
  } 

  //Unfinished, based from Unarchive item function above
  Future<void> archiveItem(int itemID) async {
    //Essentially all of the codes here prior to Try/Catch are for validation/error handling, therefore simplifying the code inside my service
    final currentItem = _defaultState.originalData.firstWhere((item) => item.itemID == itemID);

    if(currentItem == null){
      throw Exception('Cannot archive: $itemID not found in the current state.');
    }

    if(currentItem.isVisible == false){
      print('Item: $itemID is already archived.');
    }

    //Updating the state
    final updatedItemToState = currentItem.copyWith(isVisible: false);

    _defaultState = _defaultState.copyWith(isLoading: true, error: null);
    notifyListeners();

    //Fully Updating the data inside the state
    try{
      //dude this is the actual service call HAHAH yawa literally ONE line, I love it
      await _inventoryService.updateVisibility(itemID, false);

      final updatedOriginal = _defaultState.originalData.map((item){
        return item.itemID == itemID ? updatedItemToState : item;
      }).toList();

      final updatedFiltered = _defaultState.filteredData.map((item){
        return item.itemID == itemID ? updatedItemToState : item;
      }).toList();

      _defaultState = _defaultState.copyWith(
        originalData: updatedOriginal,
        filteredData: updatedFiltered,
        isLoading: false,
        error: null,
      );
    }catch(error){
      print('Error unarchiving item $itemID via this notifier. ');
      _defaultState = _defaultState.copyWith(isLoading: false, error: 'Failed to unarchive. $itemID -- $error');
      throw Exception('Database updated failed during Unarchived Notifier.');
    }finally{
      if(_defaultState.isLoading){
        _defaultState = _defaultState.copyWith(isLoading: false);
      }
      notifyListeners();
    }
  } 


  //Updated StockIn Logic: Shorter and updates both filtered and original data logic
  Future<void> stockInItem(int itemID, int addedItemQuantity) async {
    if (addedItemQuantity <= 0) {
      print('Quantity must be a positive integer.');
    }

    final updatedItemQuantityDB =
        await _handleInventoryOperation<InventoryData?>(
            () =>
                _inventoryService.updateItemQuantity(itemID, addedItemQuantity),
            'Failed to stock in item.');

    if (updatedItemQuantityDB != null) {
      final updatedOriginal = _defaultState.originalData.map((item) {
        return item.itemID == itemID ? updatedItemQuantityDB : item;
      }).toList();

      final updatedFiltered = _defaultState.filteredData.map((item) {
        return item.itemID == itemID ? updatedItemQuantityDB : item;
      }).toList();

      _defaultState = _defaultState.copyWith(
        originalData: updatedOriginal,
        filteredData: updatedFiltered,
      );
      notifyListeners();
    }
  }

  //TODO: Stock-out Item

  //TODO: Archive

  //TODO: Unarchive

  //Search Function   
  void searchItems(String searchText) {
    //If walang search text, then same lang sa original data ang lalabas
    if (searchText.isEmpty) {
      _defaultState = _defaultState.copyWith(
          filteredData: _defaultState.originalData, searchText: searchText);
    } else {
      final searchListResult = _defaultState.originalData.where((item) {
        return item.itemName.toLowerCase().contains(searchText.toLowerCase()) ||
            item.itemDescription
                .toLowerCase()
                .contains(searchText.toLowerCase());
      }).toList(); //Returns the search result! Amazing shit actually
      _defaultState = _defaultState.copyWith(
          filteredData: searchListResult, searchText: searchText);
    }
    notifyListeners();
  }

  //Filters/Sort
  void sortItems(String sortedBy) {
    //Default state is ascending is set to true, para arranged ang data mga bes
    bool ascendingState =
        _defaultState.sortBy == sortedBy ? !_defaultState.ascending : true;
    List<InventoryData> sortedItemList = List.from(_defaultState.filteredData);

    //Note the comparison
    switch (sortedBy) {
      case 'itemID':
        sortedItemList.sort((a, b) => ascendingState
            ? a.itemID.compareTo(b.itemID)
            : b.itemID.compareTo(a.itemID));
        break;
      case 'itemName':
        sortedItemList.sort((a, b) => ascendingState
            ? a.itemName.compareTo(b.itemName)
            : b.itemName.compareTo(a.itemName));
        break;
      case 'itemDescription':
        sortedItemList.sort((a, b) => ascendingState
            ? a.itemDescription.compareTo(b.itemDescription)
            : b.itemDescription.compareTo(a.itemDescription));
        break;
      case 'itemType':
        sortedItemList.sort((a, b) => ascendingState
            ? a.itemTypeID.compareTo(b.itemTypeID)
            : b.itemTypeID.compareTo(a.itemTypeID));
        break;
      case 'itemPrice':
        sortedItemList.sort((a, b) => ascendingState
            ? a.itemPrice.compareTo(b.itemPrice)
            : b.itemPrice.compareTo(a.itemPrice));
        break;
      case 'itemQuantity':
        sortedItemList.sort((a, b) => ascendingState
            ? a.itemQuantity.compareTo(b.itemQuantity)
            : b.itemQuantity.compareTo(a.itemQuantity));
        break;
    }

    _defaultState = _defaultState.copyWith(
        filteredData: sortedItemList,
        sortBy: sortedBy,
        ascending: ascendingState);
  }

  //Pagination
}
