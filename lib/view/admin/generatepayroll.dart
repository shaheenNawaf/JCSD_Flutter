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
import 'package:supabase_flutter/supabase_flutter.dart';


// Create a dedicated class to hold both the data and controllers
class EmployeePayrollEntry {
  final AccountsData account;
  final EmployeeData employee;
  final TextEditingController bonusController = TextEditingController();
  final TextEditingController deductionController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  EmployeePayrollEntry({required this.account, required this.employee});
  
  void dispose() {
    bonusController.dispose();
    deductionController.dispose();
    remarksController.dispose();
  }
}

// Create a provider for our payroll entries
final payrollEntriesProvider = StateProvider<List<EmployeePayrollEntry>>((ref) {
  final employeeState = ref.watch(employeeNotifierProvider);
  
  // Convert the employee accounts to our new format
  return employeeState.employeeAccounts.map((item) {
    final account = item['account'] as AccountsData;
    final employee = item['employee'] as EmployeeData;
    return EmployeePayrollEntry(account: account, employee: employee);
  }).toList();
});

class GeneratePayrollPage extends ConsumerStatefulWidget {
  const GeneratePayrollPage({super.key});

  @override
  ConsumerState<GeneratePayrollPage> createState() =>
      _GeneratePayrollPageState();
}

class _GeneratePayrollPageState extends ConsumerState<GeneratePayrollPage> {
  List<EmployeePayrollEntry> payrollEntries = [];

  @override
  void initState() {
    super.initState();
    // Initial creation of payroll entries will happen in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Create payroll entries based on the current state
    final employeeAccounts = ref.read(employeeNotifierProvider).employeeAccounts;
    if (payrollEntries.isEmpty) {
      payrollEntries = employeeAccounts.map((item) {
        final account = item['account'] as AccountsData;
        final employee = item['employee'] as EmployeeData;
        return EmployeePayrollEntry(account: account, employee: employee);
      }).toList();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final entry in payrollEntries) {
      entry.dispose();
    }
    super.dispose();
  }

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
                        onPressed: () {
                          for (final entry in payrollEntries) {
                            final name = entry.account.lastname;
                            print('Controller exists for $name: true');
                            
                            final bonus = entry.bonusController.text;
                            final deduction = entry.deductionController.text;
                            final remarks = entry.remarksController.text;
                            
                            print('Employee: $name');
                            print('Bonus: $bonus');
                            print('Deduction: $deduction');
                            print('Remarks: $remarks');
                            print('----------------------');
                          }

                          // showDialog(
                          //   context: context,
                          //   builder: (context) => ConfirmGeneratePayroll(onSuccess: () {
                          //     // Process the payroll data here
                          //   }),
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
                    child: _buildDataTable(context, state, notifier),
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
    EmployeeState state,
    EmployeeNotifier notifier,
  ) {
    // Apply sorting to our payrollEntries if needed
    final sortedEntries = List<EmployeePayrollEntry>.from(payrollEntries);
    if (state.sortBy == 'firstName') {
      sortedEntries.sort((a, b) {
        return state.ascending
            ? (a.account.firstName)
                .toLowerCase()
                .compareTo((b.account.firstName).toLowerCase())
            : (b.account.firstName)
                .toLowerCase()
                .compareTo((a.account.firstName).toLowerCase());
      });
    } else if (state.sortBy == 'email') {
      sortedEntries.sort((a, b) {
        return state.ascending
            ? (a.account.email)
                .toLowerCase()
                .compareTo((b.account.email).toLowerCase())
            : (b.account.email)
                .toLowerCase()
                .compareTo((a.account.email).toLowerCase());
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
            DataColumn(label: _buildSortableHeader('Employee Name', 'firstName', state, notifier)),
            DataColumn(label: _buildSortableHeader('Position', 'lastname', state, notifier)),
            DataColumn(label: _buildSortableHeader('Salary', 'address', state, notifier)),
            DataColumn(label: _buildSortableHeader('Calculated', 'firstName', state, notifier)),
            DataColumn(label: _buildHeaderText('Bonus')),
            DataColumn(label: _buildHeaderText('Deductions')),
            DataColumn(label: _buildHeaderText('Remarks')),
          ],
          rows: sortedEntries.map((entry) {
            return DataRow(cells: [
              DataCell(Text(entry.account.lastname)),
              DataCell(Text(entry.employee.companyRole)),
              DataCell(Text(entry.employee.monthlySalary.toString())),
              DataCell(Text('')), // Not clear what should go here
              DataCell(
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: entry.bonusController,
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
                  controller: entry.deductionController,
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
                  controller: entry.remarksController,
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