//Imports for Supabase and Service data type
import 'package:jcsd_flutter/api/global_variables.dart';

import 'services_data.dart';

class JcsdServices {

//Fetching the Service List
Future<List<ServicesData>> displayAllServices() async {
  try {
    final services = await supabaseDB.from('services').select();
    if(services.isEmpty == true){
      print('Empty Service table.');
      return [];
    }
    return services.map<ServicesData>((item) => ServicesData.fromJson(item)).toList();
  }catch (err){
    print('Error fetching services from the table. Error Message: $err');
    return [];
  }
}

//Fetching the Available Service List
Future<List<ServicesData>> displayAvailableServices() async {
  try {
    final services = await supabaseDB.from('services').select().eq('isActive', true);
    if(services.isEmpty == true){
      print('Empty Service table.');
      return [];
    }
    return services.map<ServicesData>((item) => ServicesData.fromJson(item)).toList();
  }catch (err){
    print('Error fetching services from the table. Error Message: $err');
    return [];
  }
}

Future<List<ServicesData>> displayHiddenServices() async {
  try {
    final services = await supabaseDB.from('services').select().eq('isActive', false);
    if(services.isEmpty == true){
      print('Empty Service table.');
      return [];
    }
    return services.map<ServicesData>((item) => ServicesData.fromJson(item)).toList();
  }catch (err){
    print('Error fetching services from the table. Error Message: $err');
    return [];
  }
}

//Adding a new services
Future<void> addNewService(ServicesData newService) async {
  try {
    await supabaseDB.from('services').insert(newService.toJson());
    print('Added new Serivce. ${newService.serviceName}');
  }catch(err){
    print('Error adding new service. $err');
  }
}

//Update a service by Service ID
Future<void> updateServiceDetails(int serviceID, String serviceName, double minPrice, double maxPrice, bool isActive) async {
  try{
      await supabaseDB.from('services').update({
        'serviceName': serviceName,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'isActive': isActive,
      }).eq('serviceID', serviceID);

      print('Added new supplier. $serviceID');
  }catch(err){
    print('Error udpating service details: $err');
  }
}

//Updating a Service's availability
Future<void> updateServiceVisibility(int serviceID, bool isActive) async {
    try {
      await supabaseDB.from('services').update({'isActive': isActive}).eq('serviceID', serviceID);
    } catch (err) {
      print('Error updating service visibility. $err');
    }
  }

//Searching a Service by ID, Name
Future<List<ServicesData>> searchSuppliers({int? serviceID, String? serviceName}) async {
    try {
      final query =  supabaseDB.from('services').select();
      if(serviceID != null){
        query.eq('serviceID', serviceID);
      }
      if(serviceName != null){
        query.eq('serviceName', serviceName);
      }

      final results = await query;
      if(results.isEmpty){
        print("Your search didnt not match any results");
        return [];
      }

      return results.map<ServicesData>((item) => ServicesData.fromJson(item)).toList(); //If may results - stored here to be accessed
    }catch (err){
      print("Error searching services. $err");
      return [];
    }
  }

//Get Service by given ID
  Future<ServicesData?> getServiceByID(int serviceID) async {
    try {
      final fetchService = await supabaseDB.from('services').select().eq('serviceID', serviceID).single(); 

      if(fetchService.isEmpty == true){
        print('$serviceID not found');
        return null;
      }else{
        return ServicesData.fromJson(fetchService);
      }
    }catch (err){
      print('Error accessing table. Error message: $err');
      return null;
    }
  }

}