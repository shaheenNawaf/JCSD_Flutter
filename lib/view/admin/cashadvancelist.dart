import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:jcsd_flutter/modals/generate_employee_payroll.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

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
  bool _ascending = false;

  final List<Map<String, dynamic>> _dummyPayrollData = List.generate(
      5,
      (index) => {
            'name': 'Employee $index',
            'position': 'Position $index',
            'paymentReceived': 'P${20000 + index * 100}',
            'monthlySalary': 'P${30000 + index * 100}',
            'calculatedSalary': 'P${25000 + index * 100}',
            'reason': 'Emergency fund',
          });

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    final query = _searchText.toLowerCase();
    final filtered = data.where((item) {
      return item['name'].toLowerCase().contains(query) ||
          item['position'].toLowerCase().contains(query);
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

  @override
  Widget build(BuildContext context) {
    final filteredData = _applyFilters(_dummyPayrollData);
    final paginatedData = filteredData
        .skip(_currentPage * _rowsPerPage)
        .take(_rowsPerPage)
        .toList();

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
                      const SizedBox(), // Placeholder to balance layout if needed
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildDataTable(paginatedData),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPagination(_applyFilters(_dummyPayrollData)),
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
            DataColumn(label: _buildSortableHeader('Position', 'position')),
            DataColumn(
                label: _buildSortableHeader(
                    'Payment Received', 'paymentReceived')),
            DataColumn(
                label: _buildSortableHeader('Monthly Salary', 'monthlySalary')),
            DataColumn(
                label:
                    _buildSortableHeader('Cash Advance', 'calculatedSalary')),
            DataColumn(label: _buildHeaderText('Reason')),
            DataColumn(label: _buildHeaderText('Action')),
          ],
          rows: data.map((item) {
            return DataRow(cells: [
              DataCell(Text(item['name'])),
              DataCell(Text(item['position'])),
              DataCell(Text(item['calculatedSalary'])),
              DataCell(Text(item['monthlySalary'])),
              DataCell(Text(item['paymentReceived'])),
              DataCell(Text(item['reason'])),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    // Navigate or open modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                  ),
                  child: const Text('View Details',
                      style: TextStyle(color: Colors.white)),
                ),
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
