import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart'; // Date Defaults only

// Inventory Related Backend 
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart'; 

// For Audit Logs only -- Essentially handling the historical action data
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';


//Set default limit - hardcoded
//TODO: User settable - soon once for QA/Polishing
const int defaultItemsPerPage = 10;

class ProductDefinitionServices{
  AuditServices addAuditLogs = AuditServices();

  //Fetches selected product definitions, mainly basing whether such PD is active/archived
  Future<List<ProductDefinitionData>> fetchProductDefinitions({
    String sortBy = 'itemID',
    bool ascending = true,
    int page  = 1,
    int itemsPerPage = defaultItemsPerPage,
    String? searchQuery,
    bool isVisible = true,

    //Additional filters that I added lang
    int? itemTypeID,
    int? manufacturerID,
  }) async {
    try{
      //Added JOINS for single-query for multiple reach functionality. Really powerful stuff.
      //Bale allows us to search names through their IDs

      //Note: Table Name, Table Column - for adding other selected queries
      const String selectPDQuery = '''
        *,
        item_types ( itemType ),
        manufacturers ( manufacturerName ) 
      ''';

      var fetchPDQuery = supabaseDB.from('product_definitions').select(selectPDQuery).eq('isVisible', isVisible);


      //Added new queries - for both itemTypeID and manufacturerID
      if (itemTypeID != null){
        fetchPDQuery.eq('itemTypeID', itemTypeID);
      }

      if (manufacturerID != null){
        fetchPDQuery.eq('manufacturerID', manufacturerID);
      }


      if(searchQuery != null && searchQuery.isNotEmpty){
        final searchTerm = "%$searchQuery%";

        fetchPDQuery = fetchPDQuery.or(
          'prodDefName.ilike.$searchTerm,'
          'prodDefDescription.ilike.$searchTerm,'
          'itemTypeID::text.ilike.$searchTerm,' 
          'manufacturerID::text.ilike.$searchTerm,'
          'item_types.itemType.ilike.$searchTerm,'
          'manufacturers.manufacturerName.ilike.$searchTerm'
        );
      }

      //Actual Sorting functionality -- essentially we're doing here are all service-side functionality to lessen load

      //Pages
      final offset = (page - 1)*itemsPerPage;
      final limit = offset + itemsPerPage - 1;

      final fetchedResults = await fetchPDQuery.order(sortBy, ascending: ascending).range(offset, limit);

      //Final checks just for data validation
      if(fetchedResults.isEmpty) return [];
      
      return fetchedResults.map((item) => ProductDefinitionData.fromJson(item)).toList();

    }catch(err, st){  
      print('Error fetching the product definitions. \n $err \n $st');
      return [];
    }
  }

  Future<int> getTotalProductDefinitionCount({
    String? searchQuery,
    bool isVisible = true,
    int? itemTypeID,
    int? manufacturerID,
  }) async {
    try{
      var countTotalPD = supabaseDB.from('product_definitions').select();

      countTotalPD = countTotalPD.eq('isVisible', isVisible);
      
      //Added new queries - for both itemTypeID and manufacturerID
      if (itemTypeID != null){
        countTotalPD.eq('itemTypeID', itemTypeID);
      }

      if (manufacturerID != null){
        countTotalPD.eq('manufacturerID', manufacturerID);
      }

      if(searchQuery != null && searchQuery.isNotEmpty){
        final searchTerm = "%$searchQuery%";

        countTotalPD = countTotalPD.or(
          'prodDefName.ilike.$searchTerm,'
          'prodDefDescription.ilike.$searchTerm,'
          'itemTypeID::text.ilike.$searchTerm,' 
          'manufacturers.manufacturerName.ilike.$searchTerm'
        );
      }

      final finalCount = await countTotalPD;
      return finalCount.length;
    }catch(err, st){
      print('Error fetching product definition count: $err \n $st');
      return 0;
    }
  }

  //Fetches all active na PD
  //Para rani sa dropdown, so strict ang viewing ani. Removed pagination function
  Future<List<ProductDefinitionData>> getAllActiveProductDefinitions() async {
    try{
      //JOINS purpose, can search on other tables too, but limited lang for the itemType and ManufacturerName kay sa table nato mga IDs ra ang reference, but thru this pwede nato ma fetch ilang data with a single query nalang. Aamzing
      const String selectPDQuery = '''*, item_types ( itemType ), manufacturers ( manufacturerName )''';

      final activePDQuery = await supabaseDB.from('product_definitions').select(selectPDQuery).eq('isVisible', true).order('prodDefName',ascending: true);

      if(activePDQuery.isEmpty) return [];

      return activePDQuery.map((item) => ProductDefinitionData.fromJson(item)).toList();
    }catch(err,st){
      print('Error fetching product definition count: $err \n $st');
      return [];
    }
  }

  //Add - Update - Archive Methods
  Future<ProductDefinitionData> addProductDefinition(ProductDefinitionData newProdDef) async {
    try{
       const String returnSelectQuery = '''*, item_types ( itemType ), manufacturers ( manufacturerName )''';

      final addNewProdDef = await supabaseDB.from('product_definitions').insert(newProdDef.toJson()).select(returnSelectQuery).single();

      print('ADDED NEW PRODUCT DEFINITION: ${newProdDef.profDefName}');
      return ProductDefinitionData.fromJson(addNewProdDef);

      //TODO: Add Audit Logs
    }catch(err, st){
      print('Error adding new product definition.\n $err \n $st');
      rethrow;
    }
  }

  Future<ProductDefinitionData> updateProductDefinition(ProductDefinitionData newProdDef) async {
    try{
      const String returnSelectQuery = '''*, item_types ( itemType ), manufacturers ( manufacturerName )''';

      final updateProdDef = await supabaseDB.from('product_definitions').update(newProdDef.toJson()).eq('prodDefID', newProdDef.profDefID).select(returnSelectQuery).single();

      //Insert Audit Log for Update Here - TBA lang
      print('UPDATED PRODUCT DEFINITION: ${newProdDef.profDefName}');
      return ProductDefinitionData.fromJson(updateProdDef);
    }catch(err, st){
      print('Error updating product definition.\n $err \n $st');
      rethrow;
    }
  }

  Future<void> updateProductDefinitionVisibility(String prodDefID, bool isVisible) async {
    try{
      //TODO: Add Audit Logs -- Later ni

      String action;

      if(isVisible){
        action = 'Restored';
      }else{
        action = 'Archived';
      }

      print('$action Product Definition: $prodDefID');

      await supabaseDB.from('product_definitions').update({'isVisible': isVisible}).eq('prodDefID', prodDefID);

      print('Prod Definition visiblity of $prodDefID set to $isVisible');
    }catch(err, st){
      print('Error updating product definition visibility: $prodDefID \n $err \n $st');
      rethrow;
    }
  }
  //April 24 Edit: Removed Dropdown helper functions. Focus rani na file for Product Definitions
}