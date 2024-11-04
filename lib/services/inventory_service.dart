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
      return null;
    }
    else{
      return InventoryData.fromJson(idItem); //Parsing the data as a JSON-like file for easier access
    }
  }

  //Method 1: Search Function -- all possible results
  Future<List<InventoryData?>> searchItems({ int? itemID, String? itemName, String? itemType}) async {
    try{ 
      final itemSearch = supabaseDB.from('item_inventory').select();

      if(itemID != null){
        itemSearch.eq('itemID', itemID);
        print("Specified ITEM_ID isn't found: $itemID");
      }
      if(itemName != null){
        itemSearch.eq('itemName', itemName);
        print("Specified ITEM_NAME isn't found: $itemName");
      }
      if(itemType != null){
        itemSearch.eq('itemType', itemType);
        print("Specified ITEM_TYPE doesn't exist: $itemType");
      }

      final storeSearch = await itemSearch.select(); //Store search results here

      if(storeSearch.isEmpty == true){
        print("Specified search didn't return any items");
        return [];
      }else{
        //Storing the data as a list
        List<InventoryData> storeResults = storeSearch.map(
        (dynamic itemData) {return InventoryData.fromJson(itemData as Map<String, dynamic>);
        },
        ).toList();

        return storeResults;
      }
    }
    catch(err){
      print('Error fetching data: $err');
      return [];
    }
    
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
      return addItem;
    }catch(err){
      print('Tried adding, caught error in: $err');
    }
  }

  //Method 4: Updating an Item's Details
  Future<void> updateItemDetails(InventoryData updateItem) async{
    try{
      final updateItemDetails = await supabaseDB.from('item_inventory').update(updateItem.toJson()).eq('itemID', updateItem.itemID);
      return updateItemDetails;
    }catch(err){
      print("Tried updating, caught error: $err");
    }
  }

  //Method 5: Updating Item's visibility/state
  Future<void> updateItemVisibility(int itemID, bool isVisible) async{
    try{
      final updateItemDetails = await supabaseDB.from('item_inventory').update({'isVisible': isVisible}).eq('itemID', itemID);
      return updateItemDetails;
    }catch(err){
      print('Tried updating the visibility of the $itemID, but caught $err');
    }
  }
}