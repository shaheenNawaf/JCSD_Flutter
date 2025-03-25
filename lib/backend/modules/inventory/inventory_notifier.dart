import 'package:flutter/material.dart';

//Backend Imports, handling the state
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

class InventoryNotifier extends ChangeNotifier {
  final InventoryService _inventoryService;

  //Initial Declaration for state handling (removing the need for that stupid state management file)
  List<InventoryData> _inventoryItems = [];

  InventoryState _defaultState =
      InventoryState(originalData: [], filteredData: []);

  InventoryState get state => _defaultState;

  bool _isLoading = false;
  String? _errorMessage = '';

  //Constructors handling the initial data
  InventoryNotifier(InventoryService inventoryService)
      : _inventoryService = inventoryService;

  List<InventoryData> get inventoryItems => _inventoryItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //Generic Function to handle ANY operations
  Future<T?> _handleInventoryOperation<T>(
      Future<T> Function() operation, String errorMessagePrefix) async {
    _isLoading = true;
    _errorMessage = null;

    _defaultState = _defaultState.copyWith(isLoading: true, error: null);

    //Telling the relevant UI elements to update as per given operation
    notifyListeners();

    try {
      return await operation();
    } catch (err) {
      _defaultState = _defaultState.copyWith(
          isLoading: false, error: '$errorMessagePrefix: ${err.toString()}');
      print('Error: $err');
      return null;
    } finally {
      _defaultState = _defaultState.copyWith(isLoading: false);
      notifyListeners();
    }
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
            currentItem.itemQuantity,
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

  //Update Visibility

  //Search
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


  //Pagination
}
