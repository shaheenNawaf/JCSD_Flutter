import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';
import 'package:jcsd_flutter/modals/request_cash_advance.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';

class Payslip extends ConsumerStatefulWidget {
  final AccountsData? acc;
  final EmployeeData? emp;
  final AccountsData? loggedInAccount;
  final EmployeeData? verifiedByEmp;
  final PayrollData? payroll;

  const Payslip(
      {super.key,
      this.acc,
      this.emp,
      this.loggedInAccount,
      this.verifiedByEmp,
      this.payroll});

  @override
  ConsumerState<Payslip> createState() => _PayslipState();
}

class _PayslipState extends ConsumerState<Payslip> {
  final String _activeSubItem = '/employeeList';
  late DateTime selectedDate = payroll!.createdAt;

  int attendanceRecords = 0;
  int lateMinutes = 0;
  int overtimeMinutes = 0;
  int leaveDays = 0;
  double totalCashAdvance = 0;

  static const Map<int, Map<String, double>> sssTable = {
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

  late double monthlySalary;

  late double sssEmployee = calculateSSS(monthlySalary);
  late double philHealthEmployee = calculatePhilHealth(monthlySalary);
  late double pagIbigEmployee = calculatePagIBIG(monthlySalary);
  late double withholdingTax = calculateWithholdingTax(
      monthlySalary, sssEmployee, philHealthEmployee, pagIbigEmployee);

  totaldeducations() {
    return (pagIbigEmployee +
        philHealthEmployee +
        sssEmployee +
        withholdingTax +
        ((payroll!.monthlySalary / 170) *
            ((lateMinutes / 60) + (leaveDays * 8))) +
        totalCashAdvance +
        payroll!.deductions);
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

  late final AccountsData? user = widget.acc;
  late final EmployeeData? emp = widget.emp;
  late final AccountsData? receivedBy = widget.acc;
  late final EmployeeData? receivedByEmp = widget.emp;
  late final AccountsData? verifiedBy = widget.loggedInAccount;
  late final EmployeeData? verifiedByEmp = widget.verifiedByEmp;
  late final PayrollData? payroll = widget.payroll;

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

  Future<void> _printPayslip() async {
    final imageLogo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    final pdf = pw.Document();

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
                    'Name: ${user?.firstName ?? 'N/A'} ${user?.lastname ?? ''}'),
                pw.Text('Role: ${emp?.companyRole ?? 'N/A'}'),
                pw.Text(
                    'Date Issued: ${selectedDate.toLocal().toString().split(' ')[0]}'),
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
                    // Attendance
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Attendance:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Number of Days Present:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('$attendanceRecords')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Number of Leaves:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('$leaveDays')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('OT Regular Day:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${(overtimeMinutes / 60).toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Tardiness:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${(lateMinutes / 60).toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Date:')),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          payroll?.createdAt != null
                              ? payroll!.createdAt
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'N/A',
                        ),
                      ),
                    ]),

                    pw.TableRow(children: [pw.SizedBox(), pw.SizedBox()]),

                    // Deductions
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Deductions:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Pagibig:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('$pagIbigEmployee')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('PhilHealth:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('$philHealthEmployee')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('SSS:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('$sssEmployee')),
                    ]),

                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Tardiness')),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(((payroll!.monthlySalary / 170) *
                                ((lateMinutes / 60) + (leaveDays * 8)))
                            .toStringAsFixed(2)),
                      )
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Others:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${(payroll?.deductions ?? 0).toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Withholding Tax:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('$withholdingTax')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Cash Advance:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${totalCashAdvance.toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Total Deductions:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${totaldeducations().toStringAsFixed(2)}')),
                    ]),

                    pw.TableRow(children: [pw.SizedBox(), pw.SizedBox()]),

                    // Payroll
                    pw.TableRow(children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('Payroll:',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Total Salary:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${(payroll?.monthlySalary ?? 0).toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Total Deductions:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${totaldeducations().toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Bonus:')),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                              '${(payroll?.bonus ?? 0).toStringAsFixed(2)}')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text('Take Home Pay:',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text('${totalSalary().toStringAsFixed(2)}',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ]),
                  ],
                ),

                pw.SizedBox(height: 25),

                // Footer with signature lines
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Verified by (Logged in user)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Verified by:',
                            style: pw.TextStyle(
                                fontSize: 12, fontStyle: pw.FontStyle.italic)),
                        pw.SizedBox(height: 25),
                        pw.Text('_________________________',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text('Cyril Adrianne Lumbre',
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Employer', style: pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    // Received by (Payslip owner)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Received by:',
                            style: pw.TextStyle(
                                fontSize: 12, fontStyle: pw.FontStyle.italic)),
                        pw.SizedBox(height: 25),
                        pw.Text('_________________________',
                            style: pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 5),
                        pw.Text(
                            '${user?.firstName ?? 'N/A'} ${user?.lastname ?? ''}',
                            style: pw.TextStyle(
                                fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text(emp?.companyRole ?? 'N/A',
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

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    // await Printing.sharePdf(
    //   bytes: await pdf.save(),
    //   filename: '${user?.lastname}_Payslip-${DateTime.now()}.pdf',
    // );
  }

  totalSalary() {
    return (payroll!.monthlySalary + payroll!.bonus - totaldeducations());
  }

  @override
  void initState() {
    super.initState();
    monthlySalary = payroll!.monthlySalary;
    Future.wait([
      _fetchAttendanceData(),
      _fetchLeavesData(),
      _fetchCashAdvanceData(),
    ]).then((_) {
      setState(() {
        sssEmployee = calculateSSS(monthlySalary);
        philHealthEmployee = calculatePhilHealth(monthlySalary);
        pagIbigEmployee = calculatePagIBIG(monthlySalary);
        withholdingTax = calculateWithholdingTax(
            monthlySalary, sssEmployee, philHealthEmployee, pagIbigEmployee);
      });
      uploadCalculatedMonthlySalary();
    }).catchError((error) {
      print('Error fetching data: $error');
    });
  }

  void _showRequestCashAdvanceModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CashAdvanceForm(),
    );
  }

  String _display(dynamic v) =>
      (v == null || (v is String && v.trim().isEmpty)) ? 'N/A' : v.toString();

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Payslip',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildWebView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
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
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Basic Information'),
                  _buildInfoRow(FontAwesomeIcons.envelope, 'Email: ',
                      _display(user?.email)),
                  _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ',
                      _display(user?.contactNumber)),
                  _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ',
                      _formatDate(user?.birthDate)),
                  _buildDivider(),
                  _buildSectionTitle('Address'),
                  _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
                      _display(user?.address)),
                  _buildInfoRow(FontAwesomeIcons.flag, 'Region: ',
                      _display(user?.region)),
                  _buildInfoRow(FontAwesomeIcons.globe, 'Province: ',
                      _display(user?.province)),
                  _buildInfoRow(
                      FontAwesomeIcons.city, 'City: ', _display(user?.city)),
                  _buildInfoRow(FontAwesomeIcons.mapPin, 'Zip Code: ',
                      _display(user?.zipCode)),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[300]),
          Expanded(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text("Payslip Breakdown Summary",
                      style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PayslipRow(
                              label: 'Attendance: ', value: '', isBold: true),
                          PayslipRow(
                            label: 'Number of Days Present: ',
                            value: attendanceRecords.toString(),
                          ),
                          PayslipRow(
                              label: 'Number of Leaves: ',
                              value: leaveDays.toString()),
                          PayslipRow(
                              label: 'OT Regular Day: ',
                              value: (overtimeMinutes / 60).toString()),
                          PayslipRow(
                            label: 'Tardiness (hours): ',
                            value: (lateMinutes / 60).toStringAsFixed(2),
                          ),
                          PayslipRow(
                            label: 'Month: ',
                            value:
                                '${payroll!.createdAt.month}/${payroll!.createdAt.year}',
                          ),
                          Divider(
                              color: Colors.grey[300],
                              indent: 40,
                              endIndent: 40),
                          const PayslipRow(
                              label: 'Deductions: ', value: '', isBold: true),
                          PayslipRow(
                              label: 'Pagibig: ',
                              value: pagIbigEmployee.toString()),
                          PayslipRow(
                              label: 'PhilHealth: ',
                              value: philHealthEmployee.toString()),
                          PayslipRow(
                              label: 'SSS: ', value: sssEmployee.toString()),
                          PayslipRow(
                            label: 'Tardiness: ',
                            value: ((payroll!.monthlySalary / 170) *
                                    ((lateMinutes / 60) + (leaveDays * 8)))
                                .toStringAsFixed(2),
                          ),
                          PayslipRow(
                              label: 'Others: ',
                              value: payroll!.deductions.toString()),
                          PayslipRow(
                              label: 'Withholding Tax: ',
                              value: withholdingTax.toStringAsFixed(2)),
                          PayslipRow(
                              label: 'Cash Advance: ',
                              value: totalCashAdvance.toString()),
                          PayslipRow(
                              label: 'Total Deductions: ',
                              value: totaldeducations().toStringAsFixed(2),
                              isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 100),
                          const PayslipRow(
                              label: 'Payroll: ', value: '', isBold: true),
                          PayslipRow(
                              label: 'Total Salary: ',
                              value: payroll!.monthlySalary.toStringAsFixed(2)),
                          PayslipRow(
                              label: 'Total Deductions: ',
                              value: totaldeducations().toStringAsFixed(2)),
                          PayslipRow(
                              label: 'Bonus: ',
                              value: payroll!.bonus.toString()),
                          PayslipRow(
                              label: 'Take Home Pay: ',
                              value: '₱${totalSalary().toStringAsFixed(2)}',
                              isBold: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 40, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                              '/employeeList/profile/payslip/cashAdvanceHistory',
                              extra: {
                                'account': user,
                                'employee': emp,
                              });
                        },
                        icon: const FaIcon(FontAwesomeIcons.clockRotateLeft,
                            color: Colors.white, size: 16),
                        label: const Text(
                          'Cash Advance History',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _showRequestCashAdvanceModal,
                        icon: const FaIcon(FontAwesomeIcons.moneyBillTransfer,
                            color: Colors.white, size: 16),
                        label: const Text(
                          'Request Cash Advance',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _printPayslip,
                        icon: const FaIcon(FontAwesomeIcons.print,
                            color: Colors.white, size: 16),
                        label: const Text(
                          'Print Payslip',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black38,
            ),
            child: const FaIcon(FontAwesomeIcons.user,
                color: Colors.white, size: 35),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${user?.firstName ?? 'N/A'} ${user?.lastname ?? ''}",
                style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                (emp?.isAdmin ?? false) ? 'Admin' : 'Employee',
                style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildInfoRow(IconData icon, String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
            child: SizedBox(
                width: 25, child: FaIcon(icon, color: Colors.grey, size: 20)),
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      );

  Widget _buildDivider() =>
      Divider(color: Colors.grey[300], indent: 40, endIndent: 40);
}

class PayslipRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const PayslipRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 40, 0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
