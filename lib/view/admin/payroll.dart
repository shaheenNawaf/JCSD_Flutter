import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/modals/editpayroll.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Payroll extends StatefulWidget {
  const Payroll({super.key});

  @override
  _PayrollState createState() => _PayrollState();
}

class _PayrollState extends State<Payroll> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DateTime selectedDate = DateTime.now();

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

  void _editBookingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const EditPayrollModal();
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
                'Payroll',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Color(0xFF00AEEF)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const Text(
                              'Payroll',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AEEF),
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage('assets/avatars/cat2.jpg'), // Replace with your image source
                              ),
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
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                  _buildSectionTitle('Employee Details'),
                  _buildInfoRow(FontAwesomeIcons.user, 'Title: ', 'Employee.'),
                  _buildInfoRow(FontAwesomeIcons.calendar, 'Hire Date: ', '05/05/05'),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[300]),
          Expanded(child: Column(
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                    child: Text("Payroll", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.pen),
                      iconSize: 10,
                      onPressed: () {
                        _editBookingModal();
                      },
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 40, 0),
                    child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      DateTime? pickedDate = await showMonthPicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    icon: const FaIcon(FontAwesomeIcons.calendar, color: Colors.black), 
                    label: Text(
                    '${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[300], indent: 40, endIndent: 40),
              const PayrollRow(label: 'Total Income: ', value: 'P20,000', isBold: true),
              const PayrollRow(label: 'Salary: ', value: 'P20,000'),
              const PayrollRow(label: 'Medical Allowance: ', value: 'P20,000'),
              const PayrollRow(label: 'OT Regular Day: ', value: 'P20,000'),
              const PayrollRow(label: 'Bonus: ', value: 'P20,000'),
              const PayrollRow(label: 'Others: ', value: 'P20,000'),
              Divider(color: Colors.grey[300], indent: 40, endIndent: 40),
              const PayrollRow(label: 'Total Deduction: ', value: 'P5,000', isBold: true),
              const PayrollRow(label: 'Tardiness: ', value: 'P2,000'),
              const PayrollRow(label: 'Absences: ', value: 'P2,000'),
              Divider(color: Colors.grey[300], indent: 40, endIndent: 40),
              const PayrollRow(label: 'Sub Total: ', value: 'P123,000', isBold: true),
              const PayrollRow(label: 'Tax: ', value: 'P20,000'),
              Divider(color: Colors.grey[300], indent: 40, endIndent: 40),
              const PayrollRow(label: 'Net Salary: ', value: 'P200,000', isBold: true),
            ],
          )),
        ],
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
}


class PayrollRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const PayrollRow({super.key, 
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 20)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 20)),
        ],
      ),
    );
  }
}
