//Imports for Supabase and Item Types data model
import 'package:jcsd_flutter/api/global_variables.dart';
import 'itemtypes_data.dart';

class ItemtypesService {

  //Fetching All Items in the List
  Future<List<ItemTypesData>> displayAllItemTypes() async {
    try {
      final dataTypes = await supabaseDB.from('item_types').select();
      if(dataTypes.isEmpty){
        print('Empty data types table.');
        return [];
      }
        print('Printing');
        return dataTypes.map<ItemTypesData>((item) => ItemTypesData.fromJson(item)).toList();
    }catch(err){
      print('Error fetching data from the table. $err');
      return [];
    }
  }

  //Fetching all active items

  //Fetching all hidden items
  
  //Add Item; Auto-increment ID
  Future<void> addNewType(String typeName, String typeDescription) async {
    try {
      await supabaseDB.from('item_type').insert({
        'itemType': typeName,
        'description': typeDescription,
        'isVisible': true,
      });
      print("Added new item_type: $typeName");
    }catch(err){
      print('Error adding new item type. $err');
    }
  }

  //Update Type Details
  Future<void> updateItemDetails(String typeName, String typeDescription, bool isVisible) async {
    try {
      await supabaseDB.from('item_type').insert({
        'itemType': typeName,
        'description': typeDescription,
        'isVisible': true,
      });
      print("Added new item_type: $typeName");
    }catch(err){
      print('Error adding new item type. $err');
    }
  }

  //Update Type Visibility
  Future<void> typeIsActive(int typeID, String typeName, bool isVisible) async {
    try {
      await supabaseDB.from('item_type').update({'isVisible': isVisible}).eq('itemTypeID', typeID);
      print("Added new item_type: $typeName");
    }catch(err){
      print('Error adding new item type. $err');
    }
  }

  //Get Item Type name by ID
  Future<String> getTypeNameByID(int typeID) async {
    try{
      final fetchNames = await supabaseDB.from('item_types').select('itemType').eq('itemTypeID', typeID).single();
      return fetchNames['itemType'] as String;
    }catch(err){
      return "Failed to fetch name. $err";
    }
  }

  //Get Item Type ID by Name
  Future<int> getIdByName(String typeName) async {
    try{
      final fetchID = await supabaseDB.from('item_types').select('itemTypeID').eq('itemType', typeName).single();
      return fetchID['itemTypeID'] as int;
    }catch(err){
      print('Error fetching Type ID. $err');
      return -1;
    }
  }
}
