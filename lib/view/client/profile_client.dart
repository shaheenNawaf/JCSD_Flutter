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

  void _showArchiveItemModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Receipt();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(activePage: 'booking'),
      body: Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 20),
                          _buildSectionTitle('About'),
                          _buildInfoRow(FontAwesomeIcons.envelope, 'Email: ', 'mebguevara@gmail.com'),
                          _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ', '09278645368'),
                          _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ', 'May 5, 2001'),
                          _buildDivider(),
                          _buildSectionTitle('Address'),
                          _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ', '106-6 CM Recto Ave.'),
                          _buildInfoRow(FontAwesomeIcons.city, 'City: ', 'Manila'),
                          _buildInfoRow(FontAwesomeIcons.globe, 'Country: ', 'Philippines'),
                          _buildDivider(),
                          _buildSectionTitle('Account Details'),
                          _buildInfoRow(FontAwesomeIcons.user, 'Username: ', 'Kami'),
                          _buildInfoRow(FontAwesomeIcons.calendar, 'Password: ', '**********'),
                        ],
                      ),
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
                                child: Text("Booking Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 1,
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 20,
                                childAspectRatio: 8,
                              ),
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                final time = ['10:00 AM', '11:30 AM', '02:00 PM', '03:15 PM', '04:45 PM', '09:00 AM', '01:30 PM'];
                                final type = ['Computer Repair', 'Computer Repair', 'Computer Clean', 'Laptop Diagnosis', 'Laptop Diagnosis', 'Laptop Diagnosis', 'PC Build'];
                                final date = ['05/05/2024', '05/05/2024', '05/05/2024', '05/05/2024', '05/05/2024', '05/05/2024', '05/05/2024'];
                                final notes = ['None', 'Broken Cooling Fan', 'None', 'None', 'None', 'None', 'None'];
                                final status = ['Pending', 'Completed', 'Unpaid', 'Pending', 'Pending', 'Pending', 'Pending'];
                                final employee = ['John Doe', 'Jane Smith', 'Alice Johnson', 'Robert Brown', 'Emily Davis', 'Michael Wilson', 'Sarah Lee'];
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
                                      border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(date[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                                                  Text(type[index]),
                                                  Text(time[index]),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                mainAxisAlignment: MainAxisAlignment.start,
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
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: status[index] == 'Pending'
                                                        ? Colors.grey
                                                        : status[index] == 'Completed'
                                                            ? Colors.green
                                                            : Color(0xFFE53935),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    status[index],
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                        : const Center(child: Text('Select a booking to see details')),
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 25, 0, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
            child: const FaIcon(FontAwesomeIcons.user, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amy D. Polie',
                style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 16),
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
            width: 25,
            child: FaIcon(icon, color: Colors.grey, size: 20)),
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
              Image.asset(
                'assets/images/logo.png',
                height: 50,
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
                style:const TextStyle(
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
                    onPressed: () {_showArchiveItemModal();},
                    style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: const Color(0xFF00AEEF),
                    padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 100),
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
