// lib/view/bookings/modals/receipt.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_service_item.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';

// PDF generation can be added later
// import 'package:pdf/widgets.dart' as pw;

// Placeholder for PDF generation
Future<void> generatePdfReceipt(Booking booking) async {
  // final pdf = pw.Document();
  // ... PDF generation logic ...
  print(
      "PDF generation for booking ${booking.id} requested (not implemented).");
  // For now, this is a placeholder.
}

class ReceiptModal extends ConsumerWidget {
  final Booking booking;

  const ReceiptModal({super.key, required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 800 ? 700 : screenWidth * 0.9;
    double dialogHeight = MediaQuery.of(context).size.height * 0.85;

    final allServicesAsync = ref.watch(fetchAvailableServices);
    final allProductDefinitionsAsync = ref.watch(
        productDefinitionNotifierProvider(true)); // Assuming true for active

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Booking Receipt',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ReceiptCompanyDetails(),
                    const SizedBox(height: 15),
                    _ReceiptBookingDetails(booking: booking),
                    const SizedBox(height: 20),
                    allServicesAsync.when(
                      data: (serviceList) {
                        final serviceMap = {
                          for (var s in serviceList) s.serviceID: s.serviceName
                        };
                        return allProductDefinitionsAsync.when(
                            data: (pdState) {
                              final Map<String, String> pdMap = {
                                for (var pd in pdState.productDefinitions)
                                  if (pd.prodDefID != null)
                                    pd.prodDefID!: pd.prodDefName
                              };

                              return _ReceiptTable(
                                bookingServices: booking.bookingServices ?? [],
                                bookingItems: booking.bookingItems ?? [],
                                serviceNameMap: serviceMap,
                                productNameMap: pdMap,
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (e, s) =>
                                Text("Error loading product names: $e"));
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text("Error loading service names: $e"),
                    ),
                    const SizedBox(height: 10),
                    _SummaryTable(booking: booking),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => generatePdfReceipt(booking),
                  icon: const Icon(Icons.print),
                  label: const Text('Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(
                        fontFamily: 'NunitoSans', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCompanyDetails extends StatelessWidget {
  final String companyName = "JCSD Computer Shop";
  final String addressLine1 = "Purok 4 Block 3, Panacan Relocation";
  final String addressLine2 = "8000 Davao City, Philippines";
  final String contactNumber = "0976 074 7797";

  const _ReceiptCompanyDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(companyName,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'NunitoSans')),
        Text(addressLine1,
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
        Text(addressLine2,
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
        Text(contactNumber,
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
      ],
    );
  }
}

class _ReceiptBookingDetails extends StatelessWidget {
  final Booking booking;
  const _ReceiptBookingDetails({required this.booking});

  @override
  Widget build(BuildContext context) {
    String customerName = booking.walkInCustomerName ?? "N/A";
    if (customerName == "N/A" && booking.customerUserId != null) {
      customerName =
          "Customer ID: ${booking.customerUserId!.length > 8 ? booking.customerUserId!.substring(0, 8) : booking.customerUserId}...";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Invoice ID: ${booking.uuid.length > 12 ? booking.uuid.substring(0, 12) : booking.uuid}...',
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
        Text('Booking ID: ${booking.id}',
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
        Text(
            'Date: ${DateFormat.yMMMd().add_jm().format(booking.scheduledStartTime)}',
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
        Text('Customer: $customerName',
            style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
        if (booking.bookingType == BookingType.homeService &&
            booking.customerNotes != null &&
            booking.customerNotes!.contains("Address:"))
          Text(
              'Service Address: ${booking.customerNotes!.split("Address:").last.split("\n").first.trim()}',
              style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans')),
      ],
    );
  }
}

class _ReceiptTable extends StatelessWidget {
  final List<BookingServiceItem> bookingServices;
  final List<BookingItem> bookingItems;
  final Map<int, String> serviceNameMap;
  final Map<String, String> productNameMap; // Expects Map<String, String>

  const _ReceiptTable({
    required this.bookingServices,
    required this.bookingItems,
    required this.serviceNameMap,
    required this.productNameMap,
  });

  @override
  Widget build(BuildContext context) {
    final List<DataRow> rows = [];
    int itemCounter = 1;

    for (var serviceItem in bookingServices) {
      rows.add(DataRow(cells: [
        DataCell(Text(itemCounter.toString())),
        DataCell(Text(serviceNameMap[serviceItem.serviceId] ??
            'Service ID: ${serviceItem.serviceId}')),
        const DataCell(Text('1', textAlign: TextAlign.center)),
        DataCell(Text(
            '₱${(serviceItem.finalPrice ?? serviceItem.estimatedPrice).toStringAsFixed(2)}',
            textAlign: TextAlign.right)),
      ]));
      itemCounter++;
    }

    for (var bookingItem in bookingItems) {
      // Assuming BookingItem has a 'prodDefID' (String?) field.
      // If bookingItem.prodDefID is null, productNameMap[null] will result in null,
      // then the fallback 'Serial: ${bookingItem.serialNumber}' will be used.
      String itemNameDisplay = (bookingItem.serialNumber != null
              ? productNameMap[bookingItem.serialNumber!]
              : null) ??
          'Item: ${bookingItem.serialNumber}';

      rows.add(DataRow(cells: [
        DataCell(Text(itemCounter.toString())),
        DataCell(Text(itemNameDisplay)),
        const DataCell(Text('1', textAlign: TextAlign.center)),
        DataCell(Text('₱${bookingItem.priceAtAddition.toStringAsFixed(2)}',
            textAlign: TextAlign.right)),
      ]));
      itemCounter++;
    }

    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text("No services or items in this booking.")),
      );
    }

    return DataTable(
      columnSpacing: 10,
      headingRowHeight: 35,
      dataRowMinHeight: 30,
      dataRowMaxHeight: 40,
      columns: const [
        DataColumn(
            label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true),
        DataColumn(
            label:
                Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true),
      ],
      rows: rows,
    );
  }
}

class _SummaryTable extends StatelessWidget {
  final Booking booking;
  const _SummaryTable({required this.booking});

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    booking.bookingServices
        ?.forEach((s) => subtotal += (s.finalPrice ?? s.estimatedPrice));
    booking.bookingItems?.forEach((i) => subtotal += i.priceAtAddition);

    double tax = 0.00;
    double otherCharges = 0.00;
    double total = booking.finalTotalPrice ?? (subtotal + tax + otherCharges);

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSummaryRow('Subtotal:', '₱${subtotal.toStringAsFixed(2)}'),
          if (tax > 0) _buildSummaryRow('Tax:', '₱${tax.toStringAsFixed(2)}'),
          if (otherCharges > 0)
            _buildSummaryRow(
                'Other Charges:', '₱${otherCharges.toStringAsFixed(2)}'),
          const Divider(thickness: 1.5),
          _buildSummaryRow('Total Amount:', '₱${total.toStringAsFixed(2)}',
              isBold: true),
          const SizedBox(height: 10),
          Text(
            'Status: ${booking.isPaid ? "Paid" : "Pending Payment"}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: booking.isPaid ? Colors.green : Colors.orangeAccent,
                fontFamily: 'NunitoSans'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'NunitoSans')),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'NunitoSans')),
        ],
      ),
    );
  }
}
