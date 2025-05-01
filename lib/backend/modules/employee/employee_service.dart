import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeService {
  Future<void> registerNewEmployee({
    required String email,
    required String password,
    required String role,
    required bool isAdmin,
  }) async {
    try {
      final authResponse = await supabaseDB.auth.admin.createUser(
        AdminUserAttributes(email: email, password: password),
      );

      final userId = authResponse.user?.id;
      if (userId == null) throw Exception("User creation failed.");

      await supabaseDB.from('accounts').insert({
        'userID': userId,
        'email': email,
      });

      await supabaseDB.from('employee').insert({
        'userID': userId,
        'companyRole': role,
        'isAdmin': isAdmin,
        'isActive': true,
      });
    } catch (err) {
      print('Error registering employee: $err');
    }
  }

  Future<void> registerNewEmployeeWithProfile({
    required String email,
    required String password,
    required String role,
    required bool isAdmin,
    required String firstName,
    required String lastName,
    required String middleInitial,
    required String phone,
    required String birthday,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final authResponse = await supabaseDB.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) throw Exception("Sign-up failed.");

      final userId = user.id;

      await supabaseDB.from('accounts').insert({
        'userID': userId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleInitial,
        'contactNumber': phone,
        'birthDate': birthday,
        'address': address,
        'city': city,
        'country': country,
      });

      await supabaseDB.from('employee').insert({
        'userID': userId,
        'companyRole': role,
        'isAdmin': isAdmin,
        'isActive': true,
      });
    } catch (err) {
      print('Error registering employee with profile (signUp): $err');
    }
  }

  Future<List<EmployeeData>> fetchAllEmployees() async {
    try {
      final results = await supabaseDB.from('employee').select(
            'employeeID, userID, isAdmin, companyRole, isActive, createDate',
          );
      return results.map<EmployeeData>((e) {
        String parsedUserId = e['userID'] != null ? e['userID'].toString() : '';
        return EmployeeData(
          employeeID: e['employeeID'].toString(),
          userID: parsedUserId,
          isAdmin: e['isAdmin'] as bool,
          companyRole: e['companyRole'] as String,
          isActive: e['isActive'] as bool,
          createDate: DateTime.parse(e['createDate']),
        );
      }).toList();
    } catch (err) {
      print('Error fetching employees: $err');
      return [];
    }
  }
}
