// lib/view/bookings/bookings.dart
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Base Imports
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart'; // For Booking type
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_notifier.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_state.dart';

//UI Imports
import 'package:shimmer/shimmer.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  final String _activeSubItem = '/bookings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingListStateAsync = ref.watch(bookingListNotifierProvider);
    final bookingListNotifier = ref.read(bookingListNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Bookings Management'),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: bookingListStateAsync.when(
                      data: (state) =>
                          _buildWebView(context, state, bookingListNotifier),
                      loading: () => _buildLoadingIndicator(),
                      error: (err, stack) => _buildErrorView(err, stack, ref),
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

  Widget _buildWebView(BuildContext context, BookingListState state,
      BookingListNotifier notifier) {
    return Column(
      children: [
        _buildTopControls(context, state, notifier),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTable(context, state, notifier),
        ),
        if (state.totalPages > 1) ...[
          const SizedBox(height: 16),
          _buildPaginationControls(state, notifier),
        ]
      ],
    );
  }

  Widget _buildTopControls(BuildContext context, BookingListState state,
      BookingListNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 200,
          height: 40,
          child: DropdownButtonFormField<BookingStatus?>(
            value: state.statusFilter?.isNotEmpty == true
                ? state.statusFilter!.first
                : null,
            hint:
                const Text('Filter by Status', style: TextStyle(fontSize: 13)),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              suffixIcon: state.statusFilter != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () =>
                          notifier.applyFilters(clearStatuses: true),
                      tooltip: "Clear filter",
                    )
                  : null,
            ),
            isExpanded: true,
            items: [
              const DropdownMenuItem<BookingStatus?>(
                value: null, // Represents "All"
                child: Text('All Statuses',
                    style:
                        TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ),
              ...BookingStatus.values
                  .where((s) => s != BookingStatus.unknown) // Exclude 'unknown'
                  .map((BookingStatus status) {
                return DropdownMenuItem<BookingStatus?>(
                  value: status,
                  child: Text(
                      status.name
                          .replaceAllMapped(
                              RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                          .trim(),
                      style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
            ],
            onChanged: (BookingStatus? newValue) {
              notifier.applyFilters(
                  statuses: newValue != null ? [newValue] : null,
                  clearStatuses: newValue == null);
            },
          ),
        ),
        // TODO: Add Date Range Filter if needed later

        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search ID, Customer, Notes...',
              hintStyle: const TextStyle(
                  color: Color(0xFFABABAB),
                  fontFamily: 'NunitoSans',
                  fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            ),
            onChanged: (value) {
              notifier.applyFilters(searchText: value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, BookingListState state,
      BookingListNotifier notifier) {
    if (state.bookings.isEmpty) {
      return Center(
        child: Text(
          state.searchText.isNotEmpty || state.statusFilter?.isNotEmpty == true
              ? 'No bookings match your current filters.'
              : 'There are no bookings to display.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
          columnSpacing: 20,
          columns: [
            _buildSortableHeader('ID', 'id', state, notifier),
            _buildSortableHeader(
                'Customer', 'walk_in_customer_name', state, notifier),
            _buildSortableHeader(
                'Scheduled At', 'scheduled_start_time', state, notifier),
            DataColumn(
                label: _buildHeaderText(
                    'Services')), // Not easily sortable directly
            _buildSortableHeader('Type', 'booking_type', state, notifier),
            _buildSortableHeader('Status', 'status', state, notifier),
            DataColumn(label: _buildHeaderText('Action', center: true)),
          ],
          rows: state.bookings.map((booking) {
            return _buildDataRow(context, booking);
          }).toList(),
        ),
      ),
    );
  }

  DataColumn _buildSortableHeader(String title, String columnKey,
      BookingListState state, BookingListNotifier notifier) {
    return DataColumn(
      label: InkWell(
        onTap: () => notifier.sort(columnKey),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderText(title),
            if (state.sortBy == columnKey)
              Icon(
                state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String text, {bool center = false}) {
    return Text(
      text,
      style: const TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 13),
      textAlign: center ? TextAlign.center : TextAlign.start,
    );
  }

  DataRow _buildDataRow(BuildContext context, Booking booking) {
    String customerDisplay = booking.walkInCustomerName ??
        booking.customerUserId?.substring(0, 8) ??
        'N/A';
    // Concatenate service names (assuming booking.bookingServices is populated)
    String serviceNames = booking.bookingServices
            ?.map((bs) =>
                bs.serviceId.toString() /* Replace with actual name lookup */)
            .join(', ') ??
        'N/A';
    // TODO: Replace bs.serviceId.toString() with actual service name lookup if available in BookingServiceItem or via a map

    return DataRow(
      cells: [
        DataCell(
            Text(booking.id.toString(), style: const TextStyle(fontSize: 13))),
        DataCell(Text(customerDisplay, style: const TextStyle(fontSize: 13))),
        DataCell(Text(
            DateFormat.yMd().add_jm().format(booking.scheduledStartTime),
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          serviceNames,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )),
        DataCell(Text(booking.bookingType.name,
            style: const TextStyle(fontSize: 13))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(booking.status).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            booking.status.name
                .replaceAllMapped(
                    RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
                .trim(),
            style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(booking.status),
                fontWeight: FontWeight.w500),
          ),
        )),
        DataCell(
          ElevatedButton(
            onPressed: () {
              context.go('/bookingDetail', extra: booking.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00AEEF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontSize: 12)),
            child: const Text('View Details',
                style:
                    TextStyle(fontFamily: 'NunitoSans', color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendingConfirmation:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.cyan;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.grey;
      case BookingStatus.pendingAdminApproval:
        return Colors.purple;
      case BookingStatus.pendingPayment:
        return Colors.amber;
      default:
        return Colors.black54;
    }
  }

  Widget _buildPaginationControls(
      BookingListState state, BookingListNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          tooltip: 'First Page',
          onPressed: state.currentPage > 1 ? () => notifier.goToPage(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.navigate_before),
          tooltip: 'Previous Page',
          onPressed: state.currentPage > 1
              ? () => notifier.goToPage(state.currentPage - 1)
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Page ${state.currentPage} of ${state.totalPages}',
              style: const TextStyle(fontSize: 14)),
        ),
        IconButton(
          icon: const Icon(Icons.navigate_next),
          tooltip: 'Next Page',
          onPressed: state.currentPage < state.totalPages
              ? () => notifier.goToPage(state.currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          tooltip: 'Last Page',
          onPressed: state.currentPage < state.totalPages
              ? () => notifier.goToPage(state.totalPages)
              : null,
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Shimmer for top controls
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    height: 40,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8))),
                Container(
                    height: 40,
                    width: 300,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Shimmer for table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  // Shimmer for table header
                  Container(
                    height: 48, // Approx header height
                    color: Colors.blueGrey[200], // Placeholder for header color
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(
                          7,
                          (_) => Expanded(
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 10),
                                  color: Colors.white))),
                    ),
                  ),
                  const Divider(height: 1),
                  // Shimmer for table rows
                  Expanded(
                    child: ListView.builder(
                      itemCount: 8, // Number of shimmer rows
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Row(
                          children: List.generate(
                              7,
                              (_) => Expanded(
                                  child: Container(
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      color: Colors.white))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Shimmer for pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (_) => Container(
                    height: 36,
                    width: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle))),
          )
        ],
      ),
    );
  }

  Widget _buildErrorView(Object error, StackTrace? stack, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error loading bookings: $error',
                textAlign: TextAlign.center),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: () => ref.invalidate(bookingListNotifierProvider),
          ),
        ],
      ),
    );
  }
}
