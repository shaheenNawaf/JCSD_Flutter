// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_data.dart';

class EditEmployeeDetailsModal extends ConsumerStatefulWidget {
  final EmployeeData emp;

  const EditEmployeeDetailsModal({super.key, required this.emp});

  @override
  ConsumerState<EditEmployeeDetailsModal> createState() =>
      _EditEmployeeDetailsModalState();
}

class _EditEmployeeDetailsModalState
    extends ConsumerState<EditEmployeeDetailsModal> {
  late TextEditingController _salaryController;
  late String _selectedRole;
  late String _selectedPosition;

  @override
  void initState() {
    super.initState();
    _salaryController =
        TextEditingController(text: widget.emp.monthlySalary.toString());
    _selectedRole = widget.emp.companyRole;
    _selectedPosition = widget.emp.position;
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final targetUserId = widget.emp.userID;

      // Only include companyRole and isAdmin if not editing own role
      final isEditingSelf = currentUserId == targetUserId;

      final newSalary = double.tryParse(_salaryController.text.trim()) ?? 15000;

      final Map<String, dynamic> updatedData = {
        'monthlySalary': newSalary,
        'position': _selectedPosition,
      };

      if (!isEditingSelf) {
        updatedData.addAll({
          'companyRole': _selectedRole,
          'isAdmin': _selectedRole == 'Admin',
        });
      } else if (_selectedRole != widget.emp.companyRole) {
        _showNotification(context, "You cannot change your own company role.");
        return;
      }

      await Supabase.instance.client
          .from('employee')
          .update(updatedData)
          .eq('employeeID', widget.emp.employeeID);

      if (!mounted) return;

      final updatedEmp = EmployeeData(
        employeeID: widget.emp.employeeID,
        userID: widget.emp.userID,
        isAdmin: isEditingSelf ? widget.emp.isAdmin : _selectedRole == 'Admin',
        position: _selectedPosition,
        companyRole: isEditingSelf ? widget.emp.companyRole : _selectedRole,
        isActive: widget.emp.isActive,
        createDate: widget.emp.createDate,
        monthlySalary: newSalary,
      );

      Navigator.pop(context, updatedEmp);
      _showNotification(context, 'Updated successfully.');
    } catch (e) {
      debugPrint('Error updating: $e');
      _showNotification(context, 'Update failed.');
    }
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 300 ? 400 : screenWidth * 0.9;
    const double containerHeight = 370;

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                'Edit Employee Details',
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
                _buildTextField(
                  label: 'Monthly Salary',
                  hintText: 'Enter monthly salary',
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'System Controls',
                  hintText: 'Select role',
                  value: _selectedRole,
                  items: const ['Employee', 'Admin'],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRole = value ?? 'Employee';
                    });
                  },
                ),
                _buildDropdownField(
                  label: 'Position',
                  hintText: 'Select position',
                  value: _selectedPosition,
                  items: const [
                    'Computer Repair Technician',
                    'IT Support Technician',
                    'Field Service Technician'
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedPosition = value ?? 'Computer Repair Technician';
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Save',
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
        ]),
      ),
    );
  }
}
