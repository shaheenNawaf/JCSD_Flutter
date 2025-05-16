import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_notifier.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_service.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_state.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService();
});

final payrollProvider = Provider<PayrollService>((ref) {
  return PayrollService();
});

final payrollNotifierProvider =
    StateNotifierProvider<PayrollNotifier, PayrollState>(
  (ref) => PayrollNotifier(
    ref.read(employeeServiceProvider),
    ref.read(accountServiceProvider),
    ref.read(payrollProvider),
  ),
);
