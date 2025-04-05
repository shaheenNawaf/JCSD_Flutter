import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/modals/addleaverequest.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({super.key});

  @override
  _LeaveRequestState createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final String _activeSubItem = '/employeeList';

  void _showAddItemListModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LeaveRequestForm();
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
                  title: 'Leave Requests',
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
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                      child: Text(
                        "Leave Request",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 10,
                      childAspectRatio: 8,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final name = [
                        'Amy D. Polie',
                        'Amy D. Polie',
                        'Amy D. Polie',
                        'Amy D. Polie',
                        'Amy D. Polie',
                        'Amy D. Polie',
                        'Amy D. Polie'
                      ];
                      final type = [
                        'Sick Leave',
                        'Sick Leave',
                        'Corporate Leave',
                        'Corporate Leave',
                        'Sick Leave',
                        'Holiday Leave',
                        'Sick Leave'
                      ];
                      final date = [
                        '05/05/2024 - 05/07/2024',
                        '05/05/2024 - 05/07/2024',
                        '05/05/2024 - 05/07/2024',
                        '05/05/2024 - 05/07/2024',
                        '05/05/2024 - 05/07/2024',
                        '05/05/2024 - 05/07/2024',
                        '05/05/2024 - 05/07/2024'
                      ];
                      final notes = [
                        'None',
                        'I have Pneumonia',
                        'None',
                        'None',
                        'None',
                        'None',
                        'None'
                      ];
                      final status = [
                        'Pending',
                        'Approved',
                        'Rejected',
                        'Pending',
                        'Pending',
                        'Pending',
                        'Pending'
                      ];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name[index],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                      Text(type[index]),
                                      Text(date[index]),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Notes',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text(notes[index]),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 35, 10, 35),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 80,
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
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
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
                        onPressed: _showAddItemListModal,
                        icon: const FaIcon(FontAwesomeIcons.suitcaseRolling,
                            color: Colors.white),
                        label: const Text('Request for Leave'),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], indent: 40, endIndent: 40);
  }
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
