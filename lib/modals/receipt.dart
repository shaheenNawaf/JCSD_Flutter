// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class Receipt extends StatefulWidget {
  const Receipt({super.key});

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
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
                      // Add your print functionality here
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
    )
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
