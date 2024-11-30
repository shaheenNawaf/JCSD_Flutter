import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/models/inventory_data.dart';
import 'package:jcsd_flutter/services/inventory_service.dart';

// Provider for the Inventory System -- USED FOR THE ENTIRE STATE MANAGEMENT -- DON'T TOUCH
final inventoryServiceProv = Provider<InventoryService>((ref){
  return InventoryService();
});

// -- ALL OTHER METHODS UNDER NA HERE -- //

//Grabbing Entire Inventory List; used for displaying the list
final fetchInventoryList = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProv);

  List<InventoryData> allItems = await baseInventory.displayAllItems();
  return allItems;
});

//Grabbing all hidden items
final fetchHiddenList = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProv);

  List<InventoryData> allItems = await baseInventory.displayAllHidden();
  return allItems;
});

//Grabbing all available items
final fetchAvailableList = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProv);

  List<InventoryData> allItems = await baseInventory.displayAllAvailable();
  return allItems;
});

//Just to hold Query State (which might be empty)
final inventoryQuery = StateProvider<String?>((ref) => null);

//Search Function; added validation to ensure it can handle null results iwas error
final inventorySearchResult = FutureProvider<List<InventoryData>>((ref) async {
  final inventoryService = ref.read(inventoryServiceProv);
  final queryResult = ref.watch(inventoryQuery);

  //Conditionals to handle if there aren't any input/search result = isEmpty
  if (queryResult == null || queryResult.isEmpty){
    return [];
  }

  //Actual function call to my inventory service for searching items
  return await inventoryService.searchItems(itemName: queryResult, itemID: int.tryParse(queryResult), itemType: queryResult);
});

// TY GPT - Just to indicate it's loading, nothing else. Visual lang.
final inventoryLoadingStateProvider = StateProvider<bool>((ref) => false);

// Adding an item
final addItemProvider = FutureProvider.family<void, InventoryData>((ref, newItem) async {
  final inventoryService = ref.read(inventoryServiceProv);
  ref.read(inventoryLoadingStateProvider.notifier).state = true;

  try {
    await inventoryService.addNewItem(newItem);
  }catch (err){
    ref.read(inventoryLoadingStateProvider.notifier).state = false;
    print('Error at addItemProvider, cant add item on table. View message: $err');
  }
});

// Updating an Item
final updateItemProvider = FutureProvider.family<void, InventoryData>((ref, updateItem) async {
  final inventoryService = ref.read(inventoryServiceProv);
  ref.read(inventoryLoadingStateProvider.notifier).state = true;

  try {
    await inventoryService.updateItemDetails(updateItem);
  }catch (err){
    ref.read(inventoryLoadingStateProvider.notifier).state = false;
    print('Error at updateItemProvider, cant update item on table. View message: $err');
  }
});

// Updating an Item's visibility
final updateItemVisibilityProvider = FutureProvider.family<void, InventoryData>((ref, updateItem) async {
  final inventoryService = ref.read(inventoryServiceProv);
  ref.read(inventoryLoadingStateProvider.notifier).state = true;

  try {
    await inventoryService.updateItemVisibility(updateItem.itemID, updateItem.isVisible);
  }catch (err){
    ref.read(inventoryLoadingStateProvider.notifier).state = false;
    print('Error at updateItemVisibilityProvider, cant item visbility. View message: $err');
  }
});

//TODO
// Filitered Search: idk when

  
