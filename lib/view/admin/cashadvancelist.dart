import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/modals/reject_cash_advance.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/modals/confirm_cash_advance.dart';
import 'package:jcsd_flutter/backend/modules/employee/cash_advance_provider.dart';

class CashAdvanceList extends ConsumerStatefulWidget {
  const CashAdvanceList({super.key});

  @override
  ConsumerState<CashAdvanceList> createState() => _CashAdvanceListState();
}

class _CashAdvanceListState extends ConsumerState<CashAdvanceList> {
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  String _searchText = '';
  String _sortBy = 'name';
  bool _ascending = true;

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    final query = _searchText.toLowerCase();
    final filtered = data.where((item) {
      return item['name'].toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      final aVal = a[_sortBy] ?? '';
      final bVal = b[_sortBy] ?? '';
      return _ascending
          ? aVal.toString().compareTo(bVal.toString())
          : bVal.toString().compareTo(aVal.toString());
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
    final dataAsync = ref.watch(cashAdvanceStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/employeeList'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Cash Advance List',
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
                              onChanged: (value) => setState(() {
                                _searchText = value;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                dataAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (err, _) => Text('Error: $err'),
                  data: (rows) {
                    final filteredData = _applyFilters(rows);
                    final paginatedData = filteredData
                        .skip(_currentPage * _rowsPerPage)
                        .take(_rowsPerPage)
                        .toList();

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildDataTable(paginatedData),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Consumer(builder: (context, ref, _) {
                  final allData =
                      ref.watch(cashAdvanceStreamProvider).value ?? [];
                  return _buildPagination(_applyFilters(allData));
                }),
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
            DataColumn(label: _buildSortableHeader('Employee Name', 'name')),
            DataColumn(
                label: _buildSortableHeader(
                    'Payment Received', 'paymentReceived')),
            DataColumn(
                label: _buildSortableHeader('Monthly Salary', 'monthlySalary')),
            DataColumn(
                label: _buildSortableHeader('Cash Advance', 'cashAdvance')),
            DataColumn(label: _buildHeaderText('Reason')),
            DataColumn(label: _buildHeaderText('Status')),
            DataColumn(label: _buildHeaderText('Actions')),
          ],
          rows: data.map((item) {
            final status = item['status'] ?? 'Pending';
            final statusColor = status == 'Approved'
                ? Colors.green
                : status == 'Rejected'
                    ? Colors.red
                    : Colors.grey;

            // Safely get cashAdvance as a number:
            double cashAdvanceValue = 0;
            if (item['cashAdvance'] != null) {
              if (item['cashAdvance'] is num) {
                cashAdvanceValue = item['cashAdvance'].toDouble();
              } else if (item['cashAdvance'] is String) {
                cashAdvanceValue = double.tryParse(item['cashAdvance']
                        .toString()
                        .replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0;
              }
            }

            // Safely get monthlySalary as a number:
            double monthlySalaryValue = 0;
            if (item['monthlySalary'] != null) {
              if (item['monthlySalary'] is num) {
                monthlySalaryValue = item['monthlySalary'].toDouble();
              } else if (item['monthlySalary'] is String) {
                monthlySalaryValue = double.tryParse(item['monthlySalary']
                        .toString()
                        .replaceAll(RegExp(r'[^0-9.]'), '')) ??
                    0;
              }
            }

            return DataRow(cells: [
              DataCell(Text(item['name'] ?? '')),

              // CASH ADVANCE FORMATTED
              DataCell(
                Text(
                    '₱${NumberFormat("#,##0.00", "en_US").format(cashAdvanceValue)}'),
              ),

              // MONTHLY SALARY FORMATTED
              DataCell(
                Text(
                    '₱${NumberFormat("#,##0.00", "en_US").format(monthlySalaryValue)}'),
              ),

              // CREATED AT (leave this alone)
              DataCell(
                Text(item['created_at'] != null
                    ? DateFormat.yMMMMd()
                        .format(DateTime.parse(item['created_at']))
                    : 'N/A'),
              ),

              // REASON
              DataCell(Text(item['reason'] ?? '')),

              // STATUS
              DataCell(Text(status, style: TextStyle(color: statusColor))),

              // ACTIONS
              DataCell(
                item['status'] == 'Pending'
                    ? Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ConfirmCashAdvanceModal(
                                  id: item['id'],
                                  onSuccess: () => setState(() {}),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: const Text('Approve',
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => RejectCashAdvanceModal(
                                  id: item['id'],
                                  onSuccess: () => setState(() {}),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Reject',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    : const SizedBox(height: 48),
              ),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'NunitoSans',
            ),
          ),
          if (_sortBy == column)
            Icon(
              _ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 18,
              color: Colors.white,
            ),
        ],
      ),
    );
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
}
