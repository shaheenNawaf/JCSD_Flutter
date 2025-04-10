import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_state.dart';
// import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_state.dart';
import 'package:jcsd_flutter/modals/add_employee.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';

final employeeAccountProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final employees = await ref.watch(fetchAllEmployeesProvider.future);
  final accountsService = ref.read(accountServiceProvider);
  final accounts = await accountsService.fetchAccounts();

  List<Map<String, dynamic>> combinedData = [];

  for (final emp in employees) {
    AccountsData? matchingAccount;

    try {
      matchingAccount = accounts.firstWhere(
        (acc) => acc.userID == emp.userID.toString(),
      );
    } catch (e) {
      continue;
    }

    combinedData.add({
      'employee': emp,
      'account': matchingAccount,
      'fullName':
          '${matchingAccount.firstName} ${matchingAccount.lastname}'.trim(),
    });
  }

  return combinedData;
});

class EmployeeListPage extends ConsumerWidget {
  const EmployeeListPage({super.key});

  void _AddEmployeeModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddEmployeeModal();
      },
    ).then((_) {
      ref.invalidate(
          fetchAllEmployeesProvider); // Refresh the list after adding
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeAccountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/employeeList'),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Employee List'),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/leaveRequestList');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          minimumSize: const Size(120, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Leave Requests',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFABABAB),
                                  fontFamily: 'NunitoSans',
                                ),
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _AddEmployeeModal(context, ref);
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEEF),
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: employeeAsync.when(
                      data: (list) => _buildDataTable(context, list, ref),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
      BuildContext context, List<Map<String, dynamic>> data, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView(
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
            columns: [
              DataColumn(label: _buildHeaderText('Name')),
              DataColumn(label: _buildHeaderText('Email')),
              DataColumn(label: _buildHeaderText('Position')),
              DataColumn(label: _buildHeaderText('Contact Info')),
              DataColumn(label: _buildHeaderText('Action', center: true)),
            ],
            rows: data.map((row) {
              final emp = row['employee'] as EmployeeData;
              final acc = row['account'] as AccountsData;
              final fullName = row['fullName'] as String;
              return DataRow(
                cells: [
                  DataCell(Text(fullName, style: _tableBodyStyle)),
                  DataCell(Text(acc.email, style: _tableBodyStyle)),
                  DataCell(Text(emp.companyRole, style: _tableBodyStyle)),
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(acc.email, style: _tableBodyStyle),
                      Text(acc.contactNumber, style: _tableBodyStyle),
                    ],
                  )),
                  DataCell(
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/profile',
                                arguments: acc);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AEEF),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: 'NunitoSans',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildHeaderText(String text, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: center ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}

const TextStyle _tableBodyStyle = TextStyle(
  fontFamily: 'NunitoSans',
);
