import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> with SingleTickerProviderStateMixin {
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
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF00AEEF),
              title: const Text(
                'Booking Details',
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
            )
          : null,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF00AEEF),
              child: Sidebar(onClose: () => _toggleDrawer(false)),
            )
          : null,
      onDrawerChanged: _toggleDrawer,
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) const Sidebar(),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking Details',
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
                        child: isMobile ? const SizedBox.shrink() : _buildWebView(),
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

  Widget _buildWebView() {
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 2,
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
            child:  SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Booking ID : 1342352',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 30),
                          onPressed: () {
                            // Add your edit functionality here
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
                    const Text('John Paul'),
                  ],
                ),
              ),
            ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
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
            child:  SizedBox(
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Spacer(),
                            ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00AEEF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text('View Receipt'),
                            ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Base Price',style: TextStyle(fontWeight: FontWeight.w600),),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Fee',style: TextStyle(fontWeight: FontWeight.w600),),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Additional Items',style: TextStyle(fontWeight: FontWeight.w600),),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text('Samsung SSD 500GB'),
                        ),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text('Samsung SSD 500GB'),
                        ),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text('Samsung SSD 500GB'),
                        ),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,

                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Price',style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('P200',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status',style: TextStyle(fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.green, // Change to Colors.red for unpaid
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                          'Paid', // Change to 'Unpaid' for unpaid
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green, // Change to Colors.red for unpaid
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
      )
    );
  }
}