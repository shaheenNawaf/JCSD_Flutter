import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_service.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_state.dart';

class PayrollNotifier extends StateNotifier<PayrollState> {
  final EmployeeService _employeeService;
  final AccountService _accountService;
  final PayrollService _payrollService;
  final int _itemsPerPage = 13;

  PayrollNotifier(
    this._employeeService,
    this._accountService,
    this._payrollService,
  ) : super(PayrollState.initial()) {
    fetchPayrollData();
  }

  Future<void> fetchPayrollData() async {
    state = state.copyWith(loading: true);
    try {
      final payrollWithDetails =
          await _payrollService.fetchPayrollsWithEmployeeDetails(
        sortBy: state.sortBy,
        ascending: state.ascending,
        page: state.currentPage,
        itemsPerPage: _itemsPerPage,
      );

      // Get total count for proper pagination
      final totalCount = await _payrollService.getTotalPayrollCount();

      state = state.copyWith(
        payrolls: payrollWithDetails,
        loading: false,
        totalPages: (totalCount / _itemsPerPage).ceil(),
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  void sort(String column) {
    final ascending = state.sortBy == column ? !state.ascending : true;
    state = state.copyWith(
      sortBy: column,
      ascending: ascending,
      currentPage: 1,
    );
    fetchPayrollData();
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
    fetchPayrollData();
  }

  Future<List<Map<String, dynamic>>> fetchAllPayrollsForMonthYear({
    required int month,
    required int year,
  }) async {
    final allPayrolls =
        await _payrollService.fetchPayrollsWithEmployeeDetailsForMonthYear(
      month: month,
      year: year,
    );

    return allPayrolls;
  }
}
