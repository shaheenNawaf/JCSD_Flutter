//personal notes - for my reference
//For the Supabase implementation - usage of single SB 
import 'package:jcsd_flutter/api/global_variables.dart';
// Inventory Data model to store all the relevant data per instance of that model
import 'package:jcsd_flutter/models/inventory_data.dart';

class InventoryService {
  // ? included for possibility that it may be null

  // Method 1: Searching by ID
  Future<InventoryData?> getItemByID(int itemID) async{
    final idItem = await supabaseDB.from('item_inventory').select().eq('itemID', itemID).single(); //Gets specific not 

    //For browser console = checking ifEmpty
    if(idItem.isEmpty == true){
      print("Specified ITEM_ID isn't found: $itemID");
    }
    else{
      return InventoryData.fromJson(idItem); //Parsing the data as a JSON-like file for easier access
    }

    // Method 2: Displaying all Employees from DB
    Future<List<InventoryData?>> displayAllItems() async{
      final displayItems = await supabaseDB.from('item_inventory').select();
       
      if(displayItems.isEmpty == true ){
        print("Table 'Items_Inventory' is empty.");
        return [];
      }else{
        List<InventoryData> inventoryItems = []; //Init state
        for(var eachItem in displayItems){
          inventoryItems.add(InventoryData.fromJson(eachItem));
        }
        return inventoryItems;
      }
    }

    //Method 3: Adding a new item on the Inventory
    Future<void> addNewItem(InventoryData newItem) async{
      try{
        final addItem = await supabaseDB.from('item_inventory').insert(newItem.toJson());
      }catch(err){
        print('Tried adding, caught error in: $err');
      }
    }

    //Method 4: Updating an Item's Details
    Future<void> updateItemDetails(InventoryData updateItem) async{
      try{
        final updateItemDetails = await supabaseDB.from('item_inventory').insert(updateItem.toJson()).eq('itemID', updateItem.itemID);
      }catch(err){
        print("Tried updating, caught error: $err");
      }
    }

    //Method 5: Updating Item's visibility/state
    Future<void> updateItemVisibility(int itemID, bool isVisible) async{
      try{
        final updateItemDetails = await supabaseDB.from('item_inventory').update({'isVisible': isVisible}).eq('itemID', itemID);
      }catch(err){
        print('Tried updating the visibility of the item: $itemID');
      }
    }
  }
}