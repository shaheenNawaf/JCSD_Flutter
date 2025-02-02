import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/modals/editprofile.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class ProfileAdminViewPage extends StatefulWidget {
  const ProfileAdminViewPage({super.key});

  @override
  _ProfileAdminViewPageState createState() => _ProfileAdminViewPageState();
}

class _ProfileAdminViewPageState extends State<ProfileAdminViewPage> {
  DateTime selectedDate = DateTime.now();

  void _editBookingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const EditProfileModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Details',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                          fontSize: 20,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/profile', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                              'assets/avatars/cat2.jpg'), // Replace with your image source
                        ),
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _editBookingModal();
                    },
                    icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Basic Information'),
            _buildInfoRow(
                FontAwesomeIcons.envelope, 'Email: ', 'mebguevara@gmail.com'),
            _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ', '09278645368'),
            _buildInfoRow(
                FontAwesomeIcons.cakeCandles, 'Birthday: ', 'May 5, 2001'),
            _buildDivider(),
            _buildSectionTitle('Address'),
            _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
                '106-6 CM Recto Ave.'),
            _buildInfoRow(FontAwesomeIcons.city, 'City: ', 'Manila'),
            _buildInfoRow(FontAwesomeIcons.globe, 'Country: ', 'Philippines'),
            _buildDivider(),
            _buildSectionTitle('Account Details'),
            _buildInfoRow(FontAwesomeIcons.user, 'User Name: ', 'Lake.'),
            _buildInfoRow(FontAwesomeIcons.user, 'Password: ', '*********.'),
            _buildInfoRow(FontAwesomeIcons.calendar, 'Account Creation Date: ',
                '05/05/05'),
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
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black38),
            child: const FaIcon(FontAwesomeIcons.user,
                color: Colors.white, size: 35),
          ),
          const SizedBox(width: 20),
          const Text(
            'Amy D. Polie',
            style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.bold,
                fontSize: 20),
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
}
