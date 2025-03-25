import 'package:flutter/material.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';

class InventoryNotifier extends ChangeNotifier {
  final InventoryService _inventoryService;

  //Initial Declaration for state handling (removing the need for that stupid state management file)
  List<InventoryData> _inventoryItems = [];
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

    //Telling the relevant UI elements to update as per given operation
    notifyListeners();

    try {
      return await operation();
    } catch (err) {
      _errorMessage = '$errorMessagePrefix: ${err.toString()}';
      print('Error: $err');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Fetch Items from the Inventory; Can just easily sort the data got if active ba or achived. EZZZZ
  Future<void> fetchInventoryItems() async {
    final allItems = await _handleInventoryOperation<List<InventoryData>>(
        () => _inventoryService.allItems(),
        'Failed to fetch all of the items inside the database.');

    if (allItems!.isNotEmpty) {
      _inventoryItems = allItems;
    } else {
      _inventoryItems = []; //Failed to fetch; still empty data huhu
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
      _inventoryItems.add(addedItem);
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
      _inventoryItems = _inventoryItems.map((item) {
        return item.itemID == currentItem.itemID ? updatedItem : item;
      }).toList();
      notifyListeners();
    }
  }

  //Update Visibility

  //Search

  //Filters

  //Pagination
}
