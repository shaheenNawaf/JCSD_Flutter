//Imports for Supabase and Item Types data model
import 'package:jcsd_flutter/api/global_variables.dart';
import 'itemtypes_data.dart';

class ItemtypesService {
  //Fetching All Items in the List
  Future<List<ItemTypesData>> displayAllItemTypes() async {
    try {
      final dataTypes = await supabaseDB.from('item_types').select();
      if (dataTypes.isEmpty) {
        print('Empty data types table.');
        return [];
      }
      print('Printing');
      return dataTypes
          .map<ItemTypesData>((item) => ItemTypesData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching data from the table. $err');
      return [];
    }
  }

  //Fetching all active items
  Future<List<ItemTypesData>> activeItemTypes() async {
    try {
      final results = await supabaseDB
          .from('item_types')
          .select()
          .eq('isVisible', true)
          .order('itemType', ascending: true);
      if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      return results
          .map<ItemTypesData>((item) => ItemTypesData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching active item types. $err');
      return [];
    }
  }

  //Fetching all hidden items
  Future<List<ItemTypesData>> archivedItemTypes() async {
    try {
      final results = await supabaseDB
          .from('item_types')
          .select()
          .eq('isVisible', false)
          .order('itemTypeID', ascending: true);
      if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      return results
          .map<ItemTypesData>((item) => ItemTypesData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching archived item types. $err');
      return [];
    }
  }

  //Add Item; Auto-increment ID
  Future<void> addNewType(String typeName, String typeDescription) async {
    try {
      await supabaseDB.from('item_types').insert({
        'itemType': typeName,
        'description': typeDescription,
        'isVisible': true,
      });
      print("NEW ITEM TYPE ADDED: $typeName");
    } catch (err) {
      print('ERROR ADDING ITEM TYPE. $err');
    }
  }

  //Update Type Details
  Future<void> updateItemDetails(
      String typeName, String typeDescription, int typeID) async {
    try {
      await supabaseDB
          .from('item_types')
          .update({'itemType': typeName, 'description': typeDescription}).eq(
              'itemTypeID', typeID);
      print("UPDATED DETAILS OF ITEM TYPE: $typeName");
    } catch (err) {
      print('UPDATE ERROR: $typeName -- $err');
    }
  }

  //Update Type Visibility
  Future<void> updateTypeVisibility(int typeID, bool isVisible) async {
    try {
      await supabaseDB
          .from('item_types')
          .update({'isVisible': isVisible}).eq('itemTypeID', typeID);
      print("Updated the visibility of $typeID");
    } catch (err) {
      print('Error updating visibility of item type. $err');
    }
  }

  //Get Item Type name by ID
  Future<String> getTypeNameByID(int typeID) async {
    try {
      final fetchNames = await supabaseDB
          .from('item_types')
          .select('itemType')
          .eq('itemTypeID', typeID)
          .single();
      return fetchNames['itemType'] as String;
    } catch (err) {
      return "Failed to fetch name. $err";
    }
  }

  //Get Item Type ID by Name
  Future<int> getIdByName(String typeName) async {
    try {
      final fetchID = await supabaseDB
          .from('item_types')
          .select('itemTypeID')
          .eq('itemType', typeName)
          .single();
      return fetchID['itemTypeID'] as int;
    } catch (err) {
      print('Error fetching Type ID. $err');
      return -1;
    }
  }
}
