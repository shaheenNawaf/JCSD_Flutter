import 'package:jcsd_flutter/api/global_variables.dart';

// Inventory Related Backend
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';

// For Audit Logs only -- Essentially handling the historical action data
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

// User Settable or constant
const int defaultItemsPerPage = 10;

class ManufacturersService {
  final AuditServices addAuditLogs = AuditServices();

  Future<List<ManufacturersData>> fetchAllManufacturers({
    bool? isActive,
    String? searchQuery,
    String sortBy = 'manufacturerName',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try {
      var fetchManufacturers = supabaseDB.from('manufacturers').select();

      //Filters are under here
      if (isActive != null) {
        fetchManufacturers = fetchManufacturers.eq('isActive', isActive);
      }

      //Search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';
        fetchManufacturers =
            fetchManufacturers.or('manufacturerName.ilike.$searchTerm,'
                'manufacturerEmail.ilike.$searchTerm,'
                'contactNumber.ilike.$searchTerm,'
                'address.ilike.$searchTerm');
      }

      //Sorting
      final offset = (page - 1) * itemsPerPage;
      final limit = offset + itemsPerPage - 1;

      final results = await fetchManufacturers
          .order(sortBy, ascending: ascending)
          .range(offset, limit);

      //Checking and returning results
      if (results.isEmpty) {
        print("fetchManufacturers: No results found.");
        return [];
      }

      return results.map((item) => ManufacturersData.fromJson(item)).toList();
    } catch (err, st) {
      print('Error fetching manufacturers: $err \n $st');
      return [];
    }
  }

  //Gets the toal count of manufactures based on optional filters (kanang ma-grab niyag tarong ang count for the different results based on the applied filters and serach)
  Future<int> getTotalManufacturerCount({
    bool? isActive,
    String? searchQuery,
  }) async {
    try {
      var fetchTotalManufacturers = supabaseDB.from('manufacturers').select();

      if (isActive != null) {
        fetchTotalManufacturers =
            fetchTotalManufacturers.eq('isActive', isActive);
      }

      //Search Filter handler here
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';
        fetchTotalManufacturers =
            fetchTotalManufacturers.or('manufacturerName.ilike.$searchTerm,'
                'manufacturerEmail.ilike.$searchTerm,'
                'contactNumber.ilike.$searchTerm,'
                'address.ilike.$searchTerm');
      }

      final totalManufactures = await fetchTotalManufacturers;
      return totalManufactures.length;
    } catch (err, st) {
      print('Error fetching total manufacturers: $err \n $st');
      return 0;
    }
  }

  //For Dropdown functionality, displaying only the active ones
  Future<List<ManufacturersData>> getAllManufacturersForSelect(
      {bool activeOnly = true}) async {
    try {
      var fetchAllManufacturers = supabaseDB.from('manufacturers').select();

      if (activeOnly) {
        fetchAllManufacturers = fetchAllManufacturers.eq('isActive', true);
      }

      //Default Ascending order for proper display
      final filteredManufacturers = await fetchAllManufacturers
          .order('manufacturerName', ascending: true);

      //Checking for if list isn't empty
      if (filteredManufacturers.isEmpty) {
        return [];
      }

      return filteredManufacturers
          .map((item) => ManufacturersData.fromJson(item))
          .toList();
    } catch (err, st) {
      print('Error fetching the active manufacturers: $err \n $st');
      rethrow;
    }
  }

  //Add-Update-Update Visibility

  Future<ManufacturersData> addNewManufacturer({
    required String manufacturerName,
    required String manufacturerEmail,
    required String contactNumber,
    required String address,
  }) async {
    try {
      final newManufacturer = {
        'manufacturerName': manufacturerName,
        'manufacturerEmail': manufacturerEmail,
        'contactNumber': contactNumber,
        'address': address,
        'isActive': true,
      };

      final addedManufacturer = await supabaseDB
          .from('manufacturers')
          .insert(newManufacturer)
          .select(
              'manufacturerID, manufacturerName, manufacturerEmail, contactNumber, createdDate, updateDate, isActive, address')
          .single();

      print("NEW MANUFACTURER ADDED: $manufacturerName");

      return ManufacturersData.fromJson(addedManufacturer);
    } catch (err, st) {
      print('ERROR ADDING MANUFACTURER ($manufacturerName): $err \n $st');
      rethrow;
    }
  }

  //Update Manufacturer
  Future<ManufacturersData> updateManufacturer({
    required int manufacturerID,
    required String manufacturerName,
    required String manufacturerEmail,
    required String contactNumber,
    required String address,
  }) async {
    try {
      final manufacturerData = {
        'manufacturerName': manufacturerName,
        'manufacturerEmail': manufacturerEmail,
        'contactNumber': contactNumber,
        'address': address,
      };

      final updatedManufacturerDetails = await supabaseDB
          .from('manufacturers')
          .update(manufacturerData)
          .eq('manufacturerID', manufacturerID)
          .select(
              'manufacturerID, manufacturerName, manufacturerEmail, contactNumber, createdDate, updateDate, isActive, address')
          .single();

      print("UPDATED MANUFACTURER: $manufacturerName (ID: $manufacturerID)");

      return ManufacturersData.fromJson(updatedManufacturerDetails);
    } catch (err, st) {
      print('ERROR UPDATING MANUFACTURER ($manufacturerName): $err \n $st');
      rethrow;
    }
  }

  //updateManufacturer Visibility
  Future<void> updateManufacturerVisibility({
    required int manufacturerID,
    required bool isActive,
    int? employeeID,
  }) async {
    await supabaseDB.from('manufacturers').update({
      'isActive': isActive,
      // 'updateDate': returnCurrentDateTime(), // Update timestamp if needed
    }).eq('manufacturerID', manufacturerID);

    final action = isActive ? "Restored" : "Archived";
    print("$action Manufacturer ID: $manufacturerID");

    //Adding Audit Logs here -- add employeeID parameter on all functionable items
  }
}
