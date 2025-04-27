import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart'; // Date Defaults only

// Inventory Related Backend 
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart'; 

// For Audit Logs only -- Essentially handling the historical action data
//TODO: Add Audit Services
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

//TODO: User Settable
const int defaultItemsPerPage = 10;

class SerialitemService {
  final AuditServices addAuditLogs = AuditServices();

  String commonlyUsedJoin() {
    return ''' *,
      product_definitions ( prodDefName, prodDefMSRP ),
      suppliers ( supplierName ),
      booking_details ( bookingID )
    ''';
  }

  //Fetch Functionalities
  Future<List<SerializedItem>> fetchSerializedItems({
    String? prodDefID,
    String? status,
    int? currentBookingID,
    int? employeeID,
    int? supplierID,
    String? searchQuery,

    //For Pagination and Sorting
    String sortBy = 'serialNumber',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try{
      //Defining JOINS for search can be in a way "Global"
      String selectQuery = commonlyUsedJoin();

      //Building the query here and the filters will be applied under
      var fetchItemSerials = supabaseDB.from('item_serials').select(selectQuery);

      //Different Filters
      if (prodDefID != null) fetchItemSerials = fetchItemSerials.eq('prodDefID', prodDefID); 
      if (status != null) fetchItemSerials = fetchItemSerials.eq('status', status);
      if (currentBookingID != null) fetchItemSerials = fetchItemSerials.eq('bookingID', currentBookingID);
      if (employeeID != null) fetchItemSerials = fetchItemSerials.eq('employeeID', employeeID);
      if (supplierID != null) fetchItemSerials = fetchItemSerials.eq('supplierID', supplierID);
      //Apply the search here
      if(searchQuery != null && searchQuery.isNotEmpty){
        final searchTerm = '%$searchQuery%';

        fetchItemSerials = fetchItemSerials.or(
          'serialNumber.ilike.$searchTerm,' 
          'notes.ilike.$searchTerm,'
          'product_definitions.prodDefName.ilike.$searchTerm,' 
          'suppliers.supplierName.ilike.$searchTerm,' 
          'booking_details.bookingID.ilike.$searchTerm' 
        );
      }

      //Sorting
      final offset = (page - 1) * itemsPerPage;
      final limit = offset + itemsPerPage - 1;

      final fetchedResults = await fetchItemSerials.order(sortBy, ascending: ascending).range(offset, limit);

      //Verifying if there are any entries inside the fetched File
      if(fetchedResults.isEmpty) return [];

      return fetchedResults.map((item) => SerializedItem.fromJson(item)).toList();
    }catch(err, st){
      print('Error fetching all serialized items. \n $err \n $st');
      rethrow;
    }
  }

  //Fetching the total count of specified Serialized Items, used ni for pagination ;) 
  Future<int> getTotalSerializedItemCount({
    String? prodDefID,
    String? status,
    int? currentBookingID,
    int? employeeID,
    int? supplierID,
    String? searchQuery,
  }) async {
    try{
      var fetchSerialsCount = supabaseDB.from('item_serials').select();
      
      //Filters
      if (prodDefID != null) fetchSerialsCount = fetchSerialsCount.eq('prodDefID', prodDefID);
      if (status != null) fetchSerialsCount = fetchSerialsCount.eq('status', status);
      if (currentBookingID != null) fetchSerialsCount = fetchSerialsCount.eq('bookingID', currentBookingID);
      if (employeeID != null) fetchSerialsCount = fetchSerialsCount.eq('employeeID', employeeID);
      if (supplierID != null) fetchSerialsCount = fetchSerialsCount.eq('supplierID', supplierID);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';
        fetchSerialsCount = fetchSerialsCount.or('serialNumber.ilike.$searchTerm,notes.ilike.$searchTerm');
      }
      
      final fetchedItemSerialsCount = await fetchSerialsCount;
      return fetchedItemSerialsCount.length;
    }catch(err,st){
      print('Error fetching serialized item count. \n $err \n $st');
      return 0;
    }
  }

  //Fetching specific details of the selected serials -- for edit/update functions ni
  Future<SerializedItem?> getSerializedItemBySerial (String serialNumber) async {
    try{
      String selectQuery = commonlyUsedJoin();

      final fetchSerialDetails = await supabaseDB.from('item_serials').select(selectQuery).eq('serialNumber', serialNumber).maybeSingle();

      if(fetchSerialDetails == null) return null;

      return SerializedItem.fromJson(fetchSerialDetails);
    }catch(err, st){
      print('Error fetching serialized item count. \n $err \n $st');
      rethrow;
    }
  }

  /// Fetches all visible status names from the item_status table.
  Future<List<String>> getAllItemStatuses() async {
    try {
      final results = await supabaseDB
          .from('item_status')
          .select('statusName')
          .order('statusName', ascending: true); // Optional: order them

      if (results.isEmpty) {
        print("No visible item statuses found.");
        return [];
      }
      // Extract just the status names into a list of strings
      return results.map<String>((row) => row['statusName'] as String).toList();
    } catch (err, st) {
      print('Error fetching item statuses: $err \n $st');
      rethrow;
    }
  }

  //Actual Methods for Adding, Updating

  Future<SerializedItem> addSerializedItem (SerializedItem newItem) async {
    try{
      final Map<String, dynamic> newSerialItem = newItem.toJson();
      String returnSelectQuery = commonlyUsedJoin();

      final serialResult = await supabaseDB.from('item_serials').insert(newSerialItem).select(returnSelectQuery).single();

      print('NEW SERIALIZED ITEM ADDED: ${newItem.serialNumber}');
      return SerializedItem.fromJson(serialResult);
    }catch(err, st){
      print('Error fetching serialized item count. \n $err \n $st');
      rethrow;
    }
  }

  Future<SerializedItem> updateSerializedItem(SerializedItem updatedItem) async {
    try{
      final dataToUpdate = {
        'status': updatedItem.status,
        'notes': updatedItem.notes,
        'bookingID': updatedItem.currentBookingID,
        'employeeID': updatedItem.employeeID,
        'costPrice': updatedItem.costPrice,
        'purchaseDate': updatedItem.purchaseDate?.toIso8601String(),
        'supplierID': updatedItem.supplierID,
        'updateDate':  returnCurrentDateTime(),
      };

      String returnSelectQuery = commonlyUsedJoin();

      final serialUpdateResult = await supabaseDB.from('item_serials').update(dataToUpdate).eq('serialNumber', updatedItem.serialNumber).select(returnSelectQuery).single();


      print('UPDATED SERIALIZED ITEM: ${updatedItem.serialNumber}');
      return SerializedItem.fromJson(serialUpdateResult);
    }catch(err, st){
      print('Error updating serialized item count. \n $err \n $st');
      rethrow;
    }
  }
}