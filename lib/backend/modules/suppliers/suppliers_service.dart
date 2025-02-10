//Imports for Supabase and Suppliers data model
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/date_converter.dart';
import 'suppliers_data.dart';

class SuppliersService {  

  //Fetching All the Supplier
  Future<List<SuppliersData>> allSuppliers() async {
    try {
      final suppliers = await supabaseDB.from('suppliers').select().order('supplierID', ascending: true);
      if(suppliers.isEmpty){
        print("No suppliers are on the list");
        return [];
      }
      //If there are entries inside the table, auto-convert as a list
      return suppliers.map<SuppliersData>((item) => SuppliersData.fromJson(item)).toList();
    }catch (err){
      print('Error fetching items from Suppliers table. Error Message: $err');
      return [];
    }
  }

  //Fetching All the Supplier
  Future<List<SuppliersData>> availableSuppliers() async {
    try {
      final suppliers = await supabaseDB.from('suppliers').select().eq('isActive', true).order('supplierID', ascending: true);
      if(suppliers.isEmpty){
        print("No suppliers are on the list");
        return [];
      }
      //If there are entries inside the table, auto-convert as a list
      return suppliers.map<SuppliersData>((item) => SuppliersData.fromJson(item)).toList();
    }catch (err){
      print('Error fetching items from Suppliers table. Error Message: $err');
      return [];
    }
  }

  //Fetching Hidden Supplier
  Future<List<SuppliersData>> archivedSuplliers() async {
    try {
      final suppliers = await supabaseDB.from('suppliers').select().eq('isActive', false).order('supplierID', ascending: true);
      if(suppliers.isEmpty){
        print("No suppliers are on the list");
        return [];
      }
      //If there are entries inside the table, auto-convert as a list
      return suppliers.map<SuppliersData>((item) => SuppliersData.fromJson(item)).toList();
    }catch (err){
      print('Error fetching items from Suppliers table. Error Message: $err');
      return [];
    }
  }

  //Searching a supplier
  Future<List<SuppliersData>> searchSuppliers({int? supplierID, String? supplierName, String? supplierEmail}) async {
    try {
      final query =  supabaseDB.from('suppliers').select();
      if(supplierID != null){
        query.eq('supplierID', supplierID);
      }
      if(supplierName != null){
        query.eq('supplierName', supplierName);
      }
      if(supplierEmail != null){
        query.eq('supplierEmail', supplierEmail);
      }

      final results = await query;
      if(results.isEmpty){
        print("Your search didnt not match any results");
        return [];
      }

      return results.map<SuppliersData>((item) => SuppliersData.fromJson(item)).toList(); //If may results - stored here to be accessed
    }catch (err){
      print("Error searching items. Error Message: $err");
      return [];
    }
  }

  // Load supplier's details by ID; Para sa edit ng Supplier Details
  Future<SuppliersData?> getSupplierByID(int supplierID) async {
    try {
      final fetchService = await supabaseDB.from('suppliers').select().eq('supplierID', supplierID).single(); 

      if(fetchService.isEmpty == true){
        print('$supplierID not found');
        return null;
      }else{
        return SuppliersData.fromJson(fetchService);
      }

    }catch (err){
      print('Error accessing table. Error message: $err');
      return null;
    }
  }

  Future<List<String>> getListOfSupplierNames() async {
    final fetchSuppliers = await supabaseDB.from('suppliers').select('supplierName').eq('isActive', true).select();

    try {
      if(fetchSuppliers.isEmpty == true){
        print('There are no active services in the table.');
      }

      return List<String>.from(fetchSuppliers.map((item) => item['supplierName'] as String ));
    }catch(err){
      print('Error fetching supplier names. $err');
      return [];
    }
  }

  Future<String> getSupplierNameByID(int supplierID) async {
    final fetchService = await supabaseDB.from('suppliers').select('supplierName').eq('supplierID', supplierID).single(); 

    if(fetchService.isNotEmpty == true){
      return fetchService['supplierName'] as String;
    }else {
      return "Supplier not found.";
    }
  }
  
  Future<int> getNameByID(String supplierName) async {
    try{
      final fetchID = await supabaseDB.from('suppliers').select('supplierID').eq('supplierName', supplierName).single();
      return fetchID['supplierID'] as int;
    }catch(err){
      print('Error fetching Supplier ID. $err');
      return -1;
    }
  }

  //Other methods for adding, editing
  Future<void> addSupplier(String supplierName, String supplierEmail, String contactNumber, String address) async {
    try{
      await supabaseDB.from('suppliers').insert({
        'supplierName': supplierName,
        'supplierEmail': supplierEmail,
        'contactNumber': contactNumber,
        'address': address,
        'isActive': true,
        'createdDate': returnCurrentDate(),
        'updateDate': returnCurrentDate(),
      });

      print('Added new supplier. $supplierName');
    }catch(err){
      print('Error adding new supplier. $err');
    }
  }

  //Update Supplier
  Future<void> updateSupplier(int supplierID, String supplierName, String supplierEmail, String contactNumber, String address) async {
    try{
      await supabaseDB.from('suppliers').update({
        'supplierName': supplierName,
        'supplierEmail': supplierEmail,
        'contactNumber': contactNumber,
        'address': address,
        'updateDate': returnCurrentDate(),
      }).eq('supplierID', supplierID);

      print('Added new supplier. $supplierName');
    }catch(err){
      print('Error adding new supplier. $err');
    }
  }

  //Updating Supplier's Visibility - soft-delete
  Future<void> updateSupplierVisbility(int supplierID, bool isActive) async {
    try {
      await supabaseDB.from('suppliers').update({'isActive': isActive}).eq('supplierID', supplierID);
    } catch (err) {
      print('Error updating service visibility. Error Message: $err');
    }
  }


}