import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService();
});

final fetchAllEmployeesProvider =
    FutureProvider.autoDispose<List<EmployeeData>>((ref) async {
  final service = ref.read(employeeServiceProvider);
  return await service.fetchAllEmployees();
});
