// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  _AuditLogPageState createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final String _activeSubItem = '/auditLog';

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
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Audit Log',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                          fontSize: 20,
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/avatars/cat2.jpg'),
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
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 350,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: Color(0xFFABABAB),
                  fontFamily: 'NunitoSans',
                ),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
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
            headingRowColor: MaterialStateProperty.all(
              const Color(0xFF00AEEF),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'Item ID',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Item Name',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Item Type',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Supplier',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date Modified',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Action Taken',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            rows: const [
              DataRow(
                cells: [
                  DataCell(Text('0126546')),
                  DataCell(Text('Samsung SSD 550GB')),
                  DataCell(Text('Technology')),
                  DataCell(Text('Samsung')),
                  DataCell(Text('11/01/2024')),
                  DataCell(Text('Item Created')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
