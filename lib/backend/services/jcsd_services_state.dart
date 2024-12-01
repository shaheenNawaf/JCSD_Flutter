//Imports for Supabase and Service data type
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/services/jcsd_services.dart';
import 'services_data.dart';


//Base Provider
final serviceStateProvider = Provider<JcsdServices>((ref){
  return JcsdServices();
});

// -- ALL OTHER SERVICES -- //

//Taga fetch rani - easier way :P
final fetchServiceList = FutureProvider<List<ServicesData>>((ref) async {
  final baseService = ref.read(serviceStateProvider);

  List<ServicesData> allServices = await baseService.displayAllServices();
  return allServices;
});

//Taga fetch ng avail rani - easier way :P
final fetchAvailableServices = FutureProvider<List<ServicesData>>((ref) async {
  final baseService = ref.read(serviceStateProvider);

  List<ServicesData> allServices = await baseService.displayAvailableServices();
  return allServices;
});

//Taga fetch ng hidden rani - easier way :P
final fetchHiddenServices = FutureProvider<List<ServicesData>>((ref) async {
  final baseService = ref.read(serviceStateProvider);

  List<ServicesData> allServices = await baseService.displayHiddenServices();
  return allServices;
});

//Holding Query Data
final serviceQuery = StateProvider<String?>((ref) => null);

//Search Function
final serviceSearchResult = FutureProvider<List<ServicesData>>((ref) async {
  final serviceProvider = ref.read(serviceStateProvider);
  final queryResult = ref.watch(serviceQuery);

    //Standard Conditionals
    if (queryResult == null || queryResult.isEmpty) return [];

    //Call to my supplier service to refer to my search method
    return await serviceProvider.searchSuppliers(serviceName: queryResult, serviceID:  int.tryParse(queryResult));

});

//Loading Visual
final loadingStateProvider = StateProvider<bool>((ref) => false);

//Adding a Service
final addServiceProvider = FutureProvider.family<void, ServicesData>((ref, newService) async {
  final serviceProvider = ref.read(serviceStateProvider);
  ref.read(loadingStateProvider.notifier).state = true; //Loading ba

  try{
    await serviceProvider.addNewService(newService);
  }catch (err){
    ref.read(loadingStateProvider.notifier).state = false; 
    print("Error adding new service to the database. $err");
  }
});

//Updating a Service

//Visbility/Soft-delete

  