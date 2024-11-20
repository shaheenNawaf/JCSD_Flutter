// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AddEmployeeModal extends StatefulWidget {
  const AddEmployeeModal({super.key});

  @override
  _AddEmployeeModalState createState() => _AddEmployeeModalState();
}

class _AddEmployeeModalState extends State<AddEmployeeModal> {
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;
    const double containerHeight = 550;

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
                  'Add Employee',
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
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'First Name',
                            hintText: 'Enter first name',
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Last Name',
                            hintText: 'Enter last name',
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Middle Initial',
                            hintText: 'Enter middle initial',
                          ),
                          const SizedBox(height: 8),
                          _buildDatePickerField(
                            label: 'Birthday',
                            controller: _birthdayController,
                            onTap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 8),
                          _buildDropdownField(
                            onChanged: (String? value) {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildTextField(
                            label: 'Email',
                            hintText: 'Enter email',
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Phone',
                            hintText: 'Enter phone number',
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Address',
                            hintText: 'Enter address',
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'City',
                            hintText: 'Enter city ',
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Country',
                            hintText: 'Enter country',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
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

  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
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
          maxLines: maxLines,
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

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
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
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: const InputDecoration(
            hintText: 'Enter birthday',
            border: OutlineInputBorder(),
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Position",
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
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
          hint: const Text(
            'Select position',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          dropdownColor: Colors.white,
          items: ['Admin', 'Employee'].map((String item) {
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
}
