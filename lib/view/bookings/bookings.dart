// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final String _activeSubItem = '/bookings';

  String _selectedFilter = 'All';

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
                        'Bookings',
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
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AEEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  items: <String>[
                    'All',
                    'Confirmed',
                    'Unconfirmed',
                    'Done',
                    'Replacement',
                    'Pending'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontFamily: 'NunitoSans',
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                    });
                  },
                  underline: Container(),
                  dropdownColor: const Color(0xFF00AEEF),
                ),
              ),
              const Spacer(),
              SizedBox(
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
            ],
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
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Booking ID',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Customer Name',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Date Time',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Service Type/s',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Service Location',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contact Info',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.only(left: 45),
                  child: Center(
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
            rows: [
              _buildDataRow(
                '000001',
                'Shaheen Al Adwani',
                '01/12/2024',
                '10:00 AM',
                'Computer Repair',
                'In-Store Service',
                '09088184444',
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
    String id,
    String name,
    String date,
    String time,
    String serviceType,
    String serviceLocation,
    String email,
  ) {
    return DataRow(
      color: MaterialStateProperty.all(Colors.white),
      cells: [
        DataCell(Align(
            alignment: Alignment.centerLeft,
            child: Text(id, overflow: TextOverflow.ellipsis))),
        DataCell(Align(
            alignment: Alignment.centerLeft,
            child: Text(name, overflow: TextOverflow.ellipsis))),
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, overflow: TextOverflow.ellipsis),
                Text(time, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
        DataCell(Align(
            alignment: Alignment.centerLeft,
            child: Text(serviceType, overflow: TextOverflow.ellipsis))),
        DataCell(Align(
            alignment: Alignment.centerLeft,
            child: Text(serviceLocation, overflow: TextOverflow.ellipsis))),
        DataCell(Align(
            alignment: Alignment.centerLeft,
            child: Text(email, overflow: TextOverflow.ellipsis))),
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/bookingDetail');
                },
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
