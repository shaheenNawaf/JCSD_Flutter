// --- suppliers_service.dart --- // lib/backend/modules/suppliers/suppliers_service.dart

import 'package:flutter/foundation.dart'; // For kDebugMode potentially
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart'; // Ensure date helpers match DB types
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Keep for other types if needed

// For Audit Logs only -- Uncomment and implement if needed
// import 'package:jcsd_flutter/backend/modules/audit_logs/audit_services.dart';

// Default items per page constant
const int _defaultSupplierItemsPerPage = 10;

class SuppliersService {
  // final AuditServices addAuditLogs = AuditServices(); // Uncomment if using audit logs

  // --- NEW Methods for Notifier Support ---

  /// Fetches suppliers with optional filtering, search, sorting, and pagination.
  Future<List<SuppliersData>> fetchSuppliersFiltered({
    bool? isActive,
    String? searchQuery,
    String sortBy = 'supplierName',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = _defaultSupplierItemsPerPage,
  }) async {
    try {
      // Select fields matching the SuppliersData model
      var query = supabaseDB.from('suppliers').select(
          'supplierID, supplierEmail, supplierName, contactNumber, address, isActive, createdDate, updateDate' // Include dates if needed
          );

      // Apply filters
      if (isActive != null) {
        query = query.eq('isActive', isActive);
      }

      // Apply search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';
        query = query.or(
            'supplierName.ilike.$searchTerm,'
            'supplierEmail.ilike.$searchTerm,'
            'contactNumber.ilike.$searchTerm,' // Assumes contactNumber is text/varchar
            'address.ilike.$searchTerm');
      }

      // Apply pagination & sorting
      final offset = (page - 1) * itemsPerPage;
      final limit = offset + itemsPerPage - 1;

      final results =
          await query.order(sortBy, ascending: ascending).range(offset, limit);

      // Map results to data model
      return results.map((item) => SuppliersData.fromJson(item)).toList();
    } catch (err, st) {
      print('Error fetching filtered suppliers: $err \n $st');
      return []; // Return empty list on error
    }
  }

  /// Gets the total count of suppliers based on optional filters and search (using .length).
  Future<int> getTotalSupplierCount({
    bool? isActive,
    String? searchQuery,
  }) async {
    try {
      // Select only the primary key for efficiency when counting with .length
      var countQuery = supabaseDB.from('suppliers').select('supplierID');

      // Apply filters
      if (isActive != null) {
        countQuery = countQuery.eq('isActive', isActive);
      }

      // Apply search
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchTerm = '%$searchQuery%';
        countQuery = countQuery.or(
            'supplierName.ilike.$searchTerm,'
            'supplierEmail.ilike.$searchTerm,'
            'contactNumber.ilike.$searchTerm,'
            'address.ilike.$searchTerm');
      }

      // Fetch the list of matching rows
      final results = await countQuery;

      // Return the length of the list
      return results.length;
    } catch (err, st) {
      print('Error fetching total supplier count: $err \n $st');
      return 0;
    }
  }

  /// Fetches suppliers suitable for select/dropdown lists (typically active ones).
  Future<List<SuppliersData>> getAllSuppliersForSelect({
    bool activeOnly = true, // Default to fetching only active ones
  }) async {
    try {
      var query = supabaseDB.from('suppliers').select(
          'supplierID, supplierName, supplierEmail, contactNumber, address, isActive, createdDate, updateDate' // Select fields needed
          );

      if (activeOnly) {
        query = query.eq('isActive', true);
      }

      final results =
          await query.order('supplierName', ascending: true); // Order by name

      if (results.isEmpty) {
        return [];
      }

      return results.map((item) => SuppliersData.fromJson(item)).toList();
    } catch (err, st) {
      print('Error fetching suppliers for select: $err \n $st');
      rethrow;
    }
  }

  // --- Existing Methods (Kept for potential direct use, but notifier uses new methods) ---

  /// Fetches All Suppliers (Redundant if using notifier).
  Future<List<SuppliersData>> allSuppliers() async {
    // print("Note: 'allSuppliers' might be redundant. Use 'fetchSuppliersFiltered'.");
    return fetchSuppliersFiltered(isActive: null);
  }

  /// Fetches Available Suppliers (Redundant if using notifier).
  Future<List<SuppliersData>> availableSuppliers() async {
    // print("Note: 'availableSuppliers' might be redundant. Use 'fetchSuppliersFiltered(isActive: true)'.");
    return fetchSuppliersFiltered(isActive: true);
  }

  /// Fetches Archived Suppliers (Redundant if using notifier).
  Future<List<SuppliersData>> archivedSupliers() async {
    // print("Note: 'archivedSupliers' might be redundant. Use 'fetchSuppliersFiltered(isActive: false)'.");
    return fetchSuppliersFiltered(isActive: false);
  }

  /// Basic search (Redundant if using notifier).
  Future<List<SuppliersData>> searchSuppliers(
      {int? supplierID, String? supplierName, String? supplierEmail}) async {
    print("Note: 'searchSuppliers' is basic. Use 'fetchSuppliersFiltered' with searchQuery.");
    return fetchSuppliersFiltered(searchQuery: supplierName ?? supplierEmail); // Basic example
  }

  /// Load supplier's details by ID (Still useful).
  Future<SuppliersData?> getSupplierByID(int supplierID) async {
    try {
      final fetchSupplier = await supabaseDB
          .from('suppliers')
          .select(
              'supplierID, supplierEmail, supplierName, contactNumber, address, isActive, createdDate, updateDate')
          .eq('supplierID', supplierID)
          .maybeSingle();

      if (fetchSupplier == null) {
        return null;
      } else {
        return SuppliersData.fromJson(fetchSupplier);
      }
    } catch (err, st) {
      print('Error fetching supplier by ID $supplierID: $err \n $st');
      return null;
    }
  }

  /// Gets list of active supplier names (Still useful for simple name lists).
  Future<List<String>> getListOfSupplierNames() async {
    try {
      final fetchSuppliers = await supabaseDB
          .from('suppliers')
          .select('supplierName')
          .eq('isActive', true)
          .order('supplierName', ascending: true);

      if (fetchSuppliers.isEmpty) {
        return [];
      }
      return List<String>.from(
          fetchSuppliers.map((item) => item['supplierName'] as String));
    } catch (err) {
      print('Error fetching supplier names. $err');
      return [];
    }
  }

  /// Gets supplier name by ID (Still useful).
  Future<String> getSupplierNameByID(int supplierID) async {
     try {
      final fetchService = await supabaseDB
          .from('suppliers')
          .select('supplierName')
          .eq('supplierID', supplierID)
          .maybeSingle();

      if (fetchService != null && fetchService['supplierName'] != null) {
        return fetchService['supplierName'] as String;
      } else {
        return "Supplier not found.";
      }
    } catch (e) {
      print("Error getting supplier name for ID $supplierID: $e");
      return "Error fetching name";
    }
  }

  /// Gets supplier ID by Name (Still useful).
  Future<int> getNameByID(String supplierName) async {
    try {
      final fetchID = await supabaseDB
          .from('suppliers')
          .select('supplierID')
          .eq('supplierName', supplierName)
          .maybeSingle();

      if (fetchID != null && fetchID['supplierID'] != null) {
        return fetchID['supplierID'] as int;
      } else {
        print('Supplier "$supplierName" not found.');
        return -1;
      }
    } catch (err) {
      print('Error fetching Supplier ID for "$supplierName": $err');
      return -1;
    }
  }

  // --- Mutation Methods (Keep as they are) ---

  /// Adds a new supplier.
  Future<SuppliersData> addSupplier({
    required String supplierName,
    required String supplierEmail,
    required String contactNumber,
    required String address,
    // int? auditUserId,
  }) async {
    try {
      final newSupplierData = {
        'supplierName': supplierName,
        'supplierEmail': supplierEmail,
        'contactNumber': contactNumber,
        'address': address,
        'isActive': true,
        // Ensure 'createdDate'/'updateDate' use DB defaults or match DB type
      };
      final result = await supabaseDB
          .from('suppliers')
          .insert(newSupplierData)
          .select(
              'supplierID, supplierEmail, supplierName, contactNumber, address, isActive, createdDate, updateDate')
          .single();
      print('Added new supplier: $supplierName');
      // addAuditLogs.insertAuditLog(...)
      return SuppliersData.fromJson(result);
    } catch (err, st) {
      print('Error adding new supplier ($supplierName): $err \n $st');
      rethrow;
    }
  }

  /// Updates an existing supplier.
  Future<SuppliersData> updateSupplier({
    required int supplierID,
    required String supplierName,
    required String supplierEmail,
    required String contactNumber,
    required String address,
    // int? auditUserId,
  }) async {
    try {
      final supplierData = {
        'supplierName': supplierName,
        'supplierEmail': supplierEmail,
        'contactNumber': contactNumber,
        'address': address,
        // Ensure 'updateDate' uses DB trigger or matches DB type
      };
      final result = await supabaseDB
          .from('suppliers')
          .update(supplierData)
          .eq('supplierID', supplierID)
          .select(
              'supplierID, supplierEmail, supplierName, contactNumber, address, isActive, createdDate, updateDate')
          .single();
      print('Updated supplier: $supplierName (ID: $supplierID)');
      // addAuditLogs.insertAuditLog(...)
      return SuppliersData.fromJson(result);
    } catch (err, st) {
      print('Error updating supplier ($supplierName): $err \n $st');
      rethrow;
    }
  }

  /// Updates the visibility (active/inactive status) of a supplier.
  Future<void> updateSupplierVisbility({
    required int supplierID,
    required bool isActive,
    // int? auditUserId,
  }) async {
    try {
      await supabaseDB.from('suppliers').update({
        'isActive': isActive,
        // Ensure 'updateDate' uses DB trigger or matches DB type
      }).eq('supplierID', supplierID);
      final action = isActive ? "Restored" : "Archived";
      print('$action Supplier ID: $supplierID');
      // addAuditLogs.insertAuditLog(...)
    } catch (err, st) {
      print('Error updating supplier visibility (ID: $supplierID): $err \n $st');
      rethrow;
    }
  }
}