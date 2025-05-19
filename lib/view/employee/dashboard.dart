// lib/view/employee/dashboard.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// API & Supabase
import 'package:jcsd_flutter/api/global_variables.dart';

// Backend Modules & Providers
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_providers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';

// UI Widgets
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

final dashboardCurrentEmployeeIntIDProvider =
    FutureProvider.autoDispose<int?>((ref) async {
  final loggedInUser = supabaseDB.auth.currentUser;
  if (loggedInUser == null) return null;
  try {
    final employeeRecord = await supabaseDB
        .from('employee')
        .select('employeeID')
        .eq('userID', loggedInUser.id)
        .maybeSingle();
    return employeeRecord?['employeeID'] as int?;
  } catch (e) {
    print("Error in dashboardCurrentEmployeeIntIDProvider: $e");
    return null;
  }
});

final dashboardRecentBookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final userRole = await ref.watch(userRoleProvider.future);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  if (userRole == 'employee') {
    final employeeId =
        await ref.watch(dashboardCurrentEmployeeIntIDProvider.future);
    if (employeeId != null) {
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
        itemsPerPage: 5,
      );
    } else {
      return [];
    }
  } else if (userRole == 'admin') {
    return bookingService.getBookings(
      statuses: [BookingStatus.pendingConfirmation],
      sortBy: 'created_at',
      ascending: false,
      itemsPerPage: 5,
    );
  } else {
    return [];
  }
});

final pendingBookingsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  return bookingService.getBookingsCount(
    statuses: [BookingStatus.pendingConfirmation],
  );
});

final confirmedBookingsTodayCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return bookingService.getBookingsCount(
    statuses: [BookingStatus.confirmed],
    dateFrom: todayStart,
    dateTo: todayEnd,
  );
});

final homeServicesTodayCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final bookings = await bookingService.getBookings(
    dateFrom: todayStart,
    dateTo: todayEnd,
    bookingTypes: BookingType.homeService,
    itemsPerPage: 1000,
  );
  return bookings.length;
});

final walkInsTodayCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final bookings = await bookingService.getBookings(
    dateFrom: todayStart,
    dateTo: todayEnd,
    bookingTypes: BookingType.walkIn,
    itemsPerPage: 1000,
  );
  return bookings.length;
});

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "Have a nice day!",
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromARGB(255, 82, 209, 255),
          ),
        ),
        Text(
          DateFormat('hh:mm:ss a').format(_currentTime),
          style: const TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Color(0xFF00AEEF),
          ),
        ),
        Text(
          DateFormat('EEE, MMM d, yyyy').format(_currentTime),
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
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
                const Header(title: 'Dashboard'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDashboardContent(ref),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingBookingsCountProvider);
    final confirmedTodayCountAsync =
        ref.watch(confirmedBookingsTodayCountProvider);
    final homeServicesTodayCountAsync =
        ref.watch(homeServicesTodayCountProvider);
    final walkInsTodayCountAsync = ref.watch(walkInsTodayCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Today\'s Overview',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            DigitalClock(),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            _buildStatsCardAsync(
              title: 'Pending Bookings',
              asyncValue: pendingCountAsync,
              iconData: Icons.pending_actions_outlined,
              iconColor: Colors.orange,
            ),
            _buildStatsCardAsync(
              title: 'Confirmed Today',
              asyncValue: confirmedTodayCountAsync,
              iconData: Icons.check_circle_outline,
              iconColor: Colors.blue,
            ),
            _buildStatsCardAsync(
              title: 'Home Services Today',
              asyncValue: homeServicesTodayCountAsync,
              iconData: Icons.home_work_outlined,
              iconColor: Colors.purple,
            ),
            _buildStatsCardAsync(
              title: 'Walk-Ins Today',
              asyncValue: walkInsTodayCountAsync,
              iconData: Icons.directions_walk_outlined,
              iconColor: Colors.teal,
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          'Low Stocks',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        _buildLowStocksTable(ref),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/bookings');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
              child: const Text('View All Bookings',
                  style: TextStyle(fontSize: 12, fontFamily: 'NunitoSans')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentBookingsTable(ref),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatsCardAsync({
    required String title,
    required AsyncValue<int> asyncValue,
    String percentageChange = "",
    required IconData iconData,
    required Color iconColor,
  }) {
    return SizedBox(
      width: 220,
      height: 110,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(iconData, color: iconColor.withOpacity(0.8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  asyncValue.when(
                    data: (count) => Text(
                      count.toString(),
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: iconColor,
                      ),
                    ),
                    loading: () => const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (e, s) => const Text("Err",
                        style: TextStyle(fontSize: 22, color: Colors.red)),
                  ),
                  if (percentageChange.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (percentageChange.startsWith('+')
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            percentageChange.startsWith('+')
                                ? FontAwesomeIcons.arrowUp
                                : FontAwesomeIcons.arrowDown,
                            color: percentageChange.startsWith('+')
                                ? Colors.green
                                : Colors.red,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            percentageChange,
                            style: TextStyle(
                              color: percentageChange.startsWith('+')
                                  ? Colors.green
                                  : Colors.red,
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStocksTable(WidgetRef ref) {
    final lowStockAsync = ref.watch(dashboardLowStockItemsProvider);

    return Container(
      width: double.infinity, // Ensure the outer container takes full width
      constraints: const BoxConstraints(minHeight: 150, maxHeight: 220),
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
      child: lowStockAsync.when(
        data: (lowStockItems) {
          if (lowStockItems.isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 48, color: Colors.green[400]),
                  const SizedBox(height: 12),
                  Text(
                    "All items are well-stocked!",
                    style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontSize: 16,
                        color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            // Allows horizontal scrolling for the DataTable
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              // Allows vertical scrolling for the content within DataTable
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFF00AEEF)),
                columnSpacing: 10,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(
                      label: Text("Item ID",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Item Name",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Type",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Supplier",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Qty",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans')),
                      numeric: true),
                  DataColumn(
                      label: Text("Price",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans')),
                      numeric: true),
                  DataColumn(
                      label: Text("Action",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                ],
                rows: lowStockItems.map((item) {
                  // ... (rest of the DataRow mapping logic remains the same)
                  final currentStock = item.serialsCount ?? 0;
                  final desiredStock = item.desiredStockLevel ?? 0;
                  final reorderQty = (desiredStock - currentStock) > 0
                      ? (desiredStock - currentStock)
                      : 1;
                  final itemTypeNameFuture = ref
                      .watch(itemTypesProvider)
                      .getTypeNameByID(item.itemTypeID);
                  final supplierNameFuture = item.preferredSupplierID != null
                      ? ref
                          .watch(suppliersServiceProvider)
                          .getSupplierNameByID(item.preferredSupplierID!)
                      : Future.value("N/A");

                  return DataRow(cells: [
                    DataCell(Text(
                        item.prodDefID?.substring(
                                0, min(6, item.prodDefID?.length ?? 0)) ??
                            'N/A',
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'NunitoSans'))),
                    DataCell(Tooltip(
                        message: item.prodDefName,
                        child: Text(item.prodDefName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontFamily: 'NunitoSans')))),
                    DataCell(FutureBuilder<String>(
                      future: itemTypeNameFuture,
                      builder: (context, snapshot) => Text(
                          snapshot.data ?? '...',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, fontFamily: 'NunitoSans')),
                    )),
                    DataCell(FutureBuilder<String>(
                      future: supplierNameFuture,
                      builder: (context, snapshot) => Text(
                          snapshot.data ?? '...',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, fontFamily: 'NunitoSans')),
                    )),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: currentStock < (desiredStock * 0.25)
                              ? Colors.redAccent
                              : Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text("$currentStock pcs",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'NunitoSans')),
                      ),
                    ),
                    DataCell(Text(
                        "₱${(item.prodDefMSRP ?? 0.0).toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'NunitoSans'))),
                    DataCell(ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final poService =
                            ref.read(purchaseOrderServiceProvider);
                        final currentAuthUser = supabaseDB.auth.currentUser;
                        int? employeeId;

                        if (currentAuthUser != null) {
                          try {
                            final empRecord = await supabaseDB
                                .from('employee')
                                .select('employeeID')
                                .eq('userID', currentAuthUser.id)
                                .maybeSingle();
                            employeeId = empRecord?['employeeID'] as int?;
                          } catch (e) {
                            print("Error fetching employee ID for PO: $e");
                          }
                        }

                        if (employeeId == null) {
                          ToastManager().showToast(
                              context,
                              "Could not identify creating employee.",
                              Colors.red);
                          return;
                        }
                        if (item.preferredSupplierID == null) {
                          ToastManager().showToast(
                              context,
                              "Product '${item.prodDefName}' has no preferred supplier.",
                              Colors.orange);
                          return;
                        }

                        final poItem = PurchaseOrderItemData(
                          purchaseOrderID: 0,
                          prodDefID: item.prodDefID!,
                          quantityOrdered: reorderQty,
                          unitCostPrice: item.prodDefMSRP ?? 0.0,
                          lineTotalCost: (item.prodDefMSRP ?? 0.0) * reorderQty,
                        );

                        try {
                          await poService.createPurchaseOrder(
                            supplierID: item.preferredSupplierID!,
                            createdByEmployee: employeeId,
                            orderDate: DateTime.now(),
                            items: [poItem],
                            note:
                                "Auto-generated PO for low stock: ${item.prodDefName}",
                          );
                          ToastManager().showToast(
                              context,
                              "Purchase Order created for ${item.prodDefName}",
                              Colors.green);
                          ref.invalidate(purchaseOrderListNotifierProvider);
                          ref.invalidate(dashboardLowStockItemsProvider);
                        } catch (e) {
                          ToastManager().showToast(
                              context,
                              "Failed to create PO: ${e.toString()}",
                              Colors.red);
                        }
                      },
                      child: const Text("Create PO",
                          style: TextStyle(
                              fontSize: 10, fontFamily: 'NunitoSans')),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator())),
        error: (err, stack) => Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error loading low stock items: $err",
                    style: const TextStyle(
                        fontFamily: 'NunitoSans', color: Colors.red)))),
      ),
    );
  }

  Widget _buildRecentBookingsTable(WidgetRef ref) {
    final recentBookingsAsync = ref.watch(dashboardRecentBookingsProvider);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 250),
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
      child: recentBookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No relevant bookings to display at the moment.",
                    style: TextStyle(fontFamily: 'NunitoSans')),
              ),
            );
          }
          final allServicesAsync = ref.watch(fetchAvailableServices);
          final serviceNameMap = allServicesAsync.asData?.value
                  ?.fold<Map<int, String>>(
                      {},
                      (map, service) =>
                          map..[service.serviceID] = service.serviceName) ??
              {};

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(const Color(0xFF00AEEF)),
                columnSpacing: 138,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(
                      label: Text("Booking ID",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Customer",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Date Time",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Service(s)",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Status",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                  DataColumn(
                      label: Text("Action",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'NunitoSans'))),
                ],
                rows: bookings.map((booking) {
                  final serviceDisplayNames = booking.bookingServices
                          ?.map((bs) =>
                              serviceNameMap[bs.serviceId] ??
                              "ID: ${bs.serviceId}")
                          .join(", ") ??
                      "N/A";
                  return DataRow(cells: [
                    DataCell(Text(booking.id.toString(),
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'NunitoSans'))),
                    DataCell(Text(
                        booking.walkInCustomerName ??
                            booking.customerUserId?.substring(0,
                                min(8, booking.customerUserId?.length ?? 0)) ??
                            'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'NunitoSans'))),
                    DataCell(Text(
                        DateFormat.yMd()
                            .add_jm()
                            .format(booking.scheduledStartTime),
                        style: const TextStyle(
                            fontSize: 11, fontFamily: 'NunitoSans'))),
                    DataCell(Tooltip(
                        message: serviceDisplayNames,
                        child: Text(serviceDisplayNames,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11, fontFamily: 'NunitoSans')))),
                    DataCell(_statusChip(booking.status)),
                    DataCell(ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 170, 71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () =>
                          context.go('/bookingDetail', extra: booking.id),
                      child: const Text("View",
                          style: TextStyle(
                              fontSize: 10, fontFamily: 'NunitoSans')),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
        loading: () => const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator())),
        error: (err, stack) => Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error loading recent bookings: $err",
                    style: const TextStyle(
                        fontFamily: 'NunitoSans', color: Colors.red)))),
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    Color chipColor;
    String chipText = status.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .toUpperCase();
    switch (status) {
      case BookingStatus.pendingConfirmation:
        chipColor = Colors.orange.shade700;
        break;
      case BookingStatus.confirmed:
        chipColor = Colors.blue.shade700;
        break;
      case BookingStatus.inProgress:
        chipColor = Colors.cyan.shade700;
        break;
      case BookingStatus.completed:
        chipColor = Colors.green.shade700;
        break;
      case BookingStatus.cancelled:
        chipColor = Colors.red.shade700;
        break;
      case BookingStatus.noShow:
        chipColor = Colors.grey.shade700;
        break;
      case BookingStatus.pendingAdminApproval:
        chipColor = Colors.purple.shade700;
        break;
      case BookingStatus.pendingPayment:
        chipColor = Colors.amber.shade800;
        break;
      default:
        chipColor = Colors.black54;
    }
    return Chip(
      label: Text(chipText,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'NunitoSans')),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
