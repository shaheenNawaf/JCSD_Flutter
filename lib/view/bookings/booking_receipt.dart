// ignore_for_file: unused_element

// import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:jcsd_flutter/widgets/header.dart';

class BookingReceipt extends StatefulWidget {
  const BookingReceipt({super.key});

  @override
  _BookingReceiptState createState() => _BookingReceiptState();
}

Future<void> generatePdfReceipt() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Align(
        alignment: pw.Alignment.topLeft,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Booking ID : 01624395345",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("Invoice ID : 01624395345",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("Purok 4 Block 3", style: const pw.TextStyle(fontSize: 15)),
            pw.Text("Panacan Relocation",
                style: const pw.TextStyle(fontSize: 15)),
            pw.Text("8000 Davao City, Philippines",
                style: const pw.TextStyle(fontSize: 15)),
            pw.Text("0976 074 7797", style: const pw.TextStyle(fontSize: 15)),
            pw.Text("JCSD", style: const pw.TextStyle(fontSize: 15)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              context: context,
              cellHeight: 20,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headers: <String>['Item', 'Description', 'Quantity', 'Amount'],
              data: <List<String>>[
                <String>['1', 'Service Charge', '3', 'P400'],
                <String>['2', 'Service Charge', '3', 'P400'],
                <String>['3', 'Service Charge', '3', 'P400'],
                <String>['4', 'Service Charge', '3', 'P400'],
                <String>['5', 'Service Charge', '3', 'P400'],
                <String>['6', 'Service Charge', '3', 'P400'],
                <String>['7', 'Service Charge', '3', 'P400'],
                <String>['8', 'Service Charge', '3', 'P400'],
                <String>['9', 'Service Charge', '3', 'P400'],
                <String>['10', 'Service Charge', '3', 'P400'],
                <String>['', '', 'Subtotal', 'P2,000'],
                <String>['', '', 'Tax', 'P1,000'],
                <String>['', '', 'Other', 'P1,000'],
                <String>['', '', 'Total', 'P5,000'],
              ],
            ),
          ],
        ),
      ),
    ),
  );
  //Add PDF Generator Function
}

class _BookingReceiptState extends State<BookingReceipt> {
  final String _activeSubItem = '/bookings';

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
                  title: 'Booking Receipt',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: _WebView(),
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

class _WebView extends StatelessWidget {
  const _WebView();

  @override
  Widget build(BuildContext context) {
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
      child: Scrollbar(
        thumbVisibility: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Receipt',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 20),
              const _ReceiptDetails(),
              const SizedBox(height: 20),
              const _ReceiptTable(),
              const _SummaryTable(),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: generatePdfReceipt,
                  icon: const Icon(
                    Icons.print,
                    color: Colors.white,
                  ),
                  label: const Text('Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00AEEF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptDetails extends StatelessWidget {
  const _ReceiptDetails();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Booking ID : 01624395345', style: TextStyle(fontSize: 20)),
        Text('Invoice ID : 01624395345', style: TextStyle(fontSize: 20)),
        Text('Purok 4 Block 3', style: TextStyle(fontSize: 20)),
        Text('Panacan Relocation', style: TextStyle(fontSize: 20)),
        Text('8000 Davao City, Philippines', style: TextStyle(fontSize: 20)),
        Text('0976 074 7797', style: TextStyle(fontSize: 20)),
        Text('JCSD', style: TextStyle(fontSize: 20)),
      ],
    );
  }
}

class _ReceiptTable extends StatelessWidget {
  const _ReceiptTable();

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(0.5),
        1: FlexColumnWidth(5.8),
        2: FlexColumnWidth(1),
      },
      children: List<TableRow>.generate(10, (index) {
        return TableRow(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.grey[200] : Colors.white,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index == 0 ? 'Item' : (index).toString()),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index == 0 ? 'Description' : 'Service Charge'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index == 0 ? 'Quantity' : '3'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index == 0 ? 'Amount' : 'P400'),
            ),
          ],
        );
      }),
    );
  }
}

class _SummaryTable extends StatelessWidget {
  const _SummaryTable();

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(7),
        1: FlexColumnWidth(1),
      },
      children: List<TableRow>.generate(4, (index) {
        return TableRow(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.grey[200] : Colors.white,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                index == 0
                    ? 'Subtotal'
                    : (index == 1 ? 'Tax' : (index == 2 ? 'Other' : 'Total')),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index == 0
                  ? 'P2,000'
                  : (index == 1
                      ? 'P1,000'
                      : (index == 2 ? 'P1,000' : 'P5,000'))),
            ),
          ],
        );
      }),
    );
  }
}
