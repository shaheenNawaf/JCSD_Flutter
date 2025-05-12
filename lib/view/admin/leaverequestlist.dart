import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/backend/modules/employee/leave_request_provider.dart';
import 'package:jcsd_flutter/modals/confirm_leaverequest.dart';
import 'package:jcsd_flutter/modals/reject_leave_request.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class LeaveRequestList extends ConsumerStatefulWidget {
  const LeaveRequestList({super.key});

  @override
  ConsumerState<LeaveRequestList> createState() => _LeaveRequestListState();
}

class _LeaveRequestListState extends ConsumerState<LeaveRequestList> {
  int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchText = '';
  String _sortBy = 'startDate';
  bool _ascending = false;

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    final filtered = data.where((item) {
      final name =
          "${item['accounts']['firstName'] ?? ''} ${item['accounts']['lastName'] ?? ''}"
              .toLowerCase();
      final type = item['leaveType']?.toLowerCase() ?? '';
      final note = item['notes']?.toLowerCase() ?? '';
      final query = _searchText.toLowerCase();
      return name.contains(query) ||
          type.contains(query) ||
          note.contains(query);
    }).toList();

    filtered.sort((a, b) {
      dynamic aVal, bVal;

      if (_sortBy == 'accounts.firstName') {
        aVal =
            "${a['accounts']['firstName'] ?? ''} ${a['accounts']['lastName'] ?? ''}"
                .toLowerCase();
        bVal =
            "${b['accounts']['firstName'] ?? ''} ${b['accounts']['lastName'] ?? ''}"
                .toLowerCase();
      } else {
        aVal = a[_sortBy] ?? '';
        bVal = b[_sortBy] ?? '';
      }

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
                  title: 'Leave Request List',
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
                              vertical: 0,
                              horizontal: 16,
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            _searchText = value;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: leaveRequestsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => const Center(child: Text('Error: \$e')),
                      data: (allData) {
                        final filteredData = _applyFilters(allData);
                        final paginatedData = filteredData
                            .skip(_currentPage * _rowsPerPage)
                            .take(_rowsPerPage)
                            .toList();
                        return _buildDataTable(paginatedData);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                leaveRequestsAsync.hasValue
                    ? _buildPagination(_applyFilters(leaveRequestsAsync.value!))
                    : const SizedBox(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Map<String, dynamic>> data) {
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
                label: _buildSortableHeader('Name', 'accounts.firstName')),
            DataColumn(label: _buildSortableHeader('Leave Type', 'leaveType')),
            DataColumn(label: _buildSortableHeader('Duration', 'duration')),
            DataColumn(label: _buildSortableHeader('Date Range', 'startDate')),
            DataColumn(label: _buildSortableHeader('Status', 'status')),
            DataColumn(label: _buildHeaderText('Notes')),
            DataColumn(label: _buildHeaderText('Actions')),
          ],
          rows: data.map((item) {
            final acc = item['accounts'];
            final name = "${acc?['firstName'] ?? ''} ${acc?['lastName'] ?? ''}";
            final leaveType = item['leaveType'] ?? 'N/A';
            final duration = item['duration'] ?? 'N/A';
            final dateRange =
                "${item['startDate'] ?? ''} - ${item['endDate'] ?? ''}";
            final status = item['status'] ?? 'Pending';
            final statusColor = status == 'Approved'
                ? Colors.green
                : status == 'Rejected'
                    ? Colors.red
                    : Colors.grey;

            return DataRow(cells: [
              DataCell(Text(name)),
              DataCell(Text(leaveType)),
              DataCell(Text(duration)),
              DataCell(Text(dateRange)),
              DataCell(Text(status, style: TextStyle(color: statusColor))),
              DataCell(Text(item['notes'] ?? 'None')),
              DataCell(status == 'Pending'
                  ? Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showConfirm(item['leaveID']),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text('Approve',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showReject(item['leaveID']),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  : const SizedBox(height: 48)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortableHeader(String title, String column) {
    return InkWell(
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
  }

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

  void _showConfirm(String leaveID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmLeaveRequestModal(
        leaveID: leaveID,
        onSuccess: () => ref.invalidate(leaveRequestStreamProvider),
      ),
    );
  }

  void _showReject(String leaveID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RejectLeaveRequestModal(
        leaveID: leaveID,
        onSuccess: () => ref.invalidate(leaveRequestStreamProvider),
      ),
    );
  }
}
