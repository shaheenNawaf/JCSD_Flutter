// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_notifier.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_providers.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_state.dart';
import 'package:jcsd_flutter/modals/confirm_generate_payroll.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class GeneratePayrollPage extends ConsumerStatefulWidget {
  const GeneratePayrollPage({super.key});

  @override
  ConsumerState<GeneratePayrollPage> createState() =>
      _GeneratePayrollPageState();
}

class _GeneratePayrollPageState extends ConsumerState<GeneratePayrollPage> {

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeNotifierProvider);
    final notifier = ref.read(employeeNotifierProvider.notifier);
     return Scaffold(
      body: Row(
        children: [
          const Sidebar(activePage: '/employeeList'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Generate Payroll',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => context.pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                        // Should redirect user to another page to display each employee's payroll summary with an option to print OR for them
                        onPressed: () {
                          print('sad');
                          // showDialog(
                          //   context: context,
                          //   builder: (context) =>
                          //       ConfirmGeneratePayroll(onSuccess: () {}),
                          // );
                        },
                        icon: const Icon(Icons.payment_rounded,
                            color: Colors.white),
                        label: const Text(
                          'Generate Payroll',
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
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildDataTable(context, state.employeeAccounts, notifier, state),
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
    if (state.sortBy == 'lastname') {
      sortedData.sort((a, b) {
        final aAcc = a['account'] as AccountsData?;
        final bAcc = b['account'] as AccountsData?;
        return state.ascending
            ? (aAcc?.lastname ?? '')
                .toLowerCase()
                .compareTo((bAcc?.lastname ?? '').toLowerCase())
            : (bAcc?.lastname ?? '')
                .toLowerCase()
                .compareTo((aAcc?.lastname ?? '').toLowerCase());
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
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
          columnSpacing: 24,
          columns: [
            DataColumn(label: _buildSortableHeader('Employee Name', 'lastname', state, notifier)),
            DataColumn(label: _buildHeaderText('Position')),
            DataColumn(label: _buildHeaderText('Salary')),
            DataColumn(label: _buildHeaderText('Calculated')),
            DataColumn(label: _buildHeaderText('Bonus')),
            DataColumn(label: _buildHeaderText('Deductions')),
            DataColumn(label: _buildHeaderText('Remarks')),
          ],
          rows: data.map((item) {
            final emp = item['employee'] as EmployeeData;
            final acc = item['account'] as AccountsData;
            return DataRow(cells: [
              DataCell(Text(acc.lastname)),
              DataCell(Text(emp.companyRole)),
                DataCell(
                Builder(
                  builder: (context) {
                    print('Monthly Salary for ${emp.toJson()}');
                  return Text(emp.monthlySalary.toString());
                  },
                ),
                ),
              DataCell(Text(item['firstName'] ?? '')),
              DataCell(
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: item['bonus'],
                    decoration: const InputDecoration(
                      prefixText: '+ ₱',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              DataCell(SizedBox(
                width: 150,
                child: TextField(
                  controller: item['deduction'],
                  decoration: const InputDecoration(
                    prefixText: '- ₱',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                ),
              )),
              DataCell(SizedBox(
                width: 250,
                child: TextField(
                  controller: item['remarks'],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableHeader(
    String title,
    String column,
    EmployeeState state,
    EmployeeNotifier notifier,
  ) {
    print('Employee Data: $title, $column, ${state.sortBy}, ${state.ascending}');
    return InkWell(
      onTap: () => notifier.sort(column),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'NunitoSans',
            ),
          ),
          if (state.sortBy == column)
            Icon(
              state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 18,
              color: Colors.white,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, {bool center = false}) {
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
}
