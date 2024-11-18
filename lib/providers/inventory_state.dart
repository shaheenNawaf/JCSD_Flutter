import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/models/inventory_data.dart';
import 'package:jcsd_flutter/services/inventory_service.dart';
// Notes: Please don't touch any of this

//Fetching Inventory List
final fetchInventoryList = FutureProvider<List<InventoryData>>((ref) async {
  final baseInventory = ref.read(inventoryServiceProd);

  List<InventoryData> allItems = await baseInventory.displayAllItems();
  return allItems;
});

// Provider for the Inventory System -- One instance for the entire application
final inventoryServiceProd = Provider<InventoryService>((ref){
  return InventoryService();
});

  
