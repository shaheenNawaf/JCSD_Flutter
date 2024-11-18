//personal notes - for my reference
//For the Supabase implementation - usage of single SB 
import 'package:jcsd_flutter/api/global_variables.dart';
// Inventory Data model to store all the relevant data per instance of that model
import 'package:jcsd_flutter/models/inventory_data.dart';

class InventoryService {

  //Single Item - for loading their details (NOT SEARCH)
  Future<InventoryData?> getItemByID(int itemID) async {
    try {
      final fetchItem = await supabaseDB.from('item_inventory').select().eq('itemID', itemID).single();
      if (fetchItem.isEmpty == true) {
        print("ITEM_ID not found: $itemID");
        return null;
      }else{
        print("ITEM_ID is present in the table: $itemID");
      }
      return InventoryData.fromJson(fetchItem);
    } catch (err) {
      print('Error fetching item by ID: $err');
      return null;
    }
  }

  // General Search Function - searches itemID, itemName, and itemType
  Future<List<InventoryData>> searchItems({
    int? itemID, // ? = null assignable in Dart, kay it may return empty
    String? itemName, 
    String? itemType,
  }) async {
    try {
      final query = supabaseDB.from('item_inventory').select();
      
      if (itemID != null){
        query.eq('itemID', itemID);
      }
      if (itemName != null){
        query.eq('itemName', itemName);
      }
      if (itemType != null){
        query.eq('itemType', itemType);
      }

      final results = await query;
      if (results.isEmpty) {
        print("No Items found in the database.");
        //Add widget
        return [];
      }
      return results.map<InventoryData>((item) => InventoryData.fromJson(item)).toList();
    } catch (err) {
      print('Error Searching Items. Refer to error here: $err');
      return [];
    }
  }

  // Just fetching all the items inside the database
  Future<List<InventoryData>> displayAllItems() async {
    try {
      final results = await supabaseDB.from('item_inventory').select();
      if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      //Notes ni Shaheen para di malibog HASHDUAJKDAD
      //Returns a FutureList - break down using the .when property
      return results.map<InventoryData>((item) => InventoryData.fromJson(item)).toList(); 
    } catch (err) {
      print('Error fetching all items: $err');
      return [];
    }
  }

  // ADD ITEM - double check entry, might need to update fields from InventoryData
  Future<void> addNewItem(InventoryData newItem) async {
    try {
      await supabaseDB.from('item_inventory').insert(newItem.toJson());
    } catch (err) {
      print('Error adding new item: $err');
    }
  }

  // UPDATE
  Future<void> updateItemDetails(InventoryData updatedItem) async {
    try {
      await supabaseDB.from('item_inventory').update(updatedItem.toJson()).eq('itemID', updatedItem.itemID);
    } catch (err) {
      print('Error updating item details: $err');
    }
  }

  // Updating Item Visibility/Soft-delete
  Future<void> updateItemVisibility(int itemID, bool isVisible) async {
    try {
      await supabaseDB.from('item_inventory').update({'isVisible': isVisible}).eq('itemID', itemID);
    } catch (err) {
      print('Error updating Item:$itemID visibility. Error Message: $err');
    }
  }
}