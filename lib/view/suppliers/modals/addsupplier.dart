// lib/view/suppliers/modals/addsupplier.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- UPDATED: Import Notifier & State ---
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_notifiers.dart';
// --- Removed Service import ---
import 'package:jcsd_flutter/view/generic/dialogs/error_dialog.dart'; // Keep for potential validation errors
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class AddSupplierModal extends ConsumerStatefulWidget {
  const AddSupplierModal({super.key});

  @override
  ConsumerState<AddSupplierModal> createState() => _AddSupplierModalState();
}

class _AddSupplierModalState extends ConsumerState<AddSupplierModal> {
  final _formKey = GlobalKey<FormState>(); // Keep form key
  bool _isSaving = false; // Keep loading state

  // Keep controllers
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _supplierNameController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Handles form submission using the notifier
  Future<void> _submitForm() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      // Consider using ToastManager here too for consistency
      showDialog(context: context, builder: (context) => const ErrorDialog(title: 'Input Error', content: 'Please fill in all required fields.'));
      return;
    }

    setState(() => _isSaving = true); // Show loading

    try {
      // Call the addSupplier method on the notifier for the active list (true)
      await ref.read(suppliersNotifierProvider(true).notifier).addSupplier(
        supplierName: _supplierNameController.text.trim(),
        supplierEmail: _emailController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        address: _addressController.text.trim(),
      );

      ToastManager().showToast(context, 'Supplier "${_supplierNameController.text}" added successfully!', Colors.green);
      Navigator.pop(context); // Close on success

    } catch (err) {
      print('Error adding supplier: $err');
      ToastManager().showToast(context, 'Error adding supplier. $err', Colors.red);
      // Error is handled, loading state will be reset in finally
    } finally {
      if (mounted) {
        setState(() => _isSaving = false); // Hide loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 300 ? 400 : screenWidth * 0.9;
    const double containerHeight = 480; // Keep height or adjust if needed

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox( // Use SizedBox for sizing
        width: containerWidth,
        height: containerHeight,
        child: Form( // Wrap content in Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Keep existing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(color: Color(0xFF00AEEF), borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                child: const Center(child: Text('Supplier Form', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white))),
              ),
              // Form Fields (Keep existing structure)
              Expanded( // Allow form fields to take available space and potentially scroll
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(label: 'Supplier Name', hintText: 'Enter supplier name', controller: _supplierNameController, isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Address', hintText: 'Enter supplier address', controller: _addressController, isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Contact Number', hintText: 'Enter supplier contact number', controller: _contactNumberController, keyboardType: TextInputType.phone, isRequired: true,
                        validator: (v) => (v == null || v.isEmpty || !RegExp(r'^(0\d{10}|\+?63?\d{10})$').hasMatch(v)) ? 'Valid PH number required' : null, // Updated regex slightly
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Email', hintText: 'Enter supplier email', controller: _emailController, keyboardType: TextInputType.emailAddress, isRequired: true,
                        validator: (v) => (v == null || v.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) ? 'Valid email required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              // Action Buttons (Keep existing structure)
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0), // Adjust padding if needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Color(0xFF00AEEF)))),
                        child: const Text('Cancel', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Color(0xFF00AEEF))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm, // Call updated submit function
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AEEF), padding: const EdgeInsets.symmetric(vertical: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                        child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Submit', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white)),
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

  // Reusable text field builder (Keep existing)
  Widget _buildTextField({required String label, required String hintText, required TextEditingController controller, String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [ Text(label), if (isRequired) const Text(' *', style: TextStyle(color: Colors.red))]),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ?? (value) { // Default required validator
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validate on change
          decoration: InputDecoration(hintText: hintText, border: const OutlineInputBorder(), hintStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w300, fontSize: 12), contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0)),
        ),
      ],
    );
  }
}
