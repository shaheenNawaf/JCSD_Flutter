import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/main.dart';
import 'package:jcsd_flutter/modals/confirmleaverequest.dart';
import 'package:jcsd_flutter/modals/rejectleaverequest.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class LeaveRequestList extends StatefulWidget {
  const LeaveRequestList({super.key});

  @override
  _LeaveRequestListState createState() => _LeaveRequestListState();
}

class _LeaveRequestListState extends State<LeaveRequestList> {
  final String _activeSubItem = '/employeeList';

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
                  title: 'Leave Request List',
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
      child: Column(
        children: [
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                child: Text("Leave Request",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Spacer(),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 20,
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
                  'I have Pnuemonia',
                  'None',
                  'None',
                  'None',
                  'None',
                  'None'
                ];
                return Container(
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
                                Text(name[index],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25)),
                                Text(type[index]),
                                Text(date[index]),
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
                                const Text('Notes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25)),
                                Text(notes[index]),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _showConfirmLeaveRequestModal();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text('Approve'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  _showRejectLeaveRequestModal();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _showConfirmLeaveRequestModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ConfirmLeaveRequestModal();
      },
    );
  }

  _showRejectLeaveRequestModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const RejectLeaveRequestModal();
      },
    );
  }
}
