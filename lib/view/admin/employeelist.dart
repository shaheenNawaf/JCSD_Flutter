// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_state.dart';
import 'package:jcsd_flutter/modals/add_employee.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_notifier.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart';

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
      ref.invalidate(employeeNotifierProvider);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employeeNotifierProvider);
    final notifier = ref.read(employeeNotifierProvider.notifier);

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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/employeeList/leaveRequestList');
                            },
                            icon: const Icon(Icons.calendar_month,
                                color: Colors.white),
                            label: const Text(
                              'Leave Requests',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEEF),
                              minimumSize: const Size(120, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/employeeList/payrollList');
                            },
                            icon: const Icon(Icons.request_quote,
                                color: Colors.white),
                            label: const Text(
                              'Payroll List',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEEF),
                              minimumSize: const Size(120, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: TextField(
                              enabled: true,
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildDataTable(
                      context,
                      state.employeeAccounts,
                      notifier,
                      state,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPagination(state, notifier),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    List<Map<String, dynamic>> data,
    EmployeeNotifier notifier,
    EmployeeState state,
  ) {
    final sortedData = List<Map<String, dynamic>>.from(data);
    if (state.sortBy == 'firstName') {
      sortedData.sort((a, b) {
        final aAcc = a['account'] as AccountsData?;
        final bAcc = b['account'] as AccountsData?;
        return state.ascending
            ? (aAcc?.firstName ?? '')
                .toLowerCase()
                .compareTo((bAcc?.firstName ?? '').toLowerCase())
            : (bAcc?.firstName ?? '')
                .toLowerCase()
                .compareTo((aAcc?.firstName ?? '').toLowerCase());
      });
    } else if (state.sortBy == 'email') {
      sortedData.sort((a, b) {
        final aAcc = a['account'] as AccountsData?;
        final bAcc = b['account'] as AccountsData?;
        return state.ascending
            ? (aAcc?.email ?? '')
                .toLowerCase()
                .compareTo((bAcc?.email ?? '').toLowerCase())
            : (bAcc?.email ?? '')
                .toLowerCase()
                .compareTo((aAcc?.email ?? '').toLowerCase());
      });
    }

    return Container(
      width: double.infinity,
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
            columnSpacing: 24,
            columns: [
              DataColumn(
                  label: _buildSortableHeader(
                      'Name', 'firstName', notifier, state)),
              DataColumn(
                  label:
                      _buildSortableHeader('Email', 'email', notifier, state)),
              DataColumn(
                  label: _buildSortableHeader(
                      'Position', 'companyRole', notifier, state)),
              DataColumn(label: _buildHeaderText('Contact Info')),
              DataColumn(label: _buildHeaderText('Action', center: true)),
            ],
            rows: sortedData.map((row) {
              final emp = row['employee'] as EmployeeData;
              final acc = row['account'] as AccountsData;
              final fullName =
                  '${acc.firstName} ${acc.middleName} ${acc.lastname}'.trim();
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
                            context.push('/employeeList/profile', extra: {
                              'account': acc,
                              'employee': emp,
                            });
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

  Widget _buildSortableHeader(String title, String column,
      EmployeeNotifier notifier, EmployeeState state) {
    return InkWell(
      onTap: () => notifier.sort(column),
      child: Row(
        children: [
          _buildHeaderText(title),
          if (state.sortBy == column)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPagination(EmployeeState state, EmployeeNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: state.currentPage > 1 ? () => notifier.goToPage(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed: state.currentPage > 1
              ? () => notifier.goToPage(state.currentPage - 1)
              : null,
        ),
        Text('Page ${state.currentPage} of ${state.totalPages}'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: state.currentPage < state.totalPages
              ? () => notifier.goToPage(state.currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: state.currentPage < state.totalPages
              ? () => notifier.goToPage(state.totalPages)
              : null,
        ),
      ],
    );
  }

  static Widget _buildHeaderText(String text, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
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
