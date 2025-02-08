import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_service.dart';

// Provider for the Inventory System -- USED FOR THE ENTIRE STATE MANAGEMENT -- DON'T TOUCH
final inventoryServiceProv = Provider<InventoryService>((ref){
  return InventoryService();
});

// -- ALL OTHER METHODS UNDER NA HERE -- //

//Grabbing Entire Inventory List; used for displaying the list
final fetchInventoryList = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProv);

  List<InventoryData> allItems = await baseInventory.allItems();
  return allItems;
});

//Grabbing all hidden items
final fetchArchived = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProv);

  List<InventoryData> allItems = await baseInventory.achivedItems();
  return allItems;
});

//Grabbing all available items
final fetchActive = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProv);

  List<InventoryData> allItems = await baseInventory.activeItems();
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



//TODO
// States for adding multiple items
// Search function

  
