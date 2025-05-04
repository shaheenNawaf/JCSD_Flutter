import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_state.dart';

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final EmployeeService _employeeService;
  final AccountService _accountService;
  final int _itemsPerPage = 10;

  List<Map<String, dynamic>> _allEmployeeAccounts = [];

  EmployeeNotifier(this._employeeService, this._accountService)
      : super(EmployeeState.initial()) {
    getEmployeeAccounts();
  }

  Future<void> getEmployeeAccounts() async {
    final employees = await _employeeService.fetchEmployees();
    final accounts = await _accountService.fetchAccounts();

    final combined = <Map<String, dynamic>>[];

    for (final emp in employees) {
      try {
        final acc = accounts.firstWhere((a) => a.userID == emp.userID);
        combined.add({
          'employee': emp,
          'account': acc,
        });
      } catch (_) {
        continue;
      }
    }

    _allEmployeeAccounts = combined;
    _applySortAndPagination();
  }

  void sort(String column) {
    if (state.sortBy == column) {
      state = state.copyWith(ascending: !state.ascending);
    } else {
      state = state.copyWith(sortBy: column, ascending: true);
    }
    _applySortAndPagination();
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
    _applySortAndPagination();
  }

  void _applySortAndPagination() {
    List<Map<String, dynamic>> sorted = List.from(_allEmployeeAccounts);

    switch (state.sortBy) {
      case 'firstName':
        sorted.sort((a, b) {
          final aName = (a['account'] as AccountsData).firstName.toLowerCase();
          final bName = (b['account'] as AccountsData).firstName.toLowerCase();
          return state.ascending
              ? aName.compareTo(bName)
              : bName.compareTo(aName);
        });
        break;
      case 'email':
        sorted.sort((a, b) {
          final aEmail = (a['account'] as AccountsData).email.toLowerCase();
          final bEmail = (b['account'] as AccountsData).email.toLowerCase();
          return state.ascending
              ? aEmail.compareTo(bEmail)
              : bEmail.compareTo(aEmail);
        });
        break;
      case 'companyRole':
        sorted.sort((a, b) {
          final aRole =
              (a['employee'] as EmployeeData).companyRole.toLowerCase();
          final bRole =
              (b['employee'] as EmployeeData).companyRole.toLowerCase();
          return state.ascending
              ? aRole.compareTo(bRole)
              : bRole.compareTo(aRole);
        });
        break;
    }

    final total = sorted.length;
    final start = (state.currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, total);
    final paginated = sorted.sublist(start, end);

    state = state.copyWith(
      employeeAccounts: paginated,
      totalPages: (total / _itemsPerPage).ceil(),
    );
  }
}
