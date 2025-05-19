import 'package:jcsd_flutter/api/global_variables.dart';

// Inventory Related Backend
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';

// For Audit Logs only -- Essentially handling the historical action data
import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

//Set default limit - hardcoded
//TODO: User settable - soon once for QA/Polishing
const int defaultItemsPerPage = 10;

class ProductDefinitionServices {
  AuditServices addAuditLogs = AuditServices();

  //JOIN Select Query
  static const String _baseProductDefinitionsSelect = '''
    prodDefID,
    prodDefName,
    prodDefDescription,
    manufacturerName, 
    createDate,
    updateDate,
    prodDefMSRP,
    isVisible,
    itemTypeID,
    desiredStockLevel,
    preferredSupplierID,
    manufacturerName,
    item_serials(count)
''';

  //Fetches selected product definitions, mainly basing whether such PD is active/archived
  Future<List<ProductDefinitionData>> fetchProductDefinitions({
    String sortBy = 'itemID',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
    String? searchQuery,
    bool isVisible = true,
    int? itemTypeID,
    String? manufacturerName,
  }) async {
    try {
      var fetchPDQuery = supabaseDB
          .from('product_definitions')
          .select(_baseProductDefinitionsSelect)
          .eq('isVisible', isVisible);

      //Added new queries - for both itemTypeID and manufacturerID
      if (itemTypeID != null) {
        fetchPDQuery.eq('itemTypeID', itemTypeID);
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        fetchPDQuery.eq('manufacturerName', manufacturerName);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = "%$searchQuery%";

        fetchPDQuery = fetchPDQuery.or('prodDefName.ilike.$searchTerm,'
            'prodDefDescription.ilike.$searchTerm');
      }

      //Pages
      final offset = (page - 1) * itemsPerPage;
      final limit = offset + itemsPerPage - 1;

      final fetchedResults = await fetchPDQuery
          .order(sortBy, ascending: ascending)
          .range(offset, limit);

      //Final checks just for data validation
      if (fetchedResults.isEmpty) return [];

      return fetchedResults
          .map((item) => ProductDefinitionData.fromJson(item))
          .toList();
    } catch (err, st) {
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
    try {
      var countTotalPD =
          supabaseDB.from('product_definitions').select('prodDefID');

      countTotalPD = countTotalPD.eq('isVisible', isVisible);

      //Added new queries - for both itemTypeID and manufacturerID
      if (itemTypeID != null) {
        countTotalPD.eq('itemTypeID', itemTypeID);
      }

      if (manufacturerName != null) {
        countTotalPD.eq('manufacturerName', manufacturerName);
      }

      //Search is only applied to these 4 data types
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = "%$searchQuery%";

        countTotalPD = countTotalPD.or('prodDefName.ilike.$searchTerm,'
            'prodDefDescription.ilike.$searchTerm,'
            'itemTypeID::text.ilike.$searchTerm,'
            //'manufacturers.manufacturerName.ilike.$searchTerm'
            );
      }

      final finalCount = await countTotalPD;
      return finalCount.length;
    } catch (err, st) {
      print('Error fetching product definition count: $err \n $st');
      return 0;
    }
  }

  //Fetches all active Product Definitions; mainly for the Dropdown
  Future<List<ProductDefinitionData>> getAllActiveProductDefinitions() async {
    try {
      final activePDQuery = await supabaseDB
          .from('product_definitions')
          .select(_baseProductDefinitionsSelect)
          .eq('isVisible', true)
          .order('prodDefName', ascending: true);

      if (activePDQuery.isEmpty) return [];

      return activePDQuery
          .map((item) => ProductDefinitionData.fromJson(item))
          .toList();
    } catch (err, st) {
      print('Error fetching product definition count: $err \n $st');
      return [];
    }
  }

  Future<List<ProductDefinitionData>> fetchAllActiveProductDefinitions({
    String? searchQuery,
    String sortBy = 'prodDefName', // Default sort for the full list
    bool ascending = true,
  }) async {
    try {
      var query = supabaseDB
          .from('product_definitions')
          .select(
              _baseProductDefinitionsSelect) // Ensure this fetches 'item_serials(count)'
          .eq('isVisible', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = "%$searchQuery%";
        // Adjust search fields as needed. This example searches name and description.
        query = query.or(
            'prodDefName.ilike.$searchTerm,prodDefDescription.ilike.$searchTerm');
      }
      // No .range() for pagination, fetch all that match
      final results = await query.order(sortBy, ascending: ascending);

      if (results.isEmpty) return [];
      return results
          .map((item) => ProductDefinitionData.fromJson(item))
          .toList();
    } catch (err, st) {
      print('Error fetching all active product definitions: $err \n $st');
      rethrow; // Rethrow to be caught by the FutureProvider
    }
  }

  //Add - Update - Archive Methods
  Future<ProductDefinitionData> addProductDefinition(
      ProductDefinitionData newProdDef) async {
    try {
      final addNewProdDef = await supabaseDB
          .from('product_definitions')
          .insert(newProdDef.toJson())
          .select(_baseProductDefinitionsSelect)
          .single();

      print('ADDED NEW PRODUCT DEFINITION: ${newProdDef.prodDefName}');
      return ProductDefinitionData.fromJson(addNewProdDef);

      //TODO: Add Audit Logs
    } catch (err, st) {
      print('Error adding new product definition.\n $err \n $st');
      rethrow;
    }
  }

  Future<ProductDefinitionData> updateProductDefinition(
      ProductDefinitionData updProdDef) async {
    final dataToUpdate = updProdDef.toJson();

    if (updProdDef.prodDefID == null) {
      throw ArgumentError(
          'Cannot update PD without a PD ID \n Product Defition has a null ID.');
    }

    try {
      const String returnSelectQuery = '''*, item_types ( itemType )''';

      //Added non-null to consider the nullable nature of out PD id
      final updateProdDef = await supabaseDB
          .from('product_definitions')
          .update(dataToUpdate)
          .eq('prodDefID', updProdDef.prodDefID!)
          .select(returnSelectQuery)
          .single();

      //Insert Audit Log for Update Here - TBA lang
      print('UPDATED PRODUCT DEFINITION: ${updProdDef.prodDefName}');
      return ProductDefinitionData.fromJson(updateProdDef);
    } catch (err, st) {
      print('Error updating product definition.\n $err \n $st');
      rethrow;
    }
  }

  Future<void> updateProductDefinitionVisibility(
      String prodDefID, bool isVisible) async {
    try {
      //TODO: Add Audit Logs -- Later ni

      String action;

      if (isVisible) {
        action = 'Restored';
      } else {
        action = 'Archived';
      }

      print('$action Product Definition: $prodDefID');

      await supabaseDB
          .from('product_definitions')
          .update({'isVisible': isVisible}).eq('prodDefID', prodDefID);

      print('Prod Definition visiblity of $prodDefID set to $isVisible');
    } catch (err, st) {
      print(
          'Error updating product definition visibility: $prodDefID \n $err \n $st');
      rethrow;
    }
  }
}
