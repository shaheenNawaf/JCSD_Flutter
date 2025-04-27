// --- serialized_item_service.dart ---

import 'package:flutter/widgets.dart';
import 'package:jcsd_flutter/api/global_variables.dart';

// Inventory Related Backend
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';

// For Audit Logs only -- Essentially handling the historical action data
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

// User Settable or constant
const int defaultItemsPerPage = 10;

// Renamed class for consistency
class ManufacturersService {
  final AuditServices addAuditLogs = AuditServices(); // Uncomment if using

  Future<List<ManufacturersData>> fetchAllManufacturers({
    bool? isActive,
    String? searchQuery,
    String sortBy = 'manufacturerName',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try{
      var fetchManufacturers = supabaseDB.from('manufacturers').select();

      //Filters are under here
      if(isActive != null) {
        fetchManufacturers = fetchManufacturers.eq('isActive', isActive);
      }

      //Search
      if(searchQuery != null && searchQuery.isNotEmpty){
        final searchTerm = '%$searchQuery%';
        fetchManufacturers = fetchManufacturers.or(
          'manufacturerName.ilike.$searchTerm,'
          'manufacturerEmail.ilike.$searchTerm,'
          'contactNumber.ilike.$searchTerm,'
          'address.ilike.$searchTerm'
        );
      }

      //Sorting
      final offset = (page - 1) * itemsPerPage;
      final limit  = offset + itemsPerPage - 1;

      final results = await fetchManufacturers.order(sortBy, ascending: ascending).range(offset, limit);

      //Checking and returning results
      if(results.isEmpty){
        print("fetchManufacturers: No results found.");
        return [];
      } 

      return results.map((item) => ManufacturersData.fromJson(item)).toList();
    }catch(err,st){
      print('Error fetching manufacturers: $err \n $st');
      return [];
    }
  }

  Future<int> getTotalManufacturerCount({
    bool? isActive,
    String? searchQuery,

  }) async {
    try{
      var fetchTotalManufacturers = supabaseDB.from('manufacturers').select();

      if(isActive != null){
        fetchTotalManufacturers = fetchTotalManufacturers.eq('isActive', isActive);
      }

      //Search Filter handler here
      if(searchQuery != null && searchQuery.isNotEmpty){
        final searchTerm = '%$searchQuery%';
        fetchTotalManufacturers = fetchTotalManufacturers.or(
          'manufacturerName.ilike.$searchTerm,'
          'manufacturerEmail.ilike.$searchTerm,'
          'contactNumber.ilike.$searchTerm,'
          'address.ilike.$searchTerm'
        );
      }

      final totalManufactures = await fetchTotalManufacturers;
      return totalManufactures.length;
    }catch(err,st){
      print('Error fetching total manufacturers: $err \n $st');
      return 0;
    }
  }

  //For Dropdown functionality
  Future<List<ManufacturersData>> getAllManufacturersForSelect({
    bool activeOny = false,
  }) async {
    try{
       var fetchAllManufacturers = supabaseDB.from('manufacturers').select();
  
       
       if(activeOny){
        fetchAllManufacturers = fetchAllManufacturers.eq('isActive', activeOny);
       }

       
    }catch(err, st){
      print('Error fetching the active manufacturers: $err \n $st');
      rethrow;
    }
  }

  //Add-Update-Update Visibility

}