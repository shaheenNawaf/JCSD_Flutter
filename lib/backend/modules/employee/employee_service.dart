import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const int defaultItemsPerPage = 10;

class EmployeeService {
  Future<List<EmployeeData>> fetchEmployees({
    String sortBy = 'createDate',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try {
      final from = (page - 1) * itemsPerPage;
      final to = from + itemsPerPage - 1;

      final results = await supabaseDB
          .from('employee')
          .select(
              'employeeID, userID, isAdmin, companyRole, isActive, createDate')
          .order(sortBy, ascending: ascending)
          .range(from, to);

      return results.map<EmployeeData>((e) {
        return EmployeeData(
          employeeID: e['employeeID'].toString(),
          userID: e['userID'].toString(),
          isAdmin: e['isAdmin'] as bool,
          companyRole: e['companyRole'] as String,
          isActive: e['isActive'] as bool,
          createDate: DateTime.parse(e['createDate']),
        );
      }).toList();
    } catch (err) {
      print('Error fetching paginated employees: $err');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchEmployeesWithAccounts({
    String sortBy = 'createDate',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try {
      final employees = await fetchEmployees(
        sortBy: sortBy,
        ascending: ascending,
        page: page,
        itemsPerPage: itemsPerPage,
      );

      final userIds = employees.map((e) => e.userID).toList();

      final accountResponse = await supabaseDB.from('accounts').select();

      final accounts = accountResponse
          .where((acc) => userIds.contains(acc['userID'].toString()))
          .toList();

      List<Map<String, dynamic>> result = [];

      for (final emp in employees) {
        final acc = accounts.firstWhere(
          (a) => a['userID'].toString() == emp.userID,
          orElse: () => {},
        );

        if (acc.isNotEmpty) {
          result.add({
            'employee': emp,
            'account': AccountsData.fromJson(acc),
            'fullName': '${acc['firstName']} ${acc['lastName']}',
          });
        }
      }

      return result;
    } catch (e) {
      print('Error combining employees and accounts: $e');
      return [];
    }
  }

  Future<int> getTotalEmployeeCount() async {
    try {
      final result = await supabaseDB.from('employee').select('employeeID');
      return result.length;
    } catch (err) {
      print('Error fetching employee count: $err');
      return 0;
    }
  }

  Future<void> registerNewEmployeeWithProfile({
    required AuthResponse authResponse,
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
    required String region,
    required String province,
    required String city,
    required String zipCode,
  }) async {
    final user = authResponse.user;

    if (user == null) {
      throw Exception("No authenticated user to link employee record.");
    }

    final userID = user.id;

    await supabaseDB.from('accounts').insert({
      'userID': userID,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleInitial,
      'contactNumber': phone,
      'birthDate': birthday,
      'address': address,
      'region': region,
      'province': region,
      'city': city,
      'zipCode': zipCode,
    });

    await supabaseDB.from('employee').insert({
      'userID': userID,
      'companyRole': role,
      'isAdmin': isAdmin,
    });
  }
}
