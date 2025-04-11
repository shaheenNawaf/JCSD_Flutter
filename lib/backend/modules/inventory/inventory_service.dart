import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart';

///Inventory Data - using the class that I made to store data
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_name_id.dart';

// Notes inserted here
// Dart allows ? as assigned null, added nako here para ma handle sa function if may empty na parameter when called

const int defaultItemsPerPage = 10; //Hardcoded limit

class InventoryService {
  AuditServices addAuditLogs = AuditServices();

  //Functions that return either: ID -> NAME or NAME -> ID
  Future<InventoryData?> getItemByID(int itemID) async {
    try {
      final fetchItem = await supabaseDB
          .from('item_inventory')
          .select()
          .eq('itemID', itemID)
          .maybeSingle();
      if (fetchItem == null) {
        print("Item not found based on the given itemID: $itemID");
        return null;
      } else {
        print("Item is present in the table: $itemID");
        return InventoryData.fromJson(fetchItem);
      }
    } catch (err) {
      print('Error accessing table: $err');
      return null;
    }
  }

  Future<bool?> fetchDataIsComplete(int itemID) async {
    try {
      final checker = await supabaseDB
          .from('item_inventory')
          .select()
          .eq('itemID', itemID)
          .maybeSingle();

      if (checker == null) {
        return false;
      }
      return true;
    } catch (error) {
      print('Error accessing table: $error');
      return false;
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

  //Note: Displays all of the
  //Search Function: Finds based on Name, ID, Type
  Future<List<InventoryData>> searchItems({
    int? itemID,
    String? itemName,
    String? itemType,
    int page = 1,
    int itemsPerPage = 10,
    String sortBy = 'itemID',
    bool isVisible = true,
    bool ascending = true,
  }) async {
    try {
      final query = supabaseDB.from('item_inventory').select();

      if (itemID != null) {
        query
            .eq('itemID', itemID)
            .range((page - 1) * itemsPerPage, page * itemsPerPage - 1);
      }
      if (itemName != null) {
        query
            .eq('itemName', itemName)
            .range((page - 1) * itemsPerPage, page * itemsPerPage - 1);
      }
      if (itemType != null) {
        query
            .eq('itemType', itemType)
            .range((page - 1) * itemsPerPage, page * itemsPerPage - 1);
      }

      final results = await query.order(sortBy, ascending: ascending);

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
      final results = await supabaseDB
          .from('item_inventory')
          .select()
          .order('itemID', ascending: true);
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

  Future<int> totalItemCount(
      {required bool isVisible, String? searchQuery}) async {
    try {
      var initialQuery = supabaseDB.from('item_inventory').select();

      //Other filters
      initialQuery = initialQuery.eq('isVisible', isVisible);
      //For the Search Filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchText = "%$searchQuery%";
        initialQuery = initialQuery.or('itemName.ilike.$searchText'
            'itemDescription.ilike.$searchText'
            'itemQuantity::text.ilike.$searchText'
            'supplierID::text.ilike.$searchText');
      }

      final finalFetchedItems = await initialQuery;
      return finalFetchedItems.length;
    } catch (err) {
      print('Error fetching item count. $err');
      return 0;
    }
  }

  Future<int> totalActiveItemCount({String? searchQuery}) async {
    return totalItemCount(isVisible: true, searchQuery: searchQuery);
  }

  Future<int> totalArchivedItemCount({String? searchQuery}) async {
    return totalItemCount(isVisible: false, searchQuery: searchQuery);
  }

  /// Functions that involve viewing items based on their statuses

  // Handle both active and archived items
  Future<List<InventoryData>> fetchItems({
    required bool? isVisible,
    String sortBy = 'itemID',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
    String? searchQuery,
  }) async {
    try {
      var initialQuery = supabaseDB.from('item_inventory').select();

      //For visibility params - archived/active
      if (isVisible != null) {
        initialQuery = initialQuery.eq('isVisible', isVisible);
      }

      //For the Search Filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchText = '%$searchQuery%';
        initialQuery = initialQuery.or('itemName.ilike.$searchText,'
            'itemDescription.ilike.$searchText');
      }

      //Pagination
      final offset = (page - 1) * itemsPerPage;
      final limit = offset + itemsPerPage - 1;

      //Combined function for both sorting and pagination
      //Note: Sorting is still client-side
      final fetchResults = await initialQuery
          .order(sortBy, ascending: ascending)
          .range(offset, limit);

      //Validation, just to check if may laman or wala
      if (fetchResults.isEmpty) {
        print('No items found on the database.');
        return [];
      }

      //Final - returning the results
      final fetchedItems = fetchResults
          .map<InventoryData>((item) => InventoryData.fromJson(item))
          .toList();
      return fetchedItems;
    } catch (err, stackTrace) {
      print('Error fetching items. $err \n $stackTrace');
      return [];
    }
  }

  Future<List<ItemNameID>> getActiveItemNamesAndID() async {
    try {
      final queryResults = await supabaseDB
          .from('item_inventory')
          .select('itemID, itemName')
          .eq('isVisible', true)
          .order('itemName', ascending: true);

      if (queryResults.isEmpty) {
        return [];
      } else {
        return queryResults
            .map((item) =>
                ItemNameID(itemID: item['itemID'], itemName: item['itemName']))
            .toList();
      }
    } catch (error, stackTrace) {
      print(
          'Error fetching the active items from the database. \n $error \n $stackTrace');
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

  Future<InventoryData> addItem(
      String itemName,
      int itemTypeID,
      String itemDescription,
      int quantity,
      int supplierID,
      double itemPrice) async {
    try {
      final addNewItem = await supabaseDB
          .from('item_inventory')
          .insert({
            'itemName': itemName,
            'itemTypeID': itemTypeID,
            'itemDescription': itemDescription,
            'itemQuantity': quantity,
            'supplierID': supplierID,
            'itemPrice': itemPrice,
            'isVisible': true,
            'createDate': returnCurrentDate(),
            'updateDate': returnCurrentDate(),
          })
          .select()
          .single();

      //For Audit Logs
      addAuditLogs.insertAuditLog(
          'audit_inventory',
          1,
          "Added new item on the database: $itemName",
          "New Item"); //Test Employee ID first

      //Debug Message
      print("NEW ITEM ADDED: $itemName");

      //Returning the newly inserted data
      return InventoryData.fromJson(addNewItem);
    } catch (err) {
      print('ERROR ADDING ITEM ($itemName) -- Info: $err');
      rethrow;
    }
  }

  Future<InventoryData> updateItem(int itemID, String itemName, int itemTypeID,
      int supplierID, String itemDescription, double itemPrice) async {
    try {
      final updatedItem = await supabaseDB
          .from('item_inventory')
          .update({
            'itemName': itemName,
            'itemTypeID': itemTypeID,
            'itemDescription': itemDescription,
            'supplierID': supplierID,
            'itemPrice': itemPrice,
            'updateDate': returnCurrentDate(),
          })
          .eq('itemID', itemID)
          .select()
          .single();

      //For Audit Logs
      addAuditLogs.insertAuditLog('audit_inventory', 1,
          "Updated existing item on the database: $itemName", "Updated Item");

      //Debug Message
      print("SUCCESS! -- UPDATED ITEM DETAILS: $itemName");

      //Returning a new InventoryData object
      return InventoryData.fromJson(updatedItem);
    } catch (err) {
      //Debug Message ulet!
      print('UPDATE ERROR. ($itemName) -- Info: $err');
      rethrow;
    }
  }

  Future<InventoryData> updateItemQuantity(int itemID, int newQuantity) async {
    //Fetch current quantity from the database
    int oldQuantity = await fetchCurrentQuantity(itemID);
    int updatedQuantity = newQuantity + oldQuantity;
    final updatedItem = await supabaseDB
        .from('item_inventory')
        .update({
          'itemQuantity': updatedQuantity,
        })
        .eq('itemID', itemID)
        .select()
        .single();

    return InventoryData.fromJson(updatedItem);
  }

  Future<int> fetchCurrentQuantity(int itemID) async {
    final fetchQuantity = await supabaseDB
        .from('item_inventory')
        .select('itemQuantity')
        .eq('itemID', itemID)
        .maybeSingle();

    //Basically ensuring na naay sulod ang gifetch nato from the database.
    if (fetchQuantity != null && fetchQuantity['itemQuantity'] != null) {
      return (fetchQuantity['itemQuantity'] as num).toInt();
    } else {
      print(
          'Item with ID: $itemID not found on the database. Might be null, returning 0 instead.');
      return 0; //So it won't affect any outstanding value.
    }
  }
}
