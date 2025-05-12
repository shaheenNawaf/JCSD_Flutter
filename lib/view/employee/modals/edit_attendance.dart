import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_attendance.dart';


class EditAttendanceModal extends StatefulWidget  {
  final Map<String, dynamic> attendanceData;

  const EditAttendanceModal({super.key, required this.attendanceData});

  @override
  State<EditAttendanceModal> createState() => _EditAttendanceModalState();
}

class _EditAttendanceModalState extends State<EditAttendanceModal> {
  late TextEditingController checkInController;
  late TextEditingController checkOutController;

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
                  'Edit Service',
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
                  _buildTextField(
                    label: 'Checkin Time',
                    hintText: 'Enter service name',
                    controller: checkInController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Checkout Time',
                    hintText: 'Enter minimum price',
                    controller: checkOutController,
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
                      onPressed: ()  async {
                        final success = await updateAttendanceRecord(
                          context: context,
                          attendanceId: widget.attendanceData['id'].toString(),
                          newCheckInTime: checkInController.text.trim(),
                          newCheckOutTime: checkOutController.text.trim(),
                        );
                        
                        if (success) {
                          Navigator.pop(context, true);
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
}
