// ignore_for_file: library_private_types_in_public_api

//Packages
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/view/generic/dialogs/error_dialog.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jcsd_flutter/others/dropdown_data.dart';

//Page Imports
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/widgets/navbar.dart';

//Backend
import '../../../api/global_variables.dart';

class SignupPage2 extends StatefulWidget {
  const SignupPage2({super.key});

  @override
  _SignupPage2State createState() => _SignupPage2State();
}

class _SignupPage2State extends State<SignupPage2> {
  // Controllers for the input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController =
      TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Error string to display on the modal
  String? errorText;

  // To show a loading spinner
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabaseDB.auth.currentUser;
    if (user == null) return;

    final data = await supabaseDB
        .from('accounts')
        .select()
        .eq('userID', user.id)
        .single();
    print(user.id);
    setState(() {
      _firstNameController.text = data['firstName'] ?? '';
      _middleInitialController.text = data['middleName'] ?? '';
      _lastNameController.text = data['lastName'] ?? '';
      _addressController.text = data['address'] ?? '';
      _cityController.text = data['city'] ?? '';
      _provinceController.text = data['province'] ?? '';
      _regionController.text = data['region'] ?? '';
      _zipCodeController.text = data['zipCode'] ?? '';
      _contactNumberController.text = data['contactNumber'] ?? '';
      _emailController.text = data['email'] ?? '';
      _dobController.text = data['birthDate'] != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(data['birthDate']))
          : '';
    });
  }

  Future<void> _submit() async {
    setState(() => isLoading = true);

    final user = supabaseDB.auth.currentUser;
    if (user == null) return;

    final firstName = _firstNameController.text.trim();
    final middleInitial = _middleInitialController.text.trim();
    final lastName = _lastNameController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final province = _provinceController.text.trim();
    final region = _regionController.text.trim();
    final zipCode = _zipCodeController.text.trim();
    final contactNumber = _contactNumberController.text.trim();
    final dob = _dobController.text.trim();

    if ([
      firstName,
      lastName,
      address,
      city,
      province,
      region,
      zipCode,
      contactNumber,
      dob
    ].any((value) => value.isEmpty)) {
      setState(() {
        errorText = 'Please fill in all fields.';
        isLoading = false;
      });
      return;
    }

    try {
      final updatedData = AccountsData(
        userID: user.id,
        firstName: firstName,
        middleName: middleInitial,
        lastname: lastName,
        birthDate: DateTime.parse(dob),
        address: address,
        city: city,
        province: province,
        region: region,
        zipCode: zipCode,
        contactNumber: contactNumber,
        email: _emailController.text,
      );

      await supabaseDB
          .from('accounts')
          .update(updatedData.toJson())
          .eq('userID', user.id);

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Update failed: $e');
      setState(() {
        errorText = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }

  //Validators for each input
  String? numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Validation Error',
          content: 'Please enter a number',
        ),
      );
      return '';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Validation Error',
          content: 'Only numbers are allowed',
        ),
      );
      return '';
    }
    return null;
  }

  String? textValidator(String? value) {
    if (value == null || value.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Validation Error',
          content: 'Please enter some text',
        ),
      );
      return '';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Validation Error',
          content: 'Only letters and spaces are allowed',
        ),
      );
      return '';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Empty Email field',
          content: 'Please enter an email',
        ),
      );
      return '';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Validation Error',
          content: 'Please enter a valid email',
        ),
      );
      return '';
    }
    return null;
  }

  String? contactNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Empty Contact Number field',
          content: 'Please enter a contact number',
        ),
      );
      return '';
    }
    if (!RegExp(r'^((\+639|09)\d{9})$').hasMatch(value)) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Validation Error',
          content: 'Please enter a valid contact number',
        ),
      );
      return '';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isMobileView = screenWidth < 600;
    return Scaffold(
      appBar: const Navbar(activePage: 'register'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double containerWidth =
                      screenWidth > 600 ? 700 : screenWidth * 0.9;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: containerWidth,
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Almost there!',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'sign-up to fully access the site features',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (isMobileView)
                                  Column(
                                    children: [
                                      buildTextField(
                                          controller: _firstNameController,
                                          label: 'First Name',
                                          hintText: 'Enter your first name',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _addressController,
                                          label: 'Address',
                                          hintText: 'Enter your address',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _middleInitialController,
                                          label: 'Middle Initial (Optional)',
                                          hintText: 'Enter your middle initial',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _regionController,
                                          label: 'Region',
                                          hintText: 'Enter your region',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _provinceController,
                                          label: 'Province',
                                          hintText: 'Enter your province',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _lastNameController,
                                          label: 'Last Name',
                                          hintText: 'Enter your last name',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _cityController,
                                          label: 'City',
                                          hintText: 'Enter your city',
                                          validator: textValidator),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                        controller: _zipCodeController,
                                        label: 'Zip Code',
                                        hintText: 'Enter your zipcode',
                                        validator: numberValidator,
                                      ),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                        controller: _dobController,
                                        label: 'Date of Birth',
                                        hintText: 'Enter your date of birth',
                                      ),
                                      const SizedBox(height: 10),
                                      buildTextField(
                                          controller: _contactNumberController,
                                          label: 'Contact Number',
                                          hintText: 'Enter your contact number',
                                          validator: contactNumberValidator),
                                    ],
                                  )
                                else
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: buildTextField(
                                              controller: _firstNameController,
                                              label: 'First Name',
                                              hintText: 'Enter your first name',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 1,
                                            child: buildTextField(
                                              controller: _addressController,
                                              label: 'Address',
                                              hintText: 'Enter your address',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: buildTextField(
                                              controller:
                                                  _middleInitialController,
                                              label:
                                                  'Middle Initial (Optional)',
                                              hintText:
                                                  'Enter your middle initial',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: buildTextField(
                                                    controller:
                                                        _regionController,
                                                    label: 'Region',
                                                    hintText:
                                                        'Enter your region',
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  flex: 1,
                                                  child: buildTextField(
                                                    controller:
                                                        _provinceController,
                                                    label: 'Province',
                                                    hintText:
                                                        'Enter your province',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: buildTextField(
                                              controller: _lastNameController,
                                              label: 'Last Name',
                                              hintText: 'Enter your last name',
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: buildTextField(
                                                    controller: _cityController,
                                                    label: 'City',
                                                    hintText: 'Enter your city',
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  flex: 1,
                                                  child: buildTextField(
                                                    controller:
                                                        _zipCodeController,
                                                    label: 'Zip Code',
                                                    hintText:
                                                        'Enter your zipcode',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: buildTextField(
                                              controller: _dobController,
                                              label: 'Date of Birth',
                                              hintText: 'Tap to pick the date',
                                              isDateOfBirthField: true,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 1,
                                            child: buildTextField(
                                              controller:
                                                  _contactNumberController,
                                              label: 'Contact Number',
                                              hintText:
                                                  'Enter your contact number',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 20),
                                if (errorText != null)
                                  Text(
                                    errorText!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AEEF),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: isLoading ? null : _submit,
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            'Register',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an Account?',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/login');
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Color(0xFF00AEEF),
                                          fontFamily: 'Nunito',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isDateOfBirthField = false, // Add a flag for date of birth field
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AutoSizeText(
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
        //Added Conditional rendering for the DOB
        if (isDateOfBirthField)
          GestureDetector(
            onTap: () async {
              // Show the date picker
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );

              //For the controller to pick up the data
              if (pickedDate != null) {
                controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              }
            },
            child: AbsorbPointer(
              // Prevent the TextField from being focused
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
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
            ),
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
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
