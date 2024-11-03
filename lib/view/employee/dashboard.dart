// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
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

  void _openDrawer() {
    _animationController.forward();
  }

  void _closeDrawer() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF00AEEF),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.bars,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                    _openDrawer();
                  },
                ),
              ),
            )
          : null,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF00AEEF),
              child: Sidebar(
                activePage: 'dashboard',
                onClose: _closeDrawer,
              ),
            )
          : null,
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          _closeDrawer();
        }
      },
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) const Sidebar(activePage: 'dashboard'),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dashboard',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AEEF),
                                fontSize: 20,
                              ),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/avatars/cat2.jpg'),
                            ),
                          ],
                        ),
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
          if (isMobile)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value * 0.6,
                  child: _animationController.value > 0
                      ? Container(
                          color: Colors.black,
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        _buildHeaderRow(),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildBookingsReportChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _buildStatsGrid(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInventoryTable(),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bookings Report',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.black,
            ),
            label: const Row(
              children: [
                Text(
                  'January 2024 - February 2024',
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 8),
                FaIcon(
                  FontAwesomeIcons.chevronDown,
                  color: Colors.black,
                  size: 16,
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsReportChart() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Text(
          'Insert Bookings Report Chart',
          style: TextStyle(
            fontFamily: 'NunitoSans',
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      children: [
        _buildStatsCard('Profit', '₱252,000', '+25.5%', Colors.green,
            backgroundColor: const Color(0xFFE6F7E6)),
        _buildStatsCard('Cost', '₱300,000', '-25.5%', Colors.red,
            backgroundColor: const Color(0xFFFFE6E6)),
        _buildStatsCard('Revenue', '₱122,000', '-25.5%', Colors.red,
            backgroundColor: const Color(0xFFFFE6E6)),
        _buildStatsCard('Revenue', '₱122,000', '-25.5%', Colors.red,
            backgroundColor: const Color(0xFFFFE6E6)),
      ],
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
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
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
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Icon(
                      percentage.contains('+')
                          ? FontAwesomeIcons.arrowUp
                          : FontAwesomeIcons.arrowDown,
                      color: color,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      percentage,
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    return Container(
      height: 300,
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
      child: ListView(
        shrinkWrap: true,
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
            columns: const [
              DataColumn(
                label: Center(
                  child: Text(
                    'Item ID',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Item Name',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Item Type',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Supplier',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Price',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            rows: [
              _buildDataRow('0126546', 'Samsung SSD 500GB', 'Technology',
                  'Samsung', '12 pcs', '₱500'),
              _buildDataRow('0126547', 'Samsung SSD 250GB', 'Technology',
                  'Samsung', '2 pcs', '₱250'),
              _buildDataRow('0126548', 'Samsung SSD 1TB', 'Technology',
                  'Samsung', '5 pcs', '₱1000'),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String id, String name, String type, String supplier,
      String quantity, String price) {
    return DataRow(
      cells: [
        DataCell(Text(id,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ))),
        DataCell(Text(name,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ))),
        DataCell(Text(type,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ))),
        DataCell(Text(supplier,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ))),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          width: 100,
          height: 30,
          decoration: BoxDecoration(
            color: quantity == '12 pcs' ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            quantity,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              color: Colors.white,
            ),
          ),
        )),
        DataCell(Text(price,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ))),
      ],
    );
  }
}
