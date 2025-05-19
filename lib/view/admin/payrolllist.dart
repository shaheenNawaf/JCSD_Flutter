import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_notifier.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_provider.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_state.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

class PayrollList extends ConsumerStatefulWidget {
  final AccountsData? acc;
  final EmployeeData? emp;
  final AccountsData? loggedInAccount;
  final EmployeeData? verifiedByEmp;
  final PayrollData? payroll;

  const PayrollList({
    super.key,
    this.acc,
    this.emp,
    this.loggedInAccount,
    this.verifiedByEmp,
    this.payroll,
  });

  @override
  ConsumerState<PayrollList> createState() => _PayrollListState();
}

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

class _PayrollListState extends ConsumerState<PayrollList> {
  String _searchText = '';

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    if (_searchText.trim().isEmpty) return data;
    final query = _searchText.toLowerCase();
    return data.where((record) {
      final account = record['account'] as AccountsData?;
      final payroll = record['payroll'] as PayrollData;
      final name = '${account?.firstName ?? ''} ${account?.lastname ?? ''}'
          .toLowerCase();
      final payDate = _formatDate(payroll.createdAt).toLowerCase();
      return name.contains(query) || payDate.contains(query);
    }).toList();
  }

  DateTime selectedDate = DateTime.now();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int attendanceRecords = 0;

  late final AccountsData? user = widget.acc;
  late final EmployeeData? emp = widget.emp;
  late final AccountsData? receivedBy = widget.acc;
  late final EmployeeData? receivedByEmp = widget.emp;
  late final AccountsData? verifiedBy = widget.loggedInAccount;
  late final EmployeeData? verifiedByEmp = widget.verifiedByEmp;

  late final PayrollData? payroll = widget.payroll;

  int lateMinutes = 0;
  int overtimeMinutes = 0;
  int leaveDays = 0;
  double totalCashAdvance = 0;

  // SSS Table and calculation function
  Map<int, Map<String, double>> sssTable = {
    15000: {'ee': 750.00, 'er': 1500.00},
    15500: {'ee': 775.00, 'er': 1550.00},
    16000: {'ee': 800.00, 'er': 1600.00},
    16500: {'ee': 825.00, 'er': 1650.00},
    17000: {'ee': 850.00, 'er': 1700.00},
    17500: {'ee': 875.00, 'er': 1750.00},
    18000: {'ee': 900.00, 'er': 1800.00},
    18500: {'ee': 925.00, 'er': 1850.00},
    19000: {'ee': 950.00, 'er': 1900.00},
    19500: {'ee': 975.00, 'er': 1950.00},
    20000: {'ee': 1000.00, 'er': 2000.00},
    20500: {'ee': 1025.00, 'er': 2050.00},
    21000: {'ee': 1050.00, 'er': 2100.00},
    21500: {'ee': 1075.00, 'er': 2150.00},
    22000: {'ee': 1100.00, 'er': 2200.00},
    22500: {'ee': 1125.00, 'er': 2250.00},
    23000: {'ee': 1150.00, 'er': 2300.00},
    23500: {'ee': 1175.00, 'er': 2350.00},
    24000: {'ee': 1200.00, 'er': 2400.00},
    24500: {'ee': 1225.00, 'er': 2450.00},
    25000: {'ee': 1250.00, 'er': 2500.00},
    25500: {'ee': 1275.00, 'er': 2550.00},
    26000: {'ee': 1300.00, 'er': 2600.00},
    26500: {'ee': 1325.00, 'er': 2650.00},
    27000: {'ee': 1350.00, 'er': 2700.00},
    27500: {'ee': 1375.00, 'er': 2750.00},
    28000: {'ee': 1400.00, 'er': 2800.00},
    28500: {'ee': 1425.00, 'er': 2850.00},
    29000: {'ee': 1450.00, 'er': 2900.00},
    29500: {'ee': 1475.00, 'er': 2950.00},
    30000: {'ee': 1500.00, 'er': 3000.00},
  };

  double calculateSSS(double monthlySalary) {
    double employeeShare = 0.0;
    for (var msc in sssTable.keys) {
      if (monthlySalary <= msc) {
        employeeShare = sssTable[msc]!['ee']!;
        break;
      } else if (monthlySalary > sssTable.keys.last) {
        employeeShare = sssTable[sssTable.keys.last]!['ee']!;
        break;
      }
    }
    return employeeShare;
  }

  double calculatePhilHealth(double monthlySalary) {
    double premiumRate = 0.05;
    double salaryFloor = 10000;
    double salaryCeiling = 100000;
    double premium;

    if (monthlySalary < salaryFloor) {
      premium = salaryFloor * premiumRate;
    } else if (monthlySalary > salaryCeiling) {
      premium = salaryCeiling * premiumRate;
    } else {
      premium = monthlySalary * premiumRate;
    }

    return premium / 2; // Employee's share is 50%
  }

  double calculatePagIBIG(double monthlySalary) {
    double contributionRate = 0.02;
    double maxContributionSalary = 10000;
    double contributionBase = min(monthlySalary, maxContributionSalary);
    return contributionBase * contributionRate; // Employee's share
  }

  double calculateWithholdingTax(double grossMonthlySalary, double sssEe,
      double philhealthEe, double pagibigEe) {
    double taxableIncome =
        grossMonthlySalary - sssEe - philhealthEe - pagibigEe;

    if (taxableIncome <= 20833) {
      return 0.00;
    } else if (taxableIncome <= 33333) {
      return (taxableIncome - 20833) * 0.15;
    } else if (taxableIncome <= 66667) {
      return 1875.00 + (taxableIncome - 33333) * 0.20;
    } else if (taxableIncome <= 166667) {
      return 8541.67 + (taxableIncome - 66667) * 0.25;
    } else if (taxableIncome <= 666667) {
      return 33541.67 + (taxableIncome - 166667) * 0.30;
    } else {
      return 183541.67 + (taxableIncome - 666667) * 0.35;
    }
  }

  totaldeducations() {
    return (calculatePagIBIG(payroll!.monthlySalary) +
        calculatePhilHealth(payroll!.monthlySalary) +
        calculateSSS(payroll!.monthlySalary) +
        payroll!.withholdingTax +
        // The following lines assume lateMinutes, leaveDays, totalCashAdvance are defined elsewhere.
        // If not, replace them with appropriate values or calculations.
        ((payroll!.monthlySalary / 170) *
            ((lateMinutes / 60) + (leaveDays * 8))) +
        totalCashAdvance +
        payroll!.deductions);
  }

  Future<void> _fetchAttendanceData() async {
    try {
      final response = await Supabase.instance.client
          .from('attendance')
          .select()
          .eq('userID', user!.userID)
          .filter('attendance_date', 'gte',
              DateTime(selectedDate.year, selectedDate.month, 1))
          .filter('attendance_date', 'lt',
              DateTime(selectedDate.year, selectedDate.month + 1, 1));

      final count = response.length;
      int totalLateMinutes = 0;
      int totalOvertimeMinutes = 0;
      for (var record in response) {
        if (record['late_minutes'] != null) {
          totalLateMinutes +=
              int.tryParse(record['late_minutes'].toString()) ?? 0;
        }
        if (record['overtime_minutes'] != null) {
          totalOvertimeMinutes +=
              int.tryParse(record['overtime_minutes'].toString()) ?? 0;
        }
      }

      setState(() {
        attendanceRecords = count;
        lateMinutes = totalLateMinutes;
        overtimeMinutes = totalOvertimeMinutes;
      });
      print(
          'Fetched attendance data: $count, total late minutes: $totalLateMinutes');
    } catch (e) {
      print('Error fetching attendance data: $e');
    }
  }

  late double monthlySalary;

  @override
  void initState() {
    super.initState();
    monthlySalary = emp?.monthlySalary ?? 0.0;
    Future.wait([
      _fetchAttendanceData(),
      _fetchLeavesData(),
      _fetchCashAdvanceData(),
    ]).then((_) {
      setState(() {});
    }).catchError((error) {
      print('Error fetching data: $error');
    });
  }

  totalSalary() {
    return (payroll!.monthlySalary + payroll!.bonus - totaldeducations());
  }

  Future<void> _fetchLeavesData() async {
    try {
      final response = await Supabase.instance.client
          .from('leave_requests')
          .select()
          .eq('userID', user!.userID)
          .eq('status', 'Approved');

      for (var leave in response) {
        DateTime start = DateTime.parse(leave['startDate']);
        DateTime end = DateTime.parse(leave['endDate']);

        DateTime monthStart =
            DateTime(selectedDate.year, selectedDate.month, 1);
        DateTime monthEnd =
            DateTime(selectedDate.year, selectedDate.month + 1, 0);

        DateTime effectiveStart =
            start.isBefore(monthStart) ? monthStart : start;
        DateTime effectiveEnd = end.isAfter(monthEnd) ? monthEnd : end;

        if (effectiveStart.isAfter(effectiveEnd)) continue;

        leaveDays += effectiveEnd.difference(effectiveStart).inDays + 1;
      }
      print('Leave days in month: $leaveDays');
      setState(() {
        leaveDays = leaveDays;
      });
      print('Fetched approved leave days: $leaveDays');
    } catch (e) {
      print('Error fetching leave data: $e');
    }
  }

  Future<void> _fetchCashAdvanceData() async {
    try {
      final response = await Supabase.instance.client
          .from('cash_advance')
          .select()
          .eq('employeeID', emp?.employeeID ?? '')
          .eq('status', 'Approved');

      double sum = 0.0;
      for (var ca in response) {
        if (ca['created_at'] != null && ca['cashAdvance'] != null) {
          DateTime caDate = DateTime.parse(ca['created_at']);
          if (caDate.year == selectedDate.year &&
              caDate.month == selectedDate.month) {
            sum += double.tryParse(ca['cashAdvance'].toString()) ?? 0.0;
          }
        }
      }

      setState(() {
        totalCashAdvance = sum;
      });
    } catch (e) {
      print('Error fetching cash advance data: $e');
    }
  }

  Future<void> uploadCalculatedMonthlySalary() async {
    try {
      final double calculatedMonthlySalary = totalSalary();
      await Supabase.instance.client
          .from('payroll')
          .update({'calculatedMonthlySalary': calculatedMonthlySalary}).eq(
              'id', payroll!.id);
      print('Calculated monthly salary uploaded: $calculatedMonthlySalary');
    } catch (e) {
      print('Error uploading calculated monthly salary: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(payrollNotifierProvider);
    final notifier = ref.read(payrollNotifierProvider.notifier);

    final filteredPayrolls = _applyFilters(state.payrolls);

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
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => context.pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // ElevatedButton.icon(
                          //   onPressed: _printPayslip,
                          //   icon: const FaIcon(FontAwesomeIcons.print,
                          //       color: Colors.white, size: 16),
                          //   label: const Text(
                          //     'Print Batch Payroll',
                          //     style: TextStyle(
                          //       fontFamily: 'NunitoSans',
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Color(0xFF00AEEF),
                          //     minimumSize: const Size(120, 48),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(width: 16),
                          // DropdownButton<int>(
                          //   value: selectedMonth,
                          //   dropdownColor: Colors.white,
                          //   style: const TextStyle(
                          //     fontFamily: 'NunitoSans',
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.black,
                          //   ),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       selectedMonth = value!;
                          //     });
                          //   },
                          //   items: List.generate(12, (index) => index + 1)
                          //       .map((month) {
                          //     return DropdownMenuItem(
                          //       value: month,
                          //       child: Text(
                          //         DateTime(0, month)
                          //             .month
                          //             .toString()
                          //             .padLeft(2, '0'),
                          //       ),
                          //     );
                          //   }).toList(),
                          // ),
                          // const SizedBox(width: 12),
                          // DropdownButton<int>(
                          //   value: selectedYear,
                          //   dropdownColor: Colors.white,
                          //   style: const TextStyle(
                          //     fontFamily: 'NunitoSans',
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.black,
                          //   ),
                          //   onChanged: (value) {
                          //     setState(() {
                          //       selectedYear = value!;
                          //     });
                          //   },
                          //   items: List.generate(10, (index) {
                          //     final year = DateTime.now().year - 5 + index;
                          //     return DropdownMenuItem(
                          //       value: year,
                          //       child: Text(year.toString()),
                          //     );
                          //   }).toList(),
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 40,
                            child: TextField(
                              controller:
                                  TextEditingController(text: _searchText)
                                    ..selection = TextSelection.collapsed(
                                        offset: _searchText.length),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFABABAB),
                                  fontFamily: 'NunitoSans',
                                ),
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchText.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchText = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchText = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _hasPayrollForCurrentMonth(state)
                                ? null
                                : () {
                                    context.go(
                                        '/employeeList/payrollList/generatePayroll');
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
                          )
                        ],
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
                    child: _buildDataTable(
                        context, filteredPayrolls, state, notifier),
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
    List<Map<String, dynamic>> payrolls,
    PayrollState state,
    PayrollNotifier notifier,
  ) {
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
              label: _buildSortableHeader(
                  'Employee Name', 'employeeName', state, notifier),
            ),
            DataColumn(
              label: _buildSortableHeader(
                  'Payment Date', 'created_at', state, notifier),
            ),
            DataColumn(
              label: _buildSortableHeader(
                  'Monthly Salary', 'monthlySalary', state, notifier),
            ),
            DataColumn(label: _buildHeaderText('Action')),
          ],
          rows: state.payrolls.map((record) {
            final payroll = record['payroll'] as PayrollData;
            final account = record['account'] as AccountsData?;

            return DataRow(cells: [
              DataCell(Text(
                  '${account?.firstName ?? 'N/A'} ${account?.lastname ?? ''}')),
              DataCell(Text(_formatDate(payroll.createdAt))),
              DataCell(
                Text(
                    '\₱${NumberFormat("#,##0.00", "en_US").format(payroll.monthlySalary)}'),
              ),
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

  Future<void> _printPayslip() async {
    final imageLogo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    final pdf = pw.Document();
    final state = ref.read(payrollNotifierProvider);

    for (var record in state.payrolls.where((record) {
      final payroll = record['payroll'] as PayrollData;
      return payroll.createdAt.month == selectedMonth &&
          payroll.createdAt.year == selectedYear;
    })) {
      final payroll = record['payroll'] as PayrollData;
      final account = record['account'] as AccountsData?;
      final employee = record['employee'] as EmployeeData?;
      // final now = DateTime.now();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(imageLogo, width: 100, height: 100),
                  pw.SizedBox(height: 12),
                  pw.Text('Payslip Breakdown Summary',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 12),
                  pw.Text(
                      'Name: ${account?.firstName ?? 'N/A'} ${account?.lastname ?? ''}'),
                  pw.Text('Role: ${employee?.position ?? 'N/A'}'),
                  pw.Text(
                      'Date Issued: ${payroll.createdAt.toLocal().toString().split(' ')[0]}'),
                  pw.SizedBox(height: 20),
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(1),
                    },
                    defaultVerticalAlignment:
                        pw.TableCellVerticalAlignment.middle,
                    children: [
                      _tableRowHeader('Attendance:'),
                      _tableRow('Number of Days Present:', ''),
                      _tableRow('Number of Leaves:', ''),
                      _tableRow('OT Regular Day:', ''),
                      _tableRow('Tardiness:', ''),
                      _tableRow('Absences:', ''),
                      _tableRow('Date:',
                          payroll.createdAt.toLocal().toString().split(' ')[0]),
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(9),
                        ),
                      ]),
                      _tableRowHeader('Deductions:'),
                      _tableRow(
                          'Pagibig:',
                          calculatePagIBIG(payroll.monthlySalary)
                              .toStringAsFixed(2)),
                      _tableRow(
                          'PhilHealth:',
                          calculatePhilHealth(payroll.monthlySalary)
                              .toStringAsFixed(2)),
                      _tableRow(
                          'SSS:',
                          calculateSSS(payroll.monthlySalary)
                              .toStringAsFixed(2)),
                      _tableRow('Tardiness:', '0'),
                      _tableRow('Others:', '${payroll.deductions}'),
                      _tableRow(
                        'Withholding Tax:',
                        calculateWithholdingTax(
                          payroll.monthlySalary,
                          calculateSSS(payroll.monthlySalary),
                          calculatePhilHealth(payroll.monthlySalary),
                          calculatePagIBIG(payroll.monthlySalary),
                        ).toStringAsFixed(2),
                      ),
                      _tableRow('Total Deductions:', '0'),
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(9),
                        ),
                      ]),
                      _tableRowHeader('Payroll:'),
                      _tableRow('Total Salary:', '${payroll.monthlySalary}'),
                      _tableRow('Total Deductions:', '0'),
                      _tableRow('Bonus:', '${payroll.bonus}'),
                      _tableRow('Take Home Pay:', '', bold: true),
                    ],
                  ),
                  pw.SizedBox(height: 25),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Verified by:',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontStyle: pw.FontStyle.italic)),
                          pw.SizedBox(height: 25),
                          pw.Text('_________________________',
                              style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 5),
                          pw.Text('Cyril Adrianne Lumbre',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('Employer',
                              style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Received by:',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontStyle: pw.FontStyle.italic)),
                          pw.SizedBox(height: 25),
                          pw.Text('_________________________',
                              style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 5),
                          pw.Text(
                              '${account?.firstName ?? 'N/A'} ${account?.lastname ?? ''}',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(employee?.position ?? 'N/A',
                              style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    // await Printing.sharePdf(
    //   bytes: await pdf.save(),
    //   filename: 'Payroll_Batch_${DateTime.now()}.pdf',
    // );
  }

  pw.TableRow _tableRow(String label, String value, {bool bold = false}) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(2),
        child: pw.Text(label),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(2),
        child: pw.Text(value,
            style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
      ),
    ]);
  }

  pw.TableRow _tableRowHeader(String label) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(''),
        ),
      ],
    );
  }
}
