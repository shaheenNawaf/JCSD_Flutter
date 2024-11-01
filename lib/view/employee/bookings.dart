// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/modals/bookingrequest.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
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

  void _showBookingRequestModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const BookingRequestModal();
      },
    );
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
                'Bookings',
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
                activePage: 'bookings',
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
              if (!isMobile) const Sidebar(activePage: 'bookings'),
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
                              backgroundImage:
                                  AssetImage('assets/avatars/cat2.jpg'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildMobileSearchBar(),
                                  const SizedBox(height: 16),
                                  Expanded(child: _buildMobileListView()),
                                ],
                              )
                            : _buildWebView(),
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

  Widget _buildMobileSearchBar() {
    return SizedBox(
      width: double.infinity,
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
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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

  Widget _buildMobileListView() {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              title: const Text(
                'Shaheen Al Adwani',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              subtitle: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '01/12/2024',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                  Text(
                    '10:00 AM',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Computer Repair - In-Store Service',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '000001',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const Text(
                    'samsung@gmail.com',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.left,
                  ),
                  TextButton(
                    onPressed: _showBookingRequestModal,
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Color(0xFF00AEEF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              height: 1,
              color: Colors.grey,
            ),
          ],
        );
      },
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
      color: WidgetStateProperty.all(Colors.white),
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
                onPressed: _showBookingRequestModal, // Open the modal
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
