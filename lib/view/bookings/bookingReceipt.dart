import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_email_sender/flutter_email_sender.dart';

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
            pw.Text("Booking ID : 01624395345", style: const pw.TextStyle(fontSize: 20)),
            pw.Text("Invoice ID : 01624395345", style: const pw.TextStyle(fontSize: 20)),
            pw.Text("Purok 4 Block 3", style: const pw.TextStyle(fontSize: 15)),
            pw.Text("Panacan Relcoation", style: const pw.TextStyle(fontSize: 15)),
            pw.Text("8000 Davao City, Philippines", style: const pw.TextStyle(fontSize: 15)),
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
                <String>['','','Subtotal', 'P2,000'],
                <String>['','','Tax', 'P1,000'],
                <String>['','','Other', 'P1,000'],
                <String>['','','Total', 'P5,000'],
            ]),
          ],
        )
      ),
    ),
  );

  final Uint8List pdfData = await pdf.save();
  final blob = html.Blob([pdfData], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..target = '_blank'
    ..download = 'receipt.pdf'
    ..click();

  html.Url.revokeObjectUrl(url);
}

Future<void> sendEmailWithAttachment(File attachment) async {
  final Email email = Email(
    body: 'Here is the PDF file you requested.',
    subject: 'PDF File',
    recipients: ['mebguevara@addu.edu.ph'], // Replace with the recipient's email
    attachmentPaths: [attachment.path],
    isHTML: false,
  );

  try {
    await FlutterEmailSender.send(email);
  } catch (error) {
    print('Failed to send email: $error');
  }
}

class _BookingReceiptState extends State<BookingReceipt> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer(bool isOpen) {
    isOpen ? _animationController.forward() : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: isMobile ? _buildAppBar() : null,
      drawer: isMobile ? _buildDrawer() : null,
      onDrawerChanged: _toggleDrawer,
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) const Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile) const _Header(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isMobile ? const SizedBox.shrink() : const _WebView(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMobile)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value * 0.6,
                  child: _animationController.value > 0 ? Container(color: Colors.black) : const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF00AEEF),
      title: const Text(
        'Booking Receipt',
        style: TextStyle(
          fontFamily: 'NunitoSans',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const FaIcon(FontAwesomeIcons.bars, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
            _toggleDrawer(true);
          },
        ),
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF00AEEF),
      child: Sidebar(onClose: () => _toggleDrawer(false)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Color(0xFF00AEEF)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Text(
            'Booking Receipt',
            style: TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.bold,
              color: Color(0xFF00AEEF),
              fontSize: 20,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            child: const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/avatars/cat2.jpg'), // Replace with your image source
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
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      IconButton(
                        icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Color(0xFF00AEEF)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        'Receipt',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const _ReceiptDetails(),
                  const Spacer(),
                  const _ReceiptTable(),
                  const _SummaryTable(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        generatePdfReceipt();
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print Receipt'),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  ),
                ],
              ),
            ),
          ),
        ],
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
        Text('Panacan Relcoation', style: TextStyle(fontSize: 20)),
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
        0: FlexColumnWidth(0.2),
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
                index == 0 ? 'Subtotal' : (index == 1 ? 'Tax' : (index == 2 ? 'Other' : 'Total')),
                textAlign: TextAlign.right,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(index == 0 ? 'P2,000' : (index == 1 ? 'P1,000' : (index == 2 ? 'P1,000' : 'P5,000'))),
            ),
          ],
        );
      }),
    );
  }
}
