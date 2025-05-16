import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';

const int defaultItemsPerPage = 10;

class PayrollService {
  Future<List<PayrollData>> fetchPayrolls({
    String sortBy = 'createDate',
    bool ascending = true,
    int page = 1,
    int itemsPerPage = defaultItemsPerPage,
  }) async {
    try {
      final from = (page - 1) * itemsPerPage;
      final to = from + itemsPerPage - 1;

      final results = await supabaseDB
          .from('payroll')
          .select()
          .order(sortBy, ascending: ascending)
          .range(from, to);

      return results.map<PayrollData>((e) {
        return PayrollData(
          id: e['id'] as int,
          createdAt: DateTime.parse(e['created_at']),
          employeeID: e['employeeID'] as int,
          monthlySalary: (e['monthlySalary'] as num).toDouble(),
          calculatedMonthlySalary: (e['calculatedMonthlySalary'] as num).toDouble(),
          bonus: (e['bonus'] as num).toDouble(),
          deductions: (e['deductions'] as num).toDouble(),
          pagibig: (e['pagibig'] as num).toDouble(),
          philhealth: (e['philhealth'] as num).toDouble(),
          sss: (e['sss'] as num).toDouble(),
          withholdingTax: (e['withholdingTax'] as num).toDouble(),
          taxableIncome: (e['taxableIncome'] as num).toDouble(),
        );
      }).toList();
    } catch (err) {
      print('Error fetching paginated employees: $err');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPayrollsWithEmployeeDetails({
  String sortBy = 'created_at',
  bool ascending = true,
  int page = 1,
  int itemsPerPage = defaultItemsPerPage,
}) async {
  try {
    // Fetch payroll data with employee details using Supabase join
    final payrollResponse = await supabaseDB
        .from('payroll')
        .select('''
          *,
          payroll:employeeID (
            *,
            accounts!employee_userID_fkey1(
              *
              )
          )
        ''')
        .order(sortBy, ascending: ascending)
        .range((page - 1) * itemsPerPage, page * itemsPerPage - 1);
    return payrollResponse.map<Map<String, dynamic>>((payroll) {
      final employeeData = payroll['payroll'] as Map<String, dynamic>?;
      final accountData = payroll['payroll']?['accounts'] as Map<String, dynamic>?;

      if (employeeData != null && employeeData['employeeID'] is int) {
          employeeData['employeeID'] = employeeData['employeeID'].toString();
        }

      print(payroll['payroll']);
      return {
        'payroll': PayrollData.fromJson(payroll),
        'employee': employeeData != null 
            ? EmployeeData.fromJson(employeeData) 
            : null,
        'account': accountData != null 
            ? AccountsData.fromJson(accountData) 
            : null,
      };
    }).toList();
  } catch (e) {
    print('Error fetching payrolls with employee details: $e');
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
      final employees = await fetchPayrolls(
        sortBy: sortBy,
        ascending: ascending,
        page: page,
        itemsPerPage: itemsPerPage,
      );

      final userIds = employees.map((e) => e.employeeID).toList();

      final accountResponse = await supabaseDB.from('accounts').select();

      final accounts = accountResponse
          .where((acc) => userIds.contains(acc['userID'].toString()))
          .toList();

      List<Map<String, dynamic>> result = [];

      for (final emp in employees) {
        final acc = accounts.firstWhere(
          (a) => a['userID'].toString() == emp.employeeID,
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
}

  
