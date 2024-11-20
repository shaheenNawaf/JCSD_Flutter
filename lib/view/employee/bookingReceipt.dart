import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class BookingReceipt extends StatefulWidget {
  const BookingReceipt({super.key});

  @override
  _BookingReceiptState createState() => _BookingReceiptState();
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
