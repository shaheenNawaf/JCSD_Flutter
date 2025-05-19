import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_attendance.dart';

class EditAttendanceModal extends StatefulWidget {
  final Map<String, dynamic> attendanceData;

  const EditAttendanceModal({super.key, required this.attendanceData});

  @override
  State<EditAttendanceModal> createState() => _EditAttendanceModalState();
}

class _EditAttendanceModalState extends State<EditAttendanceModal> {
  late TextEditingController checkInController;
  late TextEditingController checkOutController;
  final _formKey = GlobalKey<FormState>();
  String? checkInError;
  String? checkOutError;

  @override
  void initState() {
    super.initState();
    checkInController = TextEditingController(
      text: widget.attendanceData['check_in_time'] != null
          ? DateFormat('HH:mm:ss').format(DateTime.parse(widget.attendanceData['check_in_time']))
          : '',
    );
    checkOutController = TextEditingController(
      text: widget.attendanceData['check_out_time'] != null
          ? DateFormat('HH:mm:ss').format(DateTime.parse(widget.attendanceData['check_out_time']))
          : '',
    );
  }

  @override
  void dispose() {
    checkInController.dispose();
    checkOutController.dispose();
    super.dispose();
  }

  bool _validateTimeFormat(String time) {
    if (time.isEmpty) return true; // Allow empty fields
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00AEEF),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      controller.text = formattedTime;
      setState(() {
        if (controller == checkInController) {
          checkInError = null;
        } else {
          checkOutError = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;
    const double containerHeight = 400;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Form(
        key: _formKey,
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
                    'Edit Attendance',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeField(
                      label: 'Check-in Time',
                      hintText: 'HH:MM:SS',
                      controller: checkInController,
                      errorText: checkInError,
                      onTap: () => _selectTime(checkInController),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeField(
                      label: 'Check-out Time',
                      hintText: 'HH:MM:SS',
                      controller: checkOutController,
                      errorText: checkOutError,
                      onTap: () => _selectTime(checkOutController),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
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
                          // Validate time formats
                          setState(() {
                            checkInError = checkInController.text.isNotEmpty && !_validateTimeFormat(checkInController.text)
                                ? 'Invalid time format (HH:MM:SS)'
                                : null;
                            checkOutError = checkOutController.text.isNotEmpty && !_validateTimeFormat(checkOutController.text)
                                ? 'Invalid time format (HH:MM:SS)'
                                : null;
                          });

                          if ((checkInError == null && checkOutError == null) && 
                              (checkInController.text.isNotEmpty || checkOutController.text.isNotEmpty)) {
                            final success = await updateAttendanceRecord(
                              context: context,
                              attendanceId: widget.attendanceData['id'].toString(),
                              newCheckInTime: checkInController.text.trim(),
                              newCheckOutTime: checkOutController.text.trim(),
                            );
                            
                            if (success) {
                              Navigator.pop(context, true);
                            }
                          } else if (checkInController.text.isEmpty && checkOutController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter at least one time value')),
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
                          'Update',
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? errorText,
    required VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                ),
                errorText: errorText,
                suffixIcon: const Icon(Icons.access_time),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty && !_validateTimeFormat(value)) {
                  return 'Invalid time format (HH:MM:SS)';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}