import 'package:jcsd_flutter/api/global_variables.dart';

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
    String? manufacturerName,
  }) async {
    try{
      //Added JOINS for single-query for multiple reach functionality. Really powerful stuff.
      //Bale allows us to search names through their IDs

      //Note: Table Name, Table Column - for adding other selected queries
      const String selectPDQuery = '''
        *,
        item_types ( itemType ),
      ''';

      var fetchPDQuery = supabaseDB.from('product_definitions').select(selectPDQuery).eq('isVisible', isVisible);


      //Added new queries - for both itemTypeID and manufacturerID
      if (itemTypeID != null){
        fetchPDQuery.eq('itemTypeID', itemTypeID);
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty){
        fetchPDQuery.eq('manufacturerName', manufacturerName);
      }


      if(searchQuery != null && searchQuery.isNotEmpty){
        final searchTerm = "%$searchQuery%";

        fetchPDQuery = fetchPDQuery.or(
          'prodDefName.ilike.$searchTerm,'
          'prodDefDescription.ilike.$searchTerm,'
          'item_types.itemType.ilike.$searchTerm,'
          'manufacturerName.ilike.$searchTerm'
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
    String? manufacturerName,
  }) async {
    try{
      var countTotalPD = supabaseDB.from('product_definitions').select('prodDefID');

      countTotalPD = countTotalPD.eq('isVisible', isVisible);
      
      //Added new queries - for both itemTypeID and manufacturerID
      if (itemTypeID != null){
        countTotalPD.eq('itemTypeID', itemTypeID);
      }

      if (manufacturerName != null){
        countTotalPD.eq('manufacturerName', manufacturerName);
      }

      //Search is only applied to these 4 data types
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
      //Force JOINS to fetch results from the ItemTypes - bale ItemTypeID: 1 {Accesorries} - gidikit sa isa ka result ba. No need for a separate query na

      const String selectPDQuery = '''*, item_types ( itemType )''';

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
      const String returnSelectQuery = '''*, item_types ( itemType )''';

      final addNewProdDef = await supabaseDB.from('product_definitions').insert(newProdDef.toJson()).select(returnSelectQuery).single();

      print('ADDED NEW PRODUCT DEFINITION: ${newProdDef.prodDefName}');
      return ProductDefinitionData.fromJson(addNewProdDef);

      //TODO: Add Audit Logs
    }catch(err, st){
      print('Error adding new product definition.\n $err \n $st');
      rethrow;
    }
  }

  Future<ProductDefinitionData> updateProductDefinition(ProductDefinitionData updProdDef) async {
    final dataToUpdate = updProdDef.toJson();

    if(updProdDef.prodDefID == null){
      throw ArgumentError('Cannot update PD without a PD ID \n Product Defition has a null ID.');
    }

    try{
      const String returnSelectQuery = '''*, item_types ( itemType )''';
      

      //Added non-null to consider the nullable nature of out PD id
      final updateProdDef = await supabaseDB.from('product_definitions').update(dataToUpdate).eq('prodDefID', updProdDef.prodDefID!).select(returnSelectQuery).single();

      //Insert Audit Log for Update Here - TBA lang
      print('UPDATED PRODUCT DEFINITION: ${updProdDef.prodDefName}');
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