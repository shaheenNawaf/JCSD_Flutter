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
  final int _itemsPerPage = 10;

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
      final payrollWithDetails = await _payrollService.fetchPayrollsWithEmployeeDetails();
      state = state.copyWith(
        payrolls: payrollWithDetails,
        loading: false,
        totalPages: (payrollWithDetails.length / _itemsPerPage).ceil(),
      );
      _applySortAndPagination();
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
    );
    _applySortAndPagination();
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
    _applySortAndPagination();
  }

  void _applySortAndPagination() {
    List<Map<String, dynamic>> sorted = List.from(state.payrolls);

    // Apply sorting
    sorted.sort((a, b) {
      final aPayroll = a['payroll'] as PayrollData;
      final bPayroll = b['payroll'] as PayrollData;
      final aAccount = a['account'] as AccountsData?;
      final bAccount = b['account'] as AccountsData?;

      int compareResult;
      switch (state.sortBy) {
        case 'created_at':
          compareResult = aPayroll.createdAt.compareTo(bPayroll.createdAt);
          break;
        case 'monthlySalary':
          compareResult = aPayroll.monthlySalary.compareTo(bPayroll.monthlySalary);
          break;
        case 'employeeName':
          compareResult = (aAccount?.firstName ?? '')
              .compareTo(bAccount?.firstName ?? '');
          break;
        default:
          compareResult = aPayroll.createdAt.compareTo(bPayroll.createdAt);
      }

      return state.ascending ? compareResult : -compareResult;
    });

    // Apply pagination
    final total = sorted.length;
    final start = (state.currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, total);
    final paginated = sorted.sublist(start, end);

    state = state.copyWith(
      payrolls: paginated,
      totalPages: (total / _itemsPerPage).ceil(),
    );
  }
}