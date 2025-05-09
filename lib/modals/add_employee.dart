// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:jcsd_flutter/backend/modules/employee/employee_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../api/global_variables.dart';

class AddEmployeeModal extends StatefulWidget {
  const AddEmployeeModal({super.key});

  @override
  _AddEmployeeModalState createState() => _AddEmployeeModalState();
}

class _AddEmployeeModalState extends State<AddEmployeeModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _middleInitial = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _country = TextEditingController();

  String _selectedRole = 'Employee';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final authResponse = await supabaseDB.auth.signUp(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        final user = authResponse.user;
        if (user == null) throw Exception("Sign-up failed.");

        await EmployeeService().registerNewEmployeeWithProfile(
          email: _email.text.trim(),
          password: _password.text.trim(),
          role: _selectedRole,
          isAdmin: _selectedRole == 'Admin',
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          middleInitial: _middleInitial.text.trim(),
          phone: _phone.text.trim(),
          birthday: _birthday.text.trim(),
          address: _address.text.trim(),
          city: _city.text.trim(),
          country: _country.text.trim(),
        );

        await supabaseDB.auth.resend(
          type: OtpType.signup,
          email: _email.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Employee added. Please inform them to verify their email.')),
        );
        if (mounted) Navigator.pop(context);
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Error: ${e.message}')),
        );
      } catch (e) {
        print('Error during employee registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _middleInitial.dispose();
    _password.dispose();
    _email.dispose();
    _phone.dispose();
    _birthday.dispose();
    _address.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;
    const double containerHeight = 570;

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(
                  color: Color(0xFF00AEEF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                        child: Column(
                          children: [
                            _buildTextField(
                                label: 'First Name', controller: _firstName),
                            _buildTextField(
                                label: 'Last Name', controller: _lastName),
                            _buildTextField(
                                label: 'Middle Initial',
                                controller: _middleInitial),
                            _buildTextField(
                                label: 'Password',
                                controller: _password,
                                isPassword: true),
                            _buildDropdownField(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          children: [
                            _buildTextField(label: 'Email', controller: _email),
                            _buildTextField(label: 'Phone', controller: _phone),
                            _buildDatePickerField(
                                label: 'Birthday', controller: _birthday),
                            _buildTextField(
                                label: 'Address', controller: _address),
                            _buildTextField(label: 'City', controller: _city),
                            _buildTextField(
                                label: 'Country', controller: _country),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(color: Color(0xFF00AEEF)),
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
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontFamily: 'NunitoSans')),
            const Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required field' : null,
          decoration: InputDecoration(
            hintText: 'Enter $label'.toString(),
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
  }) {
    return _buildTextField(
      label: label,
      controller: controller,
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text("Position", style: TextStyle(fontFamily: 'NunitoSans')),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: ['Admin', 'Employee'].map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedRole = value ?? 'Employee';
            });
          },
        ),
      ],
    );
  }
}
