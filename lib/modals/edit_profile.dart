// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/accounts/accounts_data.dart';
import 'package:jcsd_flutter/others/dropdown_data.dart';
import '../../../api/global_variables.dart';

class EditProfileModal extends ConsumerStatefulWidget {
  final AccountsData account;

  const EditProfileModal({super.key, required this.account});

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal> {
  String? selectedRegion;
  String? selectedProvince;
  String? selectedCity;

  List<String> get regionList =>
      dropdownData.map((r) => r['name'].toString()).toList();

  List<String> get provinceList {
    if (selectedRegion == null) return [];

    final Map<String, dynamic>? region =
        dropdownData.cast<Map<String, dynamic>>().firstWhere(
              (r) => r['name'] == selectedRegion,
              orElse: () => {},
            );

    final List provinces = region?['province'] as List? ?? [];
    return provinces
        .cast<Map<String, dynamic>>()
        .map((p) => p['province'].toString())
        .toList();
  }

  List<String> get cityList {
    if (selectedRegion == null || selectedProvince == null) return [];

    final Map<String, dynamic>? region =
        dropdownData.cast<Map<String, dynamic>>().firstWhere(
              (r) => r['name'] == selectedRegion,
              orElse: () => {},
            );

    final List provinces = region?['province'] as List? ?? [];
    final Map<String, dynamic> province =
        provinces.cast<Map<String, dynamic>>().firstWhere(
              (p) => p['province'] == selectedProvince,
              orElse: () => {},
            );

    final List cities = province['cities'] as List? ?? [];
    return cities
        .cast<Map<String, dynamic>>()
        .map((c) => c['city'].toString())
        .toList();
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
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
            const Text('*', style: TextStyle(color: Colors.red))
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select',
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

  // final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  late TextEditingController _regionController;
  late TextEditingController _provinceController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;

  String? errorText;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _firstNameController = TextEditingController(text: a.firstName);
    _lastNameController = TextEditingController(text: a.lastname);
    _middleNameController = TextEditingController(text: a.middleName);
    _emailController = TextEditingController(text: a.email);
    _phoneController = TextEditingController(text: a.contactNumber);
    _birthdayController = TextEditingController(
        text: a.birthDate?.toIso8601String().split('T')[0] ?? '');
    _addressController = TextEditingController(text: a.address);
    selectedRegion = a.region.isNotEmpty ? a.region : null;
    selectedProvince = a.province.isNotEmpty ? a.province : null;
    selectedCity = a.city.isNotEmpty ? a.city : null;

    _zipCodeController = TextEditingController(text: a.zipCode);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _regionController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final updatedAccount = AccountsData(
        userID: widget.account.userID,
        firstName: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        email: _emailController.text.trim(),
        contactNumber: _phoneController.text.trim(),
        birthDate: _birthdayController.text.isNotEmpty
            ? DateTime.tryParse(_birthdayController.text)
            : null,
        address: _addressController.text.trim(),
        city: selectedCity?.trim() ?? '',
        province: selectedProvince?.trim() ?? '',
        region: selectedRegion?.trim() ?? '',
        zipCode: widget.account.zipCode,
      );

      await supabaseDB
          .from('accounts')
          .update(updatedAccount.toJson())
          .eq('userID', widget.account.userID);

      Navigator.pop(context, updatedAccount);
    } catch (e) {
      debugPrint("Update error: \$e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 700 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                  'Edit Profile',
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                'First Name', _firstNameController)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildTextField('Phone', _phoneController)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                'Last Name', _lastNameController)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            'Birthday',
                            _birthdayController,
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _birthdayController.text =
                                    picked.toIso8601String().split('T')[0];
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                'Middle Initial', _middleNameController)),
                        const SizedBox(width: 10),
                        Expanded(
                            child:
                                _buildTextField('Address', _addressController)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField('Email', _emailController)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                              'Region', selectedRegion, regionList, (value) {
                            setState(() {
                              selectedRegion = value;
                              selectedProvince = null;
                              selectedCity = null;
                            });
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                              'Province', selectedProvince, provinceList,
                              (value) {
                            setState(() {
                              selectedProvince = value;
                              selectedCity = null;
                            });
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown('City', selectedCity, cityList,
                              (value) {
                            setState(() {
                              selectedCity = value;
                            });
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                'Zip Code', _zipCodeController)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDropdownField()),
                        // const SizedBox(width: 340),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side:
                                    const BorderSide(color: Color(0xFF00AEEF)),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false, VoidCallback? onTap, bool isPassword = false}) {
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
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: 'Enter \$label'.toLowerCase(),
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

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text("Status", style: TextStyle(fontFamily: 'NunitoSans')),
            Text('*', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          hint: const Text(
            'Select status',
            style: TextStyle(
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
          items: ['Active', 'Inactive'].map((String item) {
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
          onChanged: (value) {},
        ),
      ],
    );
  }
}
