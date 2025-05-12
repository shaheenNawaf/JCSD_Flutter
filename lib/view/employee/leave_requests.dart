// ignore_for_file: library_private_types_in_public_api, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';
import 'package:jcsd_flutter/backend/modules/employee/leave_request_provider.dart';
import 'package:jcsd_flutter/modals/add_leave_request.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class LeaveRequest extends ConsumerStatefulWidget {
  final AccountsData? acc;
  final EmployeeData? emp;

  const LeaveRequest({super.key, this.acc, this.emp});

  @override
  ConsumerState<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends ConsumerState<LeaveRequest> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchText = '';
  String _sortBy = 'startDate';
  bool _ascending = false;
  late final AccountsData? user = widget.acc;
  late final EmployeeData? emp = widget.emp;

  void _showAddLeaveModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LeaveRequestForm(),
    );
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    final filtered =
        data.where((r) => r['userID'] == user?.userID).where((item) {
      final type = item['leaveType']?.toLowerCase() ?? '';
      final note = item['notes']?.toLowerCase() ?? '';
      final query = _searchText.toLowerCase();
      return type.contains(query) || note.contains(query);
    }).toList();

    filtered.sort((a, b) {
      final aVal = a[_sortBy] ?? '';
      final bVal = b[_sortBy] ?? '';
      return _ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });

    return filtered;
  }

  void _sort(String column) {
    setState(() {
      if (_sortBy == column) {
        _ascending = !_ascending;
      } else {
        _sortBy = column;
        _ascending = true;
      }
    });
  }

  String _display(dynamic v) =>
      (v == null || (v is String && v.trim().isEmpty)) ? 'N/A' : v.toString();

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildProfile() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildSectionTitle('Basic Information'),
            _buildInfoRow(
                FontAwesomeIcons.envelope, 'Email: ', _display(user?.email)),
            _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ',
                _display(user?.contactNumber)),
            _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ',
                _formatDate(user?.birthDate)),
            _buildDivider(),
            _buildSectionTitle('Address'),
            _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
                _display(user?.address)),
            _buildInfoRow(
                FontAwesomeIcons.flag, 'Region: ', _display(user?.region)),
            _buildInfoRow(
                FontAwesomeIcons.globe, 'Province: ', _display(user?.province)),
            _buildInfoRow(
                FontAwesomeIcons.city, 'City: ', _display(user?.city)),
            _buildInfoRow(
                FontAwesomeIcons.mapPin, 'Zip Code: ', _display(user?.zipCode)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> data) => Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 350,
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
                          vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) => setState(() {
                      _searchText = value;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFF00AEEF)),
                  columns: [
                    DataColumn(
                        label: _buildSortableHeader('Leave Type', 'leaveType')),
                    DataColumn(
                        label: _buildSortableHeader('Duration', 'duration')),
                    DataColumn(
                        label: _buildSortableHeader('Date Range', 'startDate')),
                    DataColumn(label: _buildSortableHeader('Status', 'status')),
                    DataColumn(label: _buildHeaderText('Notes')),
                  ],
                  rows: data.map((req) {
                    final status = req['status'] ?? 'Pending';
                    final statusColor = status == 'Approved'
                        ? Colors.green
                        : status == 'Rejected'
                            ? Colors.red
                            : Colors.grey;
                    return DataRow(cells: [
                      DataCell(Text(req['leaveType'] ?? 'N/A')),
                      DataCell(Text(req['duration'] ?? 'N/A')),
                      DataCell(Text(
                          '${req['startDate'] ?? ''} - ${req['endDate'] ?? ''}')),
                      DataCell(
                          Text(status, style: TextStyle(color: statusColor))),
                      DataCell(Text(req['notes'] ?? 'None')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildPagination(
              _applyFilters(ref.watch(leaveRequestStreamProvider).value ?? [])),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 40, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddLeaveModal,
                  icon: const FaIcon(
                    FontAwesomeIcons.suitcaseRolling,
                    color: Colors.white,
                  ),
                  label: const Text('Request for Leave'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildSortableHeader(String title, String column) => InkWell(
        onTap: () => _sort(column),
        child: Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.white)),
            if (_sortBy == column)
              Icon(_ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 18, color: Colors.white),
          ],
        ),
      );

  Widget _buildHeaderText(String title) =>
      Text(title, style: const TextStyle(color: Colors.white));

  Widget _buildPagination(List<Map<String, dynamic>> filteredData) {
    final totalPages = (filteredData.length / _rowsPerPage).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage = 0) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage--) : null,
        ),
        Text('Page ${_currentPage + 1} of $totalPages'),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage = totalPages - 1)
              : null,
        ),
      ],
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

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildDivider() =>
      Divider(color: Colors.grey[300], indent: 40, endIndent: 40);

  @override
  Widget build(BuildContext context) {
    final leaveRequestsAsync = ref.watch(leaveRequestStreamProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/employeeList'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Leave Requests',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
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
                          _buildProfile(),
                          VerticalDivider(width: 1, color: Colors.grey[300]),
                          Expanded(
                            child: leaveRequestsAsync.when(
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (e, _) => Center(child: Text('Error: $e')),
                              data: (data) {
                                final filtered = _applyFilters(data);
                                final paged = filtered
                                    .skip(_currentPage * _rowsPerPage)
                                    .take(_rowsPerPage)
                                    .toList();
                                return _buildTable(paged);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
