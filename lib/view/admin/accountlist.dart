// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  _AccountListPageState createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF00AEEF),
              title: const Text(
                'Account List',
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
                  },
                ),
              ),
            )
          : null,
      drawer: isMobile
          ? const Drawer(
              backgroundColor: Color(0xFF00AEEF),
              child: Sidebar(
                activePage: 'account_list',
              ),
            )
          : null,
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) const Sidebar(activePage: 'account_list'),
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
                              'Account List',
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
                        child: _buildWebView(),
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

  Widget _buildWebView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00AEEF),
              minimumSize: const Size(120, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Leave Requests',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTable(),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
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
      child: ListView(
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF00AEEF),
            ),
            columns: const [
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Position',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Contact Info',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.only(left: 40),
                  child: Center(
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows: [
              _buildDataRow(
                'Ashley Alexis',
                'Active',
                'Computer Repair Technician',
                '@gmail.com',
                '(***) ***-****',
              ),
              _buildDataRow(
                'Adrian Sc',
                'Active',
                'Technician',
                '@gmail.com',
                '(***) ***-****',
              ),
              _buildDataRow(
                'Jack Kaplan',
                'Terminated',
                'Technician',
                '@gmail.com',
                '(***) ***-****',
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
      String name, String status, String position, String email, String phone) {
    return DataRow(
      cells: [
        DataCell(Text(
          name,
          style: const TextStyle(
            fontFamily: 'NunitoSans',
          ),
        )),
        DataCell(Text(
          status,
          style: const TextStyle(
            fontFamily: 'NunitoSans',
          ),
        )),
        DataCell(Text(
          position,
          style: const TextStyle(
            fontFamily: 'NunitoSans',
          ),
        )),
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              email,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
            Text(
              phone,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ],
        )),
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
