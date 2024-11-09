import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/modals/addleaverequest.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class LeaveRequestList extends StatefulWidget {
  const LeaveRequestList({super.key});

  @override
  _LeaveRequestListState createState() => _LeaveRequestListState();
}

class _LeaveRequestListState extends State<LeaveRequestList> with SingleTickerProviderStateMixin {
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

  void _showAddItemListModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LeaveRequestForm();
      },
    );
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
                'Leave Requests',
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
                              'Leave Requests',
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
      child: Expanded(child: Column(
        children: [
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(40, 20, 0, 0),
                child: Text("Leave Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Spacer(),
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
                final name = ['Amy D. Polie', 'Amy D. Polie', 'Amy D. Polie', 'Amy D. Polie', 'Amy D. Polie', 'Amy D. Polie', 'Amy D. Polie'];
                final type = ['Sick Leave', 'Sick Leave', 'Corporate Leave', 'Corporate Leave', 'Sick Leave', 'Holiday Leave', 'Sick Leave'];
                final date = ['05/05/2024 - 05/07/2024', '05/05/2024 - 05/07/2024', '05/05/2024 - 05/07/2024', '05/05/2024 - 05/07/2024', '05/05/2024 - 05/07/2024', '05/05/2024 - 05/07/2024', '05/05/2024 - 05/07/2024'];
                final notes = ['None', 'I have Pnuemonia', 'None', 'None', 'None', 'None', 'None'];                  return Container(
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
                              Text(name[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                              Text(type[index]),
                              Text(date[index]),                           
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                            Text(notes[index]),
                          ],
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(width: 10),
                            ElevatedButton(
                            onPressed: () {
                              // Handle approve action
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
                              // Handle reject action
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
      ),
    );
  }
}