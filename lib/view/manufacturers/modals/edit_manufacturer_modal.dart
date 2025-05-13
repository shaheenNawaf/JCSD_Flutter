// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

//Base Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';

class EditManufacturerModal extends ConsumerStatefulWidget {
  final ManufacturersData manufacturerData;
  final bool isVisibleContext;

  const EditManufacturerModal(
      {super.key,
      required this.manufacturerData,
      this.isVisibleContext = true});

  @override
  ConsumerState<EditManufacturerModal> createState() =>
      _EditManufacturerModalState();
}

class _EditManufacturerModalState extends ConsumerState<EditManufacturerModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final mfg = widget.manufacturerData;
    _nameController = TextEditingController(text: mfg.manufacturerName);
    _emailController = TextEditingController(text: mfg.manufacturerEmail);
    _contactController = TextEditingController(text: mfg.contactNumber ?? '');
    _addressController = TextEditingController(text: mfg.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ToastManager().showToast(context, 'Please fix errors.', Colors.orange);
      return;
    }
    setState(() => _isSaving = true);

    try {
      await ref
          .read(manufacturersNotifierProvider(widget.isVisibleContext).notifier)
          .updateManufacturer(
            manufacturerID: widget.manufacturerData.manufacturerID,
            manufacturerName: _nameController.text.trim(),
            manufacturerEmail: _emailController.text.trim(),
            contactNumber: _contactController.text.trim(),
            address: _addressController.text.trim(),
          );
      ToastManager().showToast(
          context, 'Manufacturer updated successfully!', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      print("Error updating manufacturer: $e");
      ToastManager()
          .showToast(context, 'Failed to update manufacturer: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 700 ? 600 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: containerWidth,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: const BoxDecoration(
                    color: Color(0xFF00AEEF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10))),
                child: Center(
                    child: Text(
                        'Edit Manufacturer (ID: ${widget.manufacturerData.manufacturerID})',
                        style: const TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white))),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(
                          label: 'Manufacturer Name',
                          hintText: 'e.g., Intel, AMD, Dell',
                          controller: _nameController,
                          isRequired: true),
                      const SizedBox(height: 15),
                      _buildTextField(
                          label: 'Email Address',
                          hintText: 'e.g., contact@intel.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true,
                          validator: (v) => (v == null ||
                                  v.isEmpty ||
                                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(v))
                              ? 'Valid email required'
                              : null),
                      const SizedBox(height: 15),
                      _buildTextField(
                          label: 'Contact Number',
                          hintText: 'e.g., 09123456789',
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          isRequired: true,
                          validator: (v) => (v == null ||
                                  v.isEmpty ||
                                  !RegExp(r'^(0\d{10}|\+?63?\d{10})$')
                                      .hasMatch(v))
                              ? 'Valid PH number required'
                              : null),
                      const SizedBox(height: 15),
                      _buildTextField(
                          label: 'Address',
                          hintText: 'Enter full address',
                          controller: _addressController,
                          maxLines: 3,
                          isRequired: true),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                        child: TextButton(
                            onPressed:
                                _isSaving ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(
                                        color: Color(0xFF00AEEF)))),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00AEEF))))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton.icon(
                            icon: _isSaving
                                ? Container()
                                : const Icon(Icons.save, size: 18),
                            label: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Save Changes'),
                            onPressed: _isSaving ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00AEEF),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                textStyle: const TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hintText,
      required TextEditingController controller,
      int maxLines = 1,
      TextInputType? keyboardType,
      bool isRequired = false,
      String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label),
        if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))
      ]),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
                fontSize: 12)),
        validator: validator ??
            (v) => (isRequired && (v == null || v.trim().isEmpty))
                ? '$label is required'
                : null,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ]);
  }
}
