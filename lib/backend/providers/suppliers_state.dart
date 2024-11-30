import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/models/suppliers_data.dart';
import 'package:jcsd_flutter/backend/services/suppliers_service.dart';

//Base Provider for the Suppliers Mini-System -- USED FOR THE ENTIRE STATE MANAGEMENT -- DON'T TOUCH
final supplierServiceProv = Provider<SuppliersService>((ref){
    return SuppliersService();
});

// -- ALL OTHER METHODS FOR THE DIFFERENT FUNCTIONALITIES -- //

//Grab Supplier List
final fetchSupplierList = FutureProvider<List<SuppliersData>>((ref) async {
    final baseSupplier = ref.read(supplierServiceProv);

    List<SuppliersData> allSuppliers = await baseSupplier.displayAllSuppliers();
    return allSuppliers;
});

//Available Suppliers
final fetchAvailableSuppliers = FutureProvider<List<SuppliersData>>((ref) async {
    final baseSupplier = ref.read(supplierServiceProv);

    List<SuppliersData> allSuppliers = await baseSupplier.displayAvailableSuppliers();
    return allSuppliers;
});

//Arvhived Suppliers
final fetchHiddenSuppliers = FutureProvider<List<SuppliersData>>((ref) async {
    final baseSupplier = ref.read(supplierServiceProv);

    List<SuppliersData> allSuppliers = await baseSupplier.displayHiddenSuppliers();
    return allSuppliers;
});

//Hold Query Search - can be null/empty
final supplierQuery = StateProvider<String?>((ref) => null);


//Search Function
final supplierSearchResult = FutureProvider<List<SuppliersData>>((ref) async {
    final supplierService = ref.read(supplierServiceProv);
    final queryResult = ref.watch(supplierQuery);

    //Standard Conditionals
    if (queryResult == null || queryResult.isEmpty) return [];

    //Call to my supplier service to refer to my search method
    return await supplierService.searchSuppliers(supplierName: queryResult, supplierEmail: queryResult, supplierID: int.tryParse(queryResult));
});

//Loading Visual
final supplierLoadingStateProvider = StateProvider<bool>((ref) => false);

//Visibility/Soft-delete
final updateServiceVisibilityProvider = FutureProvider.family<void, SuppliersData>((ref, updateSupplier) async {
    final supplierService = ref.read(supplierServiceProv);
    ref.read(supplierLoadingStateProvider.notifier).state = true;

    try {
        await supplierService.updateSupplierVisbility(updateSupplier.supplierID, updateSupplier.isActive);
    }catch(err){
    ref.read(supplierLoadingStateProvider.notifier).state = false;
    print('Failed to update Service: ${updateSupplier.supplierName} \n View message: $err');
    }
});

