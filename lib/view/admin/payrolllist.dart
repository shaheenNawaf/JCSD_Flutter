import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_notifier.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_provider.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_state.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class PayrollList extends ConsumerWidget {
  const PayrollList({super.key});

  bool _hasPayrollForCurrentMonth(PayrollState state) {
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;
  
  return state.payrolls.any((record) {
    final payroll = record['payroll'] as PayrollData;
    return payroll.createdAt.month == currentMonth && 
           payroll.createdAt.year == currentYear;
  });
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payrollNotifierProvider);
    final notifier = ref.read(payrollNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/employeeList'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Payroll List',
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => context.pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
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
                              onChanged: (value) {
                                // Implement search functionality if needed
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _hasPayrollForCurrentMonth(state)
                                ? null
                                : () {
                                    context.go('/employeeList/payrollList/generatePayroll');
                                  },
                            icon: Icon(
                              Icons.payment_rounded,
                              color: _hasPayrollForCurrentMonth(state) 
                                  ? Colors.grey 
                                  : Colors.white,
                            ),
                            label: Text(
                              'Generate Payroll',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: _hasPayrollForCurrentMonth(state)
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasPayrollForCurrentMonth(state)
                                  ? Colors.grey[300]
                                  : const Color(0xFF00AEEF),
                              minimumSize: const Size(120, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )],
                      ),
                    ],
                  ),
                ),
                if (state.loading) const LinearProgressIndicator(),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Error: ${state.error}',
                      style: const TextStyle(color: Colors.red),
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

  Widget _buildDataTable(BuildContext context, PayrollState state, PayrollNotifier notifier) {
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
            DataColumn(
              label: _buildSortableHeader('Employee Name', 'employeeName', state, notifier),
            ),
            DataColumn(
              label: _buildSortableHeader('Payment Date', 'created_at', state, notifier),
            ),
            DataColumn(
              label: _buildSortableHeader('Monthly Salary', 'monthlySalary', state, notifier),
            ),
            DataColumn(label: _buildHeaderText('Action')),
          ],
          rows: state.payrolls.map((record) {
            final payroll = record['payroll'] as PayrollData;
            final account = record['account'] as AccountsData?;

            return DataRow(cells: [
              DataCell(Text(account?.firstName ?? '')),
              DataCell(Text(_formatDate(payroll.createdAt))),
              DataCell(Text('\$${payroll.monthlySalary.toStringAsFixed(2)}')),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    final payroll = record['payroll'] as PayrollData;
                    final employee = record['employee'] as EmployeeData?;
                    final account = record['account'] as AccountsData?;
                    context.push('/employeeList/profile/payslip', extra: {
                      'account': account,
                      'employee': employee,
                      'payroll': payroll,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableHeader(
    String title,
    String column,
    PayrollState state,
    PayrollNotifier notifier,
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

  Widget _buildPagination(PayrollState state, PayrollNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: state.currentPage > 1
              ? () => notifier.goToPage(1)
              : null,
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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