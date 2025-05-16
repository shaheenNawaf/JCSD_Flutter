// UPDATED payslip.dart with dynamic user and employee data like in leave_requests.dart

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

class Payslip extends ConsumerStatefulWidget {
  final AccountsData? acc;
  final EmployeeData? emp;
  final PayrollData? payroll;

  const Payslip({super.key, this.acc, this.emp, this.payroll});

  @override
  ConsumerState<Payslip> createState() => _PayslipState();
}

class _PayslipState extends ConsumerState<Payslip> {
  final String _activeSubItem = '/employeeList';
  DateTime selectedDate = DateTime.now();

  late final AccountsData? user = widget.acc;
  late final EmployeeData? emp = widget.emp;
  late final PayrollData? payroll = widget.payroll;

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
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                      child: Text("Payslip Breakdown Summary",
                          style: TextStyle(
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 40, 10),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          DateTime? pickedDate = await showMonthPicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        icon: const FaIcon(FontAwesomeIcons.calendar,
                            color: Colors.black),
                        label: Text(
                          '${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
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
                          const PayslipRow(
                              label: 'Number of Days Present: ', value: '17'),
                          const PayslipRow(
                              label: 'Number of Leaves: ', value: '3'),
                          const PayslipRow(
                              label: 'OT Regular Day: ', value: '3'),
                          const PayslipRow(label: 'Tardiness: ', value: '3'),
                          const PayslipRow(label: 'Absences: ', value: '0'),
                          Divider(
                              color: Colors.grey[300],
                              indent: 40,
                              endIndent: 40),
                          const PayslipRow(
                              label: 'Deductions: ', value: '', isBold: true),
                          PayslipRow(
                              label: 'Pagibig: ', value: payroll!.pagibig.toString()),
                          PayslipRow(
                              label: 'PhilHealth: ', value: payroll!.philhealth.toString()),
                          PayslipRow(label: 'SSS: ', value: payroll!.sss.toString()),
                          const PayslipRow(label: 'Others: ', value: '₱50.00'),
                          PayslipRow(
                              label: 'Withholding Tax: ', value: payroll!.withholdingTax.toString()),
                          const PayslipRow(
                              label: 'Cash Advance: ', value: '₱2,000.00'),
                          const PayslipRow(
                              label: 'Total Deductions: ',
                              value: '',
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
                          PayslipRow(
                              label: 'Payroll: ',
                              value: payroll!.calculatedMonthlySalary
                                  .toStringAsFixed(2),
                              isBold: true),
                          PayslipRow(label: 'Total Salary: ', value: payroll!.monthlySalary.toStringAsFixed(2)),
                          PayslipRow(
                              label: 'Total Deductions: ', value: payroll!.deductions.toString()),
                          PayslipRow(
                              label: 'Commission from Bookings: ',
                              value: '₱20,000'),
                          PayslipRow(label: 'Bonus: ', value: payroll!.bonus.toString()),
                          PayslipRow(
                              label: 'Take Home Pay: ',
                              value: '₱200,000',
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
                      // To be changed to print payslip functionality
                      ElevatedButton.icon(
                        onPressed: _showRequestCashAdvanceModal,
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
