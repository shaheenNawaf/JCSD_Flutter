//Supabase Implementation -- personal comments to lahat, plz don't remove
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart';

//Inventory Data - using the class that I made to store data
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

class InventoryService {
  AuditServices addAuditLogs = AuditServices();

  //Single Item - for loading their details (NOT SEARCH)
  Future<InventoryData?> getItemByID(int itemID) async {
    try {
      final fetchItem = await supabaseDB
          .from('item_inventory')
          .select()
          .eq('itemID', itemID)
          .single();
      if (fetchItem.isEmpty == true) {
        print("ITEM_ID not found: $itemID");
        return null;
      } else {
        print("ITEM_ID is present in the table: $itemID");
        return InventoryData.fromJson(fetchItem);
      }
    } catch (err) {
      print('Error accessing table: $err');
      return null;
    }
  }

  Future<String?> retrieveNameByID(int itemID) async {
    try {
      final fetchItem = await supabaseDB
          .from('item_inventory')
          .select('itemName')
          .eq('itemID', itemID)
          .maybeSingle();
      if (fetchItem == null) {
        print('Item not found based on the given itemID.');
        return null;
      } else {
        print('Successfully found the item on the table.');
        return fetchItem['itemName'];
      }
    } catch (err, stackTrace) {
      print('Error accessing table: $err, $stackTrace');
      return null;
    }
  }

  //Fetching ID from the given name
  Future<int?> getIDByName(String? itemName) async {
    try {
      //Add functionality that checks for multiple items
      final fetchItem = await supabaseDB
          .from('item_inventory')
          .select('itemID')
          .eq('itemName', itemName!)
          .maybeSingle();
      if (fetchItem == null) {
        print('Item doesn\'t exist. Not able to fetch ID.');
        return null;
      } else {
        print('Item ID get from DB');
        return fetchItem['itemID'] as int?;
      }
    } catch (err, stackTrace) {
      print('Error fetching ID. Please check: $err -- $stackTrace');
      return null;
    }
  }

