import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/main.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final String _activeSubItem = '/employeeList';
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
                  title: 'Profile',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => context.pop(),
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
                  _buildInfoRow(FontAwesomeIcons.envelope, 'Email: ',
                      'mebguevara@gmail.com'),
                  _buildInfoRow(
                      FontAwesomeIcons.phone, 'Phone: ', '09278645368'),
                  _buildInfoRow(FontAwesomeIcons.cakeCandles, 'Birthday: ',
                      'May 5, 2001'),
                  _buildDivider(),
                  _buildSectionTitle('Address'),
                  _buildInfoRow(FontAwesomeIcons.locationDot, 'Address: ',
                      '106-6 CM Recto Ave.'),
                  _buildInfoRow(FontAwesomeIcons.city, 'City: ', 'Manila'),
                  _buildInfoRow(
                      FontAwesomeIcons.globe, 'Country: ', 'Philippines'),
                  _buildDivider(),
                  _buildSectionTitle('Employee Details'),
                  _buildInfoRow(FontAwesomeIcons.user, 'Title: ', 'Employee.'),
                  _buildInfoRow(
                      FontAwesomeIcons.calendar, 'Hire Date: ', '05/05/05'),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[300]),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                      child: Text("Attendance",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
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
                        icon: const FaIcon(FontAwesomeIcons.calendar,
                            color: Colors.black),
                        label: Text(
                          '${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 2,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final days = [
                        '250 Hours',
                        '286 Hours',
                        '+ 36 Hours',
                        '3',
                        '4',
                        '2 Days',
                      ];
                      final statuses = [
                        'Scheduled',
                        'Worked',
                        'Difference',
                        'Tardies',
                        'Absences',
                        'Leaves',
                        'Button'
                      ];

                      if (statuses[index] == 'Button') {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00AEEF),
                            foregroundColor: Colors.white,
                            side:
                                const BorderSide(color: Colors.grey, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {
                            // Button action here
                          },
                          child: const Center(
                            child: Text(
                              'Clock In',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(days[index],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Text(statuses[index],
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
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
                                label: Center(
                                  child: Text(
                                    'Date',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    'Clock In',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    'Clock Out',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Center(
                                  child: Text(
                                    'Worked',
                                    style: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                            rows: const [
                              DataRow(cells: [
                                DataCell(Text('01/01/2023')),
                                DataCell(Text('Present')),
                                DataCell(Text('09:00 AM')),
                                DataCell(Text('05:00 PM')),
                                DataCell(Text('8 hrs')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('01/02/2023')),
                                DataCell(Text('Absent')),
                                DataCell(Text('-')),
                                DataCell(Text('-')),
                                DataCell(Text('-')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('01/03/2023')),
                                DataCell(Text('Present')),
                                DataCell(Text('09:15 AM')),
                                DataCell(Text('05:15 PM')),
                                DataCell(Text('8 hrs')),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 40, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          context.go('/employeeList/profile/payslip');
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.fileInvoiceDollar,
                          color: Colors.white,
                        ),
                        label: const Text('Payslips'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          context.go('/employeeList/profile/leaveRequest');
                        },
                        icon: const FaIcon(FontAwesomeIcons.suitcaseRolling,
                            color: Colors.white),
                        label: const Text('Leave Requests'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
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
