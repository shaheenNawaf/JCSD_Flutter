import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/modals/edit_profile.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class ProfileAdminViewPage extends ConsumerStatefulWidget {
  const ProfileAdminViewPage({super.key});

  @override
  ConsumerState<ProfileAdminViewPage> createState() =>
      _ProfileAdminViewPageState();
}

class _ProfileAdminViewPageState extends ConsumerState<ProfileAdminViewPage> {
  final String _activeSubItem = '/accountList';

  void _editBookingModal(AccountsData user) async {
    final updated = await showDialog<AccountsData>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditProfileModal(account: user);
      },
    );

    if (updated != null) {
      setState(() {
        // Replace with updated info
      });
    }
  }

  String displayValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String && value.trim().isEmpty) return 'N/A';
    return value.toString();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat.yMMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    final AccountsData? user =
        ModalRoute.of(context)?.settings.arguments as AccountsData?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Account Details',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildProfileView(user),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(AccountsData? user) {
    if (user == null) {
      return const Center(child: Text("No data available."));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior()
              .copyWith(overscroll: false, scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(user),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _editBookingModal(user),
                        icon: const FaIcon(FontAwesomeIcons.penToSquare,
                            color: Colors.white, size: 16),
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
                _buildInfoRow(FontAwesomeIcons.envelope, 'Email: ',
                    displayValue(user.email)),
                _buildInfoRow(FontAwesomeIcons.phone, 'Phone: ',
                    displayValue(user.contactNumber)),
                _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ',
                    formatDate(user.birthDate)),
                _buildDivider(),
                _buildSectionTitle('Address'),
                _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
                    displayValue(user.address)),
                _buildInfoRow(
                    FontAwesomeIcons.city, 'City: ', displayValue(user.city)),
                _buildInfoRow(FontAwesomeIcons.globe, 'Province: ',
                    displayValue(user.province)),
                _buildInfoRow(FontAwesomeIcons.flag, 'Country: ',
                    displayValue(user.country)),
                _buildInfoRow(FontAwesomeIcons.mapPin, 'Zip Code: ',
                    displayValue(user.zipCode)),
                _buildDivider(),
                _buildSectionTitle('Account Details'),
                _buildInfoRow(FontAwesomeIcons.user, 'Full Name: ',
                    '${displayValue(user.firstName)} ${displayValue(user.middleName)} ${displayValue(user.lastname)}'),
                _buildInfoRow(FontAwesomeIcons.lock, 'Password: ', '*********'),
                _buildInfoRow(FontAwesomeIcons.idBadge, 'User ID: ',
                    displayValue(user.userID)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AccountsData user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black38,
            ),
            child: const FaIcon(FontAwesomeIcons.user,
                color: Colors.white, size: 35),
          ),
          const SizedBox(width: 20),
          Text(
            '${displayValue(user.firstName)} ${displayValue(user.lastname)}',
            style: const TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 0, 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
          child: SizedBox(
              width: 25, child: FaIcon(icon, color: Colors.grey, size: 20)),
        ),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], indent: 40, endIndent: 40);
  }
}
