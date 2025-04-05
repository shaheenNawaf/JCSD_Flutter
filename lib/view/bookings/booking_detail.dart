// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/modals/add_item_list.dart';
import 'package:jcsd_flutter/view/bookings/modals/booking_request.dart';
import 'package:jcsd_flutter/view/bookings/modals/edit_booking_detail.dart';
import 'package:jcsd_flutter/modals/remove_itemlist.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final String _activeSubItem = '/bookings';

  void _showAddItemListModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddItemListModal();
      },
    );
  }

  void _removeItemConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const RemoveItemModal();
      },
    );
  }

  void _editBookingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const EditBookingModal();
      },
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Booking Details',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => Navigator.pop(context),
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
        Expanded(
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
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Booking ID : 1342352',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 35),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 30),
                          onPressed: () {
                            _editBookingModal();
                          },
                        )
                      ],
                    ),
                    const Text('September 5, 2021 10:00PM'),
                    const Spacer(),
                    const Text(
                      'Computer Diagnosis',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Roxas St. Davao City, Davao del Sur'),
                    const Text('8000, Philippines'),
                    const Text('Home Service'),
                    const Spacer(),
                    const Text(
                      'Customer Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('Kyle Maggelan'),
                    const Text('092786453636'),
                    const Spacer(),
                    const Text(
                      'Assigned Employee',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Text('John Paul'),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            _showBookingRequestModal();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AEEF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text('Finalize'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
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
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Row(
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, '/bookingReceipt');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00AEEF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('View Receipt'),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Price',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'P200',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Service Fee',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'P200',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Additional Items',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 5),
                          child: ElevatedButton(
                            onPressed: () {
                              _showAddItemListModal();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              backgroundColor: const Color(0xFF00AEEF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: const Text('Item List',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
                          constraints: const BoxConstraints(),
                          icon: const FaIcon(FontAwesomeIcons.x,
                              color: Colors.red, size: 15),
                          onPressed: () {
                            _removeItemConfirmationModal();
                          },
                        ),
                        const Text('Samsung SSD 500GB'),
                        const Spacer(),
                        const Text('P200'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
                          constraints: const BoxConstraints(),
                          icon: const FaIcon(FontAwesomeIcons.x,
                              color: Colors.red, size: 15),
                          onPressed: () {
                            _removeItemConfirmationModal();
                          },
                        ),
                        const Text('Samsung SSD 500GB'),
                        const Spacer(),
                        const Text('P200'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(0, 2, 10, 0),
                          constraints: const BoxConstraints(),
                          icon: const FaIcon(FontAwesomeIcons.x,
                              color: Colors.red, size: 15),
                          onPressed: () {
                            _removeItemConfirmationModal();
                          },
                        ),
                        const Text('Samsung SSD 500GB'),
                        const Spacer(),
                        const Text('P200'),
                      ],
                    ),
                    const Spacer(),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          'P200',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Paid',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
