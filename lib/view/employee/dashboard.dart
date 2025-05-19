// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Default Imports
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_attendance.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

//Supabase / Generic Backend
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart'; // For AccountsData
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';

//Backend Imports (Bookings and Accounts)
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart'; // For service names
import 'package:jcsd_flutter/view/bookings/booking_detail.dart';

//Providers/Services to fetch information -- only specific for this page

//Fetching Current Employee
final currentEmployeeIDProvider = FutureProvider.autoDispose<int?>((ref) async {
  final loggedInEmployee = supabaseDB.auth.currentUser;
  if (loggedInEmployee == null) {
    print(
        'At Current Employee ID Provider: No authneticated user is logged in');
    return null;
  }

  try {
    final employeeID = await supabaseDB
        .from('employee')
        .select('employeeID')
        .eq('userID', loggedInEmployee.id)
        .maybeSingle();

    if (employeeID != null && employeeID['employeeID'] != null) {
      print(
          "[currentEmployeeIdProvider] Fetched employeeID: ${employeeID['employeeID']}");
      return employeeID['employeeID'] as int;
    }
    print(
        'No employee record found for userID: ${supabaseDB.auth.currentUser?.id}');
    return null;
  } catch (err, sty) {
    print('Error fetching the Employee ID \n Error: $err \n $sty');
    return null;
  }
});

//Fetching the bookings assigned for the employee today
final todaysBookingsForEmployeeProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final employeeIdAsyncValue = ref.watch(currentEmployeeIDProvider);

  return employeeIdAsyncValue.when(
    data: (employeeId) {
      if (employeeId == null) {
        print(
            "[todaysBookingsForEmployeeProvider] Employee ID is null, returning empty list.");
        return Future.value([]);
      }

      final bookingService = ref.watch(bookingServiceProvider);
      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day); // Start of today
      final todayEnd =
          DateTime(now.year, now.month, now.day, 23, 59, 59); // End of today

      print(
          "[todaysBookingsForEmployeeProvider] Fetching for employeeID: $employeeId, Date: $todayStart to $todayEnd");
      return bookingService.getBookings(
        assignedEmployeeId: employeeId,
        dateFrom: todayStart,
        dateTo: todayEnd,
        statuses: [
          BookingStatus.confirmed,
          BookingStatus.inProgress,
          BookingStatus.pendingCustomerResponse,
          BookingStatus.pendingParts,
        ],
        sortBy: 'scheduled_start_time',
        ascending: true,
        itemsPerPage: 50, // Fetch a reasonable number for "today"
      );
    },
    loading: () {
      print("[todaysBookingsForEmployeeProvider] Waiting for employee ID...");
      return Future.value([]); // Return empty list while employeeId is loading
    },
    error: (err, stack) {
      print(
          "[todaysBookingsForEmployeeProvider] Error fetching employee ID: $err. Returning empty list.");
      return Future.value([]);
    },
  );
});

//For the Low-Stock Notifications -- to be updated
final lowStockProductsProvider =
    FutureProvider.autoDispose<List<ProductDefinitionData>>((ref) async {
  try {
    final pdState = await ref.watch(
        productDefinitionNotifierProvider(true).future); // true for active
    // Placeholder: Actual low stock logic needed. This just takes a few.
    // You would filter based on actual stock levels if that data is available.
    print(
        "[lowStockProductsProvider] Product definitions fetched: ${pdState.productDefinitions.length}");
    return pdState.productDefinitions
        .take(3)
        .toList(); // Example: show first 3 as "low stock"
  } catch (e) {
    print("[lowStockProductsProvider] Error fetching product definitions: $e");
    return [];
  }
});

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/dashboard'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Dashboard',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDashboardContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bookings Report',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            ElevatedButton.icon(
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
              icon:
                  const FaIcon(FontAwesomeIcons.calendar, color: Colors.black),
              label: Text(
                '${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildBookingsReportChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildStatsCard(
                        'Profit',
                        '₱252,000',
                        '+25.5%',
                        Colors.green,
                        backgroundColor: const Color(0xFFE6F7E6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: _buildStatsCard(
                        'Pending Bookings',
                        '5',
                        '',
                        Colors.orange,
                        backgroundColor: const Color(0xFFFFF4E6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Low Stocks',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        _buildLowStocksTable(),
        const SizedBox(height: 12),
        const Text(
          'Recent Bookings',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        _buildRecentBookingsTable(),
      ],
    );
  }

  Widget _buildBookingsReportChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 8,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Confirmed';
                      break;
                    case 1:
                      text = 'Unconfirmed';
                      break;
                    case 2:
                      text = 'Done';
                      break;
                    case 3:
                      text = 'Replacement';
                      break;
                    case 4:
                      text = 'Pending';
                      break;
                    default:
                      text = '';
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(text, style: style),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: 80,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.lightBlueAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: 60,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.lightBlueAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: 70,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.lightBlueAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: 50,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.lightBlueAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: 70,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.lightBlueAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                )
              ],
              showingTooltipIndicators: [0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
      String title, String value, String percentage, Color color,
      {required Color backgroundColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: color,
                ),
              ),
            ],
          ),
          if (percentage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    percentage.contains('+')
                        ? FontAwesomeIcons.arrowUp
                        : FontAwesomeIcons.arrowDown,
                    color: color,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    percentage,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLowStocksTable() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF00AEEF)),
            columns: const [
              DataColumn(label: Text("Item ID")),
              DataColumn(label: Text("Item Name")),
              DataColumn(label: Text("Item Type")),
              DataColumn(label: Text("Supplier")),
              DataColumn(label: Text("Quantity")),
              DataColumn(label: Text("Price")),
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text("2")),
                const DataCell(Text("Mechanical Keyboard Ga light light")),
                const DataCell(Text("Accessories")),
                const DataCell(Text("Digital Center Enterprises")),
                DataCell(Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "1 pcs",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
                const DataCell(Text("₱1,000,000")),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsTable() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFF00AEEF)),
            columns: const [
              DataColumn(label: Text("Booking ID")),
              DataColumn(label: Text("Customer Name")),
              DataColumn(label: Text("Date Time")),
              DataColumn(label: Text("Service Type/s")),
              DataColumn(label: Text("Service Location")),
              DataColumn(label: Text("Contact Info")),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text("000001")),
                DataCell(Text("Shaheen Al Adwani")),
                DataCell(Text("01/12/2024 10:00 AM")),
                DataCell(Text("Computer Repair")),
                DataCell(Text("In-Store Service")),
                DataCell(Text("09088184444")),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
