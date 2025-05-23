import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_data.dart';
import 'package:jcsd_flutter/backend/modules/payroll/payroll_provider.dart';
import 'package:jcsd_flutter/modals/edit_payroll.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Payroll extends StatefulWidget {
  final EmployeeData? employee;
  final AccountsData? account;

  Payroll({
    super.key,
    required this.employee,
    required this.account,
  });

  @override
  _PayrollState createState() => _PayrollState();
}

class _PayrollState extends State<Payroll> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime selectedDate = DateTime.now();
  AccountsData? get user => widget.account;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer(bool isOpen) {
    isOpen ? _animationController.forward() : _animationController.reverse();
  }

  void _editBookingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const EditPayrollModal();
      },
    );
  }

  final String _activeSubItem = '/employeeList';

  String _display(dynamic v) =>
      (v == null || (v is String && v.trim().isEmpty)) ? 'N/A' : v.toString();

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF00AEEF),
              title: const Text(
                'Payroll',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon:
                      const FaIcon(FontAwesomeIcons.bars, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                    _toggleDrawer(true);
                  },
                ),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF00AEEF),
              child: Sidebar(
                activePage: _activeSubItem,
                onClose: () => _toggleDrawer(false),
              ),
            )
          : null,
      onDrawerChanged: _toggleDrawer,
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) Sidebar(activePage: _activeSubItem),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                                  color: Color(0xFF00AEEF)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const Text(
                              'Payroll',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AEEF),
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/profile', (route) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'assets/avatars/cat2.jpg'), // Replace with your image source
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isMobile
                            ? const SizedBox.shrink()
                            : _buildWebView(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMobile)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value * 0.6,
                  child: _animationController.value > 0
                      ? Container(color: Colors.black)
                      : const SizedBox.shrink(),
                );
              },
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
            color: Colors.grey.withValues(alpha: 0.3),
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
                      padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                      child: Text("Payroll History",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 40, 0),
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
                const SizedBox(height: 20),
                Expanded(
                  child: EmployeePayrollTable(
                    employeeId: int.parse(widget.employee!.employeeID),
                    selectedDate: selectedDate,
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
                (widget.employee?.position) != null
                    ? widget.employee!.position
                    : 'N/A',
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
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
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
  }

  Widget _buildDivider() =>
      Divider(color: Colors.grey[300], indent: 40, endIndent: 40);
}

class EmployeePayrollTable extends ConsumerWidget {
  final int employeeId;
  final DateTime selectedDate;

  const EmployeePayrollTable({
    super.key,
    required this.employeeId,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(payrollNotifierProvider);
    final filteredPayrolls = state.payrolls.where((record) {
      final payroll = record['payroll'] as PayrollData;
      return payroll.employeeID == employeeId &&
          payroll.createdAt.month == selectedDate.month &&
          payroll.createdAt.year == selectedDate.year;
    }).toList();

    if (filteredPayrolls.isEmpty) {
      return const Center(child: Text('No payroll records found'));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
      child: Container(
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
            headingRowColor: MaterialStateProperty.all(const Color(0xFF00AEEF)),
            columnSpacing: 24,
            columns: const [
              DataColumn(
                  label: Text(
                'Payment Date',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NunitoSans',
                  color: Colors.white,
                ),
              )),
              DataColumn(
                  label: Text(
                'Monthly Salary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NunitoSans',
                  color: Colors.white,
                ),
              )),
              DataColumn(
                  label: Text(
                'Net Salary',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NunitoSans',
                  color: Colors.white,
                ),
              )),
              DataColumn(
                  label: Text(
                'Actions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NunitoSans',
                  color: Colors.white,
                ),
              )),
            ],
            rows: filteredPayrolls.map((record) {
              final payroll = record['payroll'] as PayrollData;
              return DataRow(cells: [
                DataCell(Text(_formatDate(payroll.createdAt))),
                DataCell(
                  Text(
                    '₱${NumberFormat("#,##0.00", "en_US").format(payroll.monthlySalary)}',
                  ),
                ),
                DataCell(
                  Text(
                    '₱${NumberFormat("#,##0.00", "en_US").format(payroll.calculatedMonthlySalary)}',
                  ),
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
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class PayrollRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const PayrollRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 20)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 20)),
        ],
      ),
    );
  }
}
