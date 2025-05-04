import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_service.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_notifier.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_state.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService();
});

final employeeNotifierProvider =
    StateNotifierProvider<EmployeeNotifier, EmployeeState>(
  (ref) => EmployeeNotifier(
    ref.read(employeeServiceProvider),
    ref.read(accountServiceProvider),
  ),
);
