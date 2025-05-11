// ignore_for_file: library_private_types_in_public_api

import 'package:datepicker_dropdown/datepicker_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/employee/profile_leave_request_provider.dart';

class LeaveRequestForm extends ConsumerStatefulWidget {
  const LeaveRequestForm({super.key});

  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends ConsumerState<LeaveRequestForm> {
  int? _fromDay, _fromMonth, _fromYear;
  int? _toDay, _toMonth, _toYear;

  String? _selectedItem;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _leaveType = [
    'Sick Leave',
    'Corporate Leave',
    'Maternal Leave',
    'Paternal Leave',
    'Half-Day Leave',
    'Others'
  ];

  String? _selectedTime;
  final List<String> _duration = [
    'Full Day',
    'Half Day (Morning)',
    'Half Day (Afternoon)',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 300 ? 400 : screenWidth * 0.9;
    const double containerHeight = 640;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Leave Request Form',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDropdownField(
                    label: 'Leave Type',
                    hintText: 'Select Leave Type',
                    value: _selectedItem,
                    items: _leaveType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedItem = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Duration',
                    hintText: 'Select Duration',
                    value: _selectedTime,
                    items: _duration,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedTime = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(label: 'From'),
                  const SizedBox(height: 16),
                  _buildDateField(label: 'To'),
                  const SizedBox(height: 16),
                  _buildTextField(
                      label: 'Notes',
                      hintText: 'Enter notes',
                      controller: _notesController),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        ref.invalidate(
                            userLeaveRequestStreamProvider("userId"));
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color(0xFF00AEEF),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00AEEF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final userId =
                            Supabase.instance.client.auth.currentUser?.id;

                        if (userId == null ||
                            _selectedItem == null ||
                            _fromDay == null ||
                            _fromMonth == null ||
                            _fromYear == null ||
                            _toDay == null ||
                            _toMonth == null ||
                            _toYear == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please complete all required fields.")),
                          );
                          return;
                        }

                        final now = DateTime.now();
                        final startDate =
                            DateTime(_fromYear!, _fromMonth!, _fromDay!);
                        final endDate = DateTime(_toYear!, _toMonth!, _toDay!);

                        if (startDate
                            .isBefore(DateTime(now.year, now.month, now.day))) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Start date must not be in the past.")),
                          );
                          return;
                        }

                        if (endDate.isBefore(startDate)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "End date cannot be before start date.")),
                          );
                          return;
                        }

                        try {
                          await Supabase.instance.client
                              .from('leave_requests')
                              .insert({
                            'userID': userId,
                            'leaveType': _selectedItem,
                            'duration': _selectedTime,
                            'startDate': startDate.toIso8601String(),
                            'endDate': endDate.toIso8601String(),
                            'notes': _notesController.text.trim(),
                          }).select();

                          if (context.mounted) {
                            ref.invalidate(
                                userLeaveRequestStreamProvider(userId));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Leave request submitted.")),
                            );
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $error")),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hintText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          maxLines: 4,
          minLines: 4,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
  }) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        DropdownDatePicker(
          startYear: now.year,
          endYear: now.year + 5, // allow 5 years ahead, can change as needed
          onChangedDay: (val) {
            setState(() {
              if (label == 'From') {
                _fromDay = int.tryParse(val ?? '');
              } else {
                _toDay = int.tryParse(val ?? '');
              }
            });
          },
          onChangedMonth: (val) {
            setState(() {
              if (label == 'From') {
                _fromMonth = int.tryParse(val ?? '');
              } else {
                _toMonth = int.tryParse(val ?? '');
              }
            });
          },
          onChangedYear: (val) {
            setState(() {
              if (label == 'From') {
                _fromYear = int.tryParse(val ?? '');
              } else {
                _toYear = int.tryParse(val ?? '');
              }
            });
          },
          dayFlex: 2,
          monthFlex: 3,
          yearFlex: 3,
          isFormValidator: true,
          width: 10,
          hintTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
          boxDecoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
