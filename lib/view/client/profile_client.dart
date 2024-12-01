import 'package:flutter/material.dart';
import 'package:jcsd_flutter/modals/receipt.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePageClient extends StatefulWidget {
  const ProfilePageClient({super.key});

  @override
  State<ProfilePageClient> createState() => _ProfilePageClientState();
}

class _ProfilePageClientState extends State<ProfilePageClient> {
  Map<String, String>? selectedBooking;

  final List<String> time = [
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '03:15 PM',
    '04:45 PM',
    '09:00 AM',
    '01:30 PM'
  ];
  final List<String> type = [
    'Computer Repair',
    'Computer Repair',
    'Computer Clean',
    'Laptop Diagnosis',
    'Laptop Diagnosis',
    'Laptop Diagnosis',
    'PC Build'
  ];
  final List<String> date = [
    '05/05/2024',
    '05/05/2024',
    '05/05/2024',
    '05/05/2024',
    '05/05/2024',
    '05/05/2024',
    '05/05/2024'
  ];
  final List<String> notes = [
    'None',
    'Broken Cooling Fan',
    'None',
    'None',
    'None',
    'None',
    'None'
  ];
  final List<String> status = [
    'Pending',
    'Completed',
    'Unpaid',
    'Pending',
    'Pending',
    'Pending',
    'Pending'
  ];
  final List<String> employee = [
    'John Doe',
    'Jane Smith',
    'Alice Johnson',
    'Robert Brown',
    'Emily Davis',
    'Michael Wilson',
    'Sarah Lee'
  ];

  void _showReceptModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Receipt();
      },
    );
  }

  void _showBookingDetails(Map<String, String> booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 490),
            child: Column(
              children: [
                _buildBookingDetails(booking),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: LayoutBuilder(builder: (context, constraints) {
        if (!isMobile) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFDFDFDF),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildprofile(),
                        ),
                        VerticalDivider(color: Colors.grey[300], thickness: 1),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                                    child: Text("Booking Appointments",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18)),
                                  ),
                                ],
                              ),
                              Expanded(
                                flex: 1,
                                child: GridView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(40, 10, 40, 0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 8,
                                  ),
                                  itemCount: 7,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedBooking = {
                                            'date': date[index],
                                            'type': type[index],
                                            'time': time[index],
                                            'notes': notes[index],
                                            'status': status[index],
                                            'employee': employee[index],
                                          };
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all( color: Colors.grey, width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                          child: Row(
                                            mainAxisAlignment:MainAxisAlignment.start,
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                    mainAxisAlignment:MainAxisAlignment.start,
                                                    crossAxisAlignment:CrossAxisAlignment.start,
                                                    children: [
                                                      Text(date[index], style: const TextStyle( fontWeight:FontWeight.bold, fontSize: 25)),
                                                      Text(type[index]),
                                                      Text(time[index]),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                    mainAxisAlignment:MainAxisAlignment.start,
                                                    crossAxisAlignment:CrossAxisAlignment.start,
                                                    children: [
                                                        const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                                                        Text(notes[index]),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                                Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Assigned Employee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                                                    Text(employee[index]),
                                                  ],
                                                  ),
                                                ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(20.0),
                                                  child: Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: Container(
                                                    width: 100,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: status[index] == 'Pending'
                                                        ? Colors.grey
                                                        : status[index] == 'Completed'
                                                          ? Colors.green
                                                          : const Color(0xFFE53935),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      status[index],
                                                      style: const TextStyle(color: Colors.white),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedBooking != null
                            ? _buildBookingDetails(selectedBooking!)
                            : const Center(
                                child: Text('Select a booking to see details')),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        height: 192,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Need Help?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '\nContact us at Facebook or call using this number\n12312413525454324',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFDFDFDF),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(children: [
                      _buildprofile(),
                      const SizedBox(height: 20),
                      _buildDivider(),
                      const SizedBox(height: 20),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.expand_more),
                          Text("Booking Appointments",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Icon(Icons.expand_more),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              _showBookingDetails({
                                'date': date[index],
                                'type': type[index],
                                'time': time[index],
                                'notes': notes[index],
                                'status': status[index],
                                'employee': employee[index],
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 40),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(date[index],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text(type[index]),
                                  Text(time[index]),
                                  Text('Notes: ${notes[index]}'),
                                  Text('Assigned Employee: ${employee[index]}'),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      width: 1000,
                                      decoration: BoxDecoration(
                                        color: status[index] == 'Pending'
                                            ? Colors.grey
                                            : status[index] == 'Completed'
                                                ? Colors.green
                                                : const Color(0xFFE53935),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          status[index],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ]),
                  )));
        }
      }),
    );
  }

  Widget _buildprofile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 20),
        _buildSectionTitle('About'),
        _buildInfoRow(
            FontAwesomeIcons.envelope, 'Email: ', 'mebguevara@gmail.com'),
        _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ', '09278645368'),
        _buildInfoRow(
            FontAwesomeIcons.cakeCandles, 'Birthday: ', 'May 5, 2001'),
        _buildDivider(),
        _buildSectionTitle('Address'),
        _buildInfoRow(
            FontAwesomeIcons.locationDot, 'Address: ', '106-6 CM Recto Ave.'),
        _buildInfoRow(FontAwesomeIcons.city, 'City: ', 'Manila'),
        _buildInfoRow(FontAwesomeIcons.globe, 'Country: ', 'Philippines'),
        _buildDivider(),
        _buildSectionTitle('Account Details'),
        _buildInfoRow(FontAwesomeIcons.user, 'Username: ', 'Kami'),
        _buildInfoRow(FontAwesomeIcons.calendar, 'Password: ', '**********'),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 25, 0, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black38),
            child: const FaIcon(FontAwesomeIcons.user,
                color: Colors.white, size: 35),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amy D. Polie',
                style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                'Employee',
                style: TextStyle(fontFamily: 'NunitoSans', fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 0, 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 10, 10),
          child: SizedBox(
              width: 25, child: FaIcon(icon, color: Colors.grey, size: 20)),
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], indent: 40, endIndent: 40);
  }

  Widget _buildBookingDetails(Map<String, String> booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 50,
                  ),
                  Spacer(),
                  if (MediaQuery.of(context).size.width <= 600)
                    IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Booking Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              const Divider(),
              Text(
                "${booking['date']} at ${booking['time']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
              ),
              const Divider(),
              const Text(
                "Booking Notes:",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "${booking['notes']}",
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                ),
              ),
              const Divider(),
              const Text(
                "Service Location:",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                "In-store Service",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                ),
              ),
              const Divider(),
              const Text(
                "Assigned Employee:",
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "${booking['employee']}",
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${booking['type']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Nunito',
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    "P1,500",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Nunito',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Divider(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "P 900",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _showReceptModal();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      backgroundColor: const Color(0xFF00AEEF),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 100),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    child: const Text(
                      'Receipt',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
