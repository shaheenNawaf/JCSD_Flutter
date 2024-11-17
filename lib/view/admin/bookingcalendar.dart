// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class BookingCalendarPage extends StatefulWidget {
  const BookingCalendarPage({super.key});

  @override
  _BookingCalendarPageState createState() => _BookingCalendarPageState();
}

class _BookingCalendarPageState extends State<BookingCalendarPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final String _activeSubItem = '/bookingsCalendar';

  DateTime _focusedDate = DateTime.now();

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

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  List<String> _getTimeSlots() {
    return [
      '9:00',
      '10:00',
      '11:00',
      '12:00',
      '1:00',
      '2:00',
      '3:00',
      '4:00',
      '5:00',
    ];
  }

  List<DateTime> _getWeekDays(DateTime startOfWeek) {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _changeWeek(int offset) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: offset * 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final startOfWeek = _getWeekStart(_focusedDate);
    final weekDays = _getWeekDays(startOfWeek);

    final availableWidth = MediaQuery.of(context).size.width - 332.0;
    final columnWidth = availableWidth / 7;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calendar',
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
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            color: const Color(0xFF00AEEF),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => _changeWeek(-1),
                                  icon: const Icon(
                                    Icons.arrow_left,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${DateFormat('MMM d').format(weekDays.first)} - ${DateFormat('MMM d, yyyy').format(weekDays.last)}',
                                  style: const TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _changeWeek(1),
                                  icon: const Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey),
                                    right: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                              ...weekDays.map((day) {
                                return Container(
                                  width: columnWidth,
                                  height: 50,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey),
                                      right: BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                  child: Text(
                                    '${DateFormat('EEE').format(day)} ${DateFormat('d').format(day)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00AEEF),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _getTimeSlots().length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: columnWidth,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom:
                                              BorderSide(color: Colors.grey),
                                          right: BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                      child: Text(
                                        _getTimeSlots()[index],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    // Day Columns
                                    ...weekDays.map((_) {
                                      return Container(
                                        width: columnWidth,
                                        height: columnWidth,
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom:
                                                BorderSide(color: Colors.grey),
                                            right:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
