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
        return InventoryData.fromJson(fetchItem);
      }
    } catch (err) {
      print('Error accessing table: $err');
      return null;
    }
  }

  // General Search Function - searches itemID, itemName, and itemType
  // Dart allows ? as assigned null, added nako here para ma handle sa function if may empty na parameter when called
  Future<List<InventoryData>> searchItems({ int? itemID, String? itemName, String? itemType}) async {
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

  //Fetching all active items
  Future<List<InventoryData>> displayAllAvailable() async{
    try{
      final results = await supabaseDB.from('item_inventory').select().eq('isVisible', true);
       if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      return results.map<InventoryData>((item) => InventoryData.fromJson(item)).toList();
    }catch(err){
      print('Error fetching hidden items. $err');
      return [];
    }
  }

  //Fetching all hidden items
  Future<List<InventoryData>> displayAllHidden() async{
  try{
      final results = await supabaseDB.from('item_inventory').select().eq('isVisible', 'false');
       if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      return results.map<InventoryData>((item) => InventoryData.fromJson(item)).toList();
    }catch(err){
      print('Error fetching hidden items. $err');
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
  Future<void> updateItemDetails(InventoryData updatedtem) async {
     try {
       await supabaseDB.from('item_inventory').update(updatedtem.toJson()).eq('itemID', updatedtem.itemID);
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

  Future<void> addItem(String itemName, int itemTypeID, String itemDescription, int quantity, int supplierID, double itemPrice, bool isVisible) async{
    try {
      await supabaseDB.from('item_inventory').insert({
        'itemName': itemName,
        'itemTypeID': itemTypeID,
        'itemDescription': itemDescription,
        'itemQuantity': quantity,
        'supplierID': supplierID,
        'itemPrice': itemPrice,
        'isVisible': isVisible,
      });

      print("Added new item: $itemName");
    }catch(err){
      print('Error adding new item. $err');
    }
  }

  Future<void> updateItem(int itemID, String itemName, int itemTypeID,
    String itemDescription, int quantity, int supplierID, double itemPrice,
    bool isVisible) async {
  try {
    // Execute the update query
    await supabaseDB.from('item_inventory').update({
      'itemName': itemName,
      'itemTypeID': itemTypeID,
      'itemDescription': itemDescription,
      'itemQuantity': quantity,
      'supplierID': supplierID,
      'itemPrice': itemPrice,
      'isVisible': isVisible,
    }).eq('itemID', itemID);

    print("Updated item: $itemID - $itemName");
  } catch (err) {
    // Catch and print general exceptions
    print('Error updating item. $err');
  }
}

  Future<void> itemIsActive(int itemID,  bool isVisible) async{
    try {
      await supabaseDB.from('item_inventory').update({'isVisible': isVisible,}).eq('itemID', itemID);
      print("Archived item: $itemID");
      
    }catch(err){
      print('Error adding new item. $err');
    }
  }
}