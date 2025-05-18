import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
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
                          ElevatedButton.icon(
                            onPressed: _printPayslip,
                            icon: const FaIcon(FontAwesomeIcons.print,
                                color: Colors.white, size: 16),
                            label: const Text(
                              'Print Batch Payroll',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00AEEF),
                              minimumSize: const Size(120, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<int>(
                            value: selectedMonth,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value!;
                              });
                            },
                            items: List.generate(12, (index) => index + 1)
                                .map((month) {
                              return DropdownMenuItem(
                                value: month,
                                child: Text(
                                  DateTime(0, month)
                                      .month
                                      .toString()
                                      .padLeft(2, '0'),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<int>(
                            value: selectedYear,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedYear = value!;
                              });
                            },
                            items: List.generate(10, (index) {
                              final year = DateTime.now().year - 5 + index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
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
      BuildContext context, PayrollState state, PayrollNotifier notifier) {
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
                  pw.Text('Role: ${employee?.companyRole ?? 'N/A'}'),
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
                      _tableRow('Pagibig:', '${payroll.pagibig}'),
                      _tableRow('PhilHealth:', '${payroll.philhealth}'),
                      _tableRow('SSS:', '${payroll.sss}'),
                      _tableRow(
                          'Withholding Tax:', '${payroll.withholdingTax}'),
                      _tableRow('Cash Advance:', '0'),
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
                          pw.Text(employee?.companyRole ?? 'N/A',
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
