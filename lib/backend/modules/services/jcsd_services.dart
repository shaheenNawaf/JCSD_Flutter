//Imports for Supabase and Service data type
import 'package:jcsd_flutter/api/global_variables.dart';
import 'services_data.dart';
import 'package:jcsd_flutter/backend/date_converter.dart';

class JcsdServices {
//Fetching the Service List
  Future<List<ServicesData>> allServices() async {
    try {
      final services = await supabaseDB
          .from('jcsd_services')
          .select('*')
          .order('serviceID', ascending: true);
      if (services.isEmpty == true) {
        print('Empty Service table.');
        return [];
      }
      return services
          .map<ServicesData>((item) => ServicesData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching services from the table. Error Message: $err');
      return [];
    }
  }

//Fetching the Available Service List
  Future<List<ServicesData>> activeServices() async {
    try {
      final services = await supabaseDB
          .from('jcsd_services')
          .select('*')
          .eq('isActive', true)
          .order('serviceID', ascending: true);
      if (services.isEmpty == true) {
        print('Empty Service table.');
        return [];
      }
      return services
          .map<ServicesData>((item) => ServicesData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching services from the table. Error Message: $err');
      return [];
    }
  }

//Fetching the Available Service List
  Future<List<ServicesData>> archivedServices() async {
    try {
      final services = await supabaseDB
          .from('jcsd_services')
          .select('*')
          .eq('isActive', false)
          .order('serviceID', ascending: true);
      if (services.isEmpty == true) {
        print('Empty Service table.');
        return [];
      }
      return services
          .map<ServicesData>((item) => ServicesData.fromJson(item))
          .toList();
    } catch (err) {
      print('Error fetching services from the table. Error Message: $err');
      return [];
    }
  }

//Updating a Service's availability
  Future<void> updateVisibility(int serviceID, bool isActive) async {
    try {
      await supabaseDB
          .from('jcsd_services')
          .update({'isActive': isActive}).eq('serviceID', serviceID);
    } catch (err) {
      print('Error updating $serviceID visibility. $err');
    }
  }

  //Fixed Add
  Future<void> addService(
      String serviceName, double minPrice, double maxPrice) async {
    try {
      await supabaseDB.from('jcsd_services').insert({
        'serviceName': serviceName,
        'isActive': true,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'createDate': returnCurrentDate(),
        'updateDate': returnCurrentDate()
      });

      print('SUCCESS! -- NEW SERVICE ADDED: $serviceName');
    } catch (err) {
      print('ERROR ADDING SERVICE ($serviceName) -- Info: $err');
    }
  }

  //Fixed Update
  Future<void> updateService(int serviceID, String serviceName, double minPrice,
      double maxPrice) async {
    try {
      await supabaseDB.from('jcsd_services').update({
        'serviceName': serviceName,
        'isActive': true,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'updateDate': returnCurrentDate()
      }).eq('serviceID', serviceID);
      print('SUCCESS! -- Updated $serviceName and saved.');
    } catch (err) {
      print('UPDATE ERROR. ($serviceName) -- $err');
    }
  }

//Searching a Service by ID, Name
  Future<List<ServicesData>> searchSuppliers(
      {int? serviceID, String? serviceName}) async {
    try {
      final query = supabaseDB.from('services').select();
      if (serviceID != null) {
        query.eq('serviceID', serviceID);
      }
      if (serviceName != null) {
        query.eq('serviceName', serviceName);
      }

      final results = await query;
      if (results.isEmpty) {
        print("Your search didnt not match any results");
        return [];
      }

      return results
          .map<ServicesData>((item) => ServicesData.fromJson(item))
          .toList(); //If may results - stored here to be accessed
    } catch (err) {
      print("Error searching services. $err");
      return [];
    }
  }

//Get Service by given ID
  Future<ServicesData?> getServiceByID(int serviceID) async {
    try {
      final fetchService = await supabaseDB
          .from('services')
          .select()
          .eq('serviceID', serviceID)
          .single();

      if (fetchService.isEmpty == true) {
        print('$serviceID not found');
        return null;
      } else {
        return ServicesData.fromJson(fetchService);
      }
    } catch (err) {
      print('Error accessing table. Error message: $err');
      return null;
    }
  }
}