  // General Search Function - searches itemID, itemName, and itemType
  // Dart allows ? as assigned null, added nako here para ma handle sa function if may empty na parameter when called
  Future<List<InventoryData>> searchItems(
      {int? itemID, String? itemName, String? itemType}) async {
    try {
      final query = supabaseDB.from('item_inventory').select();

      if (itemID != null) {
        query.eq('itemID', itemID);
      }
      if (itemName != null) {
        query.eq('itemName', itemName);
      }
      if (itemType != null) {
        query.eq('itemType', itemType);
      }

      final results = await query;
      if (results.isEmpty) {
        print("No Items found in the database.");
        //Add widget
        return [];
      }
      return results
          .map<InventoryData>((item) => InventoryData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error Searching Items. Refer to error here: $err');
      return [];
    }
  }

  // Just fetching all the items inside the database
  Future<List<InventoryData>> allItems() async {
    try {
      final results = await supabaseDB.from('item_inventory').select();
      if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      //Notes ni Shaheen para di malibog HASHDUAJKDAD
      //Returns a FutureList - break down using the .when property
      return results
          .map<InventoryData>((item) => InventoryData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching all items: $err');
      return [];
    }
  }

  //Fetching all active items
  Future<List<InventoryData>> activeItems() async {
    try {
      final results = await supabaseDB
          .from('item_inventory')
          .select()
          .eq('isVisible', true)
          .order('itemID', ascending: true);
      if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      return results
          .map<InventoryData>((item) => InventoryData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching active items. $err');
      return [];
    }
  }

  //Fetching all archived/hidden items
  Future<List<InventoryData>> achivedItems() async {
    try {
      final results = await supabaseDB
          .from('item_inventory')
          .select()
          .eq('isVisible', 'false')
          .order('itemID', ascending: true);
      if (results.isEmpty) {
        print("No items inside the database");
        return [];
      }
      return results
          .map<InventoryData>((item) => InventoryData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching hidden items. $err');
      return [];
    }
  }

  // Updating Item Visibility/Soft-delete
  Future<void> updateVisibility(int itemID, bool isVisible) async {
    try {
      if (isVisible == true) {
        addAuditLogs.insertAuditLog(
            'audit_inventory',
            1,
            "Unarchived item: $itemID",
            "Unarchived Item"); //Test Employee ID first
      } else {
        addAuditLogs.insertAuditLog('audit_inventory', 1,
            "Archived item: $itemID", "Archived Item"); //Test Employee ID first
      }
      await supabaseDB
          .from('item_inventory')
          .update({'isVisible': isVisible}).eq('itemID', itemID);
    } catch (err) {
      print('Error updating Item:$itemID visibility. Error Message: $err');
    }
  }

  Future<void> addItem(String itemName, int itemTypeID, String itemDescription,
      int quantity, int supplierID, double itemPrice) async {
    try {
      await supabaseDB.from('item_inventory').insert({
        'itemName': itemName,
        'itemTypeID': itemTypeID,
        'itemDescription': itemDescription,
        'itemQuantity': quantity,
        'supplierID': supplierID,
        'itemPrice': itemPrice,
        'isVisible': true,
        'createDate': returnCurrentDate(),
        'updateDate': returnCurrentDate(),
      });
      addAuditLogs.insertAuditLog(
          'audit_inventory',
          1,
          "Added new item on the database: $itemName",
          "New Item"); //Test Employee ID first
      print("NEW ITEM ADDED: $itemName");
    } catch (err) {
      print('ERROR ADDING ITEM ($itemName) -- Info: $err');
    }
  }

  Future<void> updateItem(
      int itemID,
      String itemName,
      int itemTypeID,
      String itemDescription,
      int quantity,
      int supplierID,
      double itemPrice) async {
    try {
      await supabaseDB.from('item_inventory').update({
        'itemName': itemName,
        'itemTypeID': itemTypeID,
        'itemDescription': itemDescription,
        'itemQuantity': quantity,
        'supplierID': supplierID,
        'itemPrice': itemPrice,
        'updateDate': returnCurrentDate(),
      }).eq('itemID', itemID);
      addAuditLogs.insertAuditLog('audit_inventory', 1,
          "Updated existing item on the database: $itemName", "Updated Item");
      print("SUCCESS! -- UPDATED ITEM DETAILS: $itemName");
    } catch (err) {
      // Catch and print general exceptions
      print('UPDATE ERROR. ($itemName) -- Info: $err');
    }
  }

  Future<int> fetchCurrentQuantity(int? itemID) async {
    try {
      final fetchQuantity = await supabaseDB
          .from('item_inventory')
          .select('itemQuantity')
          .eq('itemID', itemID!);

      if (fetchQuantity.isNotEmpty) {
        final itemCurrentQuantity = fetchQuantity[0]
            ['itemQuantity']; //Just getting the quantity from the
        return itemCurrentQuantity;
      } else if (fetchQuantity.isEmpty) {
        return 0;
      } else if (fetchQuantity is String) {
        print('fetchQuantity returned as a String, not int.');
      } else {
        print('fetchQuantity is both not string and int.');
        return 0;
      }
    } catch (err, stackTrace) {
      print('Error fetching current item: $itemID quantity -- $stackTrace');
      return 0;
    }
    return 0;
  }

  Future<void> updateQuantity(int itemID, int newQuantity) async {
    int oldQuantity = await fetchCurrentQuantity(
        itemID); //Fetching lang the value from the Function that returns a Future<int>
    int updatedQuantity = oldQuantity + newQuantity; //Adding new
    try {
      await supabaseDB
          .from('item_inventory')
          .update({'itemQuantity': updatedQuantity}).eq('itemID', itemID);
    } catch (err) {
      print('Error updating quantity of the product: $itemID. Message: $err');
    }
  }
}
