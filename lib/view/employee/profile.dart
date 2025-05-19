import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/modals/request_cash_advance.dart';
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_attendance.dart';
import 'package:jcsd_flutter/modals/edit_employee_details.dart';
import 'package:jcsd_flutter/view/employee/modals/edit_attendance.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.targetUser, this.currentUserId, this.emp});
  final AccountsData? targetUser;
  final String? currentUserId;
  final EmployeeData? emp;

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  String _checkInMessage = '';
  String _checkOutMessage = '';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceHistory = [];
  AccountsData? user;
  bool get isViewingOwnProfile =>
      widget.targetUser?.userID == widget.currentUserId;
  String _totalHoursWorked = 'Loading...';
  bool _loadingHours = false;

  EmployeeData? emp;

  String displayValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String && value.trim().isEmpty) return 'N/A';
    return value.toString();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<bool> isCurrentUserAdmin() async {
    final container = ProviderContainer();
    try {
      final userRole = await container.read(userRoleProvider.future);
      return userRole == 'admin';
    } catch (e) {
      debugPrint("Error checking admin status: $e");
      return false;
    } finally {
      container.dispose();
    }
  }

  Future<void> _fetchEmployeeData() async {
    final userID = Supabase.instance.client.auth.currentUser?.id;
    if (userID == null) return;

    final response = await Supabase.instance.client
        .from('employee')
        .select()
        .eq('userID', userID)
        .maybeSingle();

    if (response != null) {
      setState(() {
        emp = EmployeeData.fromJson(response);
      });
    }
  }

  Future<void> _refreshEmployeeData() async {
    final userID = emp?.userID;
    if (userID == null) return;

    final response = await Supabase.instance.client
        .from('employee')
        .select()
        .eq('userID', userID)
        .maybeSingle();

    if (response != null) {
      setState(() {
        emp = EmployeeData.fromJson(response);
      });
    }
  }

  Future<void> _handleCheckIn() async {
    await checkIn(context);
    setState(() {
      _checkInMessage = 'Check-in initiated.';
      _checkOutMessage = '';
    });
    _fetchAttendanceHistory();
  }

  Future<void> _handleCheckOut() async {
    await checkOut(context);
    setState(() {
      _checkOutMessage = 'Check-out initiated.';
      _checkInMessage = '';
    });
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final history =
          await fetchUserAttendance(_startDate, _endDate, user!.userID);
      setState(() {
        _attendanceHistory = history;
      });
    } catch (e) {
      ToastManager().showToast(context, 'Failed to refresh data', Colors.red);
    }
  }

  Future<void> _fetchTotalHoursWorked() async {
    setState(() => _loadingHours = true);
    try {
      final hours = await calculateTotalHoursWorked(
        user!.userID,
        _startDate,
        _endDate,
      );
      setState(() => _totalHoursWorked = hours);
    } catch (e) {
      setState(() => _totalHoursWorked = 'Error');
    } finally {
      setState(() => _loadingHours = false);
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _fetchAttendanceHistory();
      _fetchTotalHoursWorked();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _fetchAttendanceHistory();
      _fetchTotalHoursWorked();
    }
  }

  void _showEditAttendanceModal(Map<String, dynamic> attendanceData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditAttendanceModal(attendanceData: attendanceData),
    ).then((success) {
      if (success == true) {
        _fetchAttendanceHistory();
        _fetchTotalHoursWorked();
      }
    });
  }

  // Future<void> _fetchEmployeeData() async {
  //   final userID = Supabase.instance.client.auth.currentUser?.id;
  //   if (userID == null) return;

  //   final response = await Supabase.instance.client
  //       .from('employee')
  //       .select()
  //       .eq('userID', userID)
  //       .maybeSingle();

  //   if (response != null) {
  //     setState(() {
  //       emp = EmployeeData.fromJson(response);
  //     });
  //   }
  // }

  void _showRequestCashAdvanceModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CashAdvanceForm(),
    );
  }

  @override
  void initState() {
    super.initState();
    user = widget.targetUser;
    emp = widget.emp;
    _fetchEmployeeData();

    if (emp == null) {
      _fetchEmployeeData();
    } else {
      _refreshEmployeeData();
    }

    _fetchAttendanceHistory();
    _fetchTotalHoursWorked();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  final String _activeSubItem = '/employeeList';
  late AnimationController _animationController;
  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
                  title: 'Profile',
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
                      displayValue(user?.email)),
                  _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ',
                      displayValue(user?.contactNumber)),
                  _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ',
                      formatDate(user?.birthDate)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                          child: SizedBox(
                            width: 25,
                            child: FaIcon(FontAwesomeIcons.pesoSign,
                                color: Colors.grey, size: 20),
                          ),
                        ),
                        const Text('Monthly Salary: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          emp?.monthlySalary != null
                              ? '₱${NumberFormat("#,##0.00", "en_US").format(emp!.monthlySalary)}'
                              : 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(width: 4),
                        FutureBuilder<bool>(
                          future: isCurrentUserAdmin(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.hasError ||
                                snapshot.data != true) {
                              return const SizedBox.shrink();
                            }
                            return GestureDetector(
                              onTap: () async {
                                final updatedEmp =
                                    await showDialog<EmployeeData>(
                                  context: context,
                                  builder: (context) =>
                                      EditEmployeeDetailsModal(emp: emp!),
                                );

                                if (updatedEmp != null) {
                                  setState(() {
                                    emp = updatedEmp;
                                  });
                                }
                              },
                              child: const Icon(Icons.edit,
                                  size: 16, color: Colors.black54),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),
                  _buildSectionTitle('Address'),
                  _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
                      displayValue(user?.address)),
                  _buildInfoRow(FontAwesomeIcons.flag, 'Region: ',
                      displayValue(user?.region)),
                  _buildInfoRow(FontAwesomeIcons.globe, 'Province: ',
                      displayValue(user?.province)),
                  _buildInfoRow(FontAwesomeIcons.city, 'City: ',
                      displayValue(user?.city)),
                  _buildInfoRow(FontAwesomeIcons.mapPin, 'Zip Code: ',
                      displayValue(user?.zipCode)),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[300]),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                      child: Text("Attendance",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                      child: ElevatedButton.icon(
                          onPressed: _selectStartDate,
                          icon: const FaIcon(FontAwesomeIcons.calendar,
                              color: Colors.black),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: Text(
                            DateFormat('yyyy-MM-dd').format(_startDate),
                            style: const TextStyle(color: Colors.black),
                          )),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 20, 0),
                      child: Icon(Icons.keyboard_arrow_right, size: 40),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 40, 0),
                      child: ElevatedButton.icon(
                          onPressed: _selectEndDate,
                          icon: const FaIcon(FontAwesomeIcons.calendar,
                              color: Colors.black),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.black),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: Text(
                            DateFormat('yyyy-MM-dd').format(_endDate),
                            style: const TextStyle(color: Colors.black),
                          )),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 50,
                      childAspectRatio: 4,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final days = [
                        _totalHoursWorked,
                        '---',
                        '',
                        '',
                      ];
                      final statuses = [
                        'Worked',
                        '---',
                        'CheckinButton',
                        'CheckoutButton'
                      ];

                      if (statuses[index] == 'CheckinButton') {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isViewingOwnProfile
                                ? const Color(0xFF00AEEF)
                                : Colors.grey[400]!,
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: isViewingOwnProfile
                              ? () => _handleCheckIn()
                              : null,
                          icon: const FaIcon(
                            FontAwesomeIcons.clock,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Clock in',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        );
                      } else if (statuses[index] == 'CheckoutButton') {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isViewingOwnProfile
                                ? Colors.red
                                : Colors.grey[400]!,
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: isViewingOwnProfile
                              ? () => _handleCheckOut()
                              : null,
                          icon: const FaIcon(
                            FontAwesomeIcons.clock,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Clock Out',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        );
                      } else {
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(days[index],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text(statuses[index],
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FutureBuilder(
                          future: isCurrentUserAdmin(),
                          builder: (context, snapshot) {
                            final isAdmin = snapshot.data ?? false;
                            return DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                  const Color(0xFF00AEEF)),
                              columns: <DataColumn>[
                                const DataColumn(
                                  label: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NunitoSans',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NunitoSans',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Check In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NunitoSans',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Check Out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NunitoSans',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (isAdmin)
                                  const DataColumn(
                                    label: Text(
                                      'Action',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'NunitoSans',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                              rows: _attendanceHistory.map((attendance) {
                                return DataRow(
                                  cells: <DataCell>[
                                    DataCell(Text(
                                        attendance['attendance_date'] ??
                                            'N/A')),
                                    DataCell(
                                        Text(attendance['status'] ?? 'N/A')),
                                    DataCell(Text(attendance['check_in_time'] !=
                                            null
                                        ? DateFormat('HH:mm:ss').format(
                                            DateTime.parse(
                                                attendance['check_in_time']))
                                        : 'N/A')),
                                    DataCell(Text(attendance[
                                                'check_out_time'] !=
                                            null
                                        ? DateFormat('HH:mm:ss').format(
                                            DateTime.parse(
                                                attendance['check_out_time']))
                                        : 'N/A')),
                                    if (isAdmin)
                                      DataCell(
                                        // Only show if admin
                                        SizedBox(
                                          width: 80,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _showEditAttendanceModal(
                                                    attendance),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            );
                          }),
                    ),
                  ),
                ),
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
                        onPressed: () async {
                          final result = await context.push('/payroll', extra: {
                            'account': user,
                            'employee': emp,
                          });

                          if (result != null && result is EmployeeData) {
                            setState(() {
                              emp = result;
                            });
                          }
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.fileInvoiceDollar,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Payslips',
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
                      if (Supabase.instance.client.auth.currentUser?.id ==
                          user?.userID)
                        const SizedBox(width: 12),
                      if (Supabase.instance.client.auth.currentUser?.id ==
                          user?.userID)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final updatedEmp = await context.push(
                              '/employeeList/profile/leaveRequest',
                              extra: {
                                'account': user,
                                'employee': emp,
                              },
                            );

                            if (updatedEmp != null &&
                                updatedEmp is EmployeeData) {
                              setState(() {
                                emp = updatedEmp;
                              });
                            }
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.suitcaseRolling,
                            color: Colors.white,
                          ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

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

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], indent: 40, endIndent: 40);
  }
}
