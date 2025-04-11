// ignore_for_file: library_private_types_in_public_api

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//BE Imports
import 'package:jcsd_flutter/backend/modules/services/jcsd_services.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/view/generic/dialogs/error_dialog.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class AddServiceModal extends ConsumerStatefulWidget{
  const AddServiceModal({super.key});

  @override
  ConsumerState<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends ConsumerState<AddServiceModal> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  //Validators
    String? numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only numbers are allowed';
    }
    return null;
  }

  String? textValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Only letters and spaces are allowed';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? contactNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a contact number';
    }
    if (!RegExp(r'^((\+639|09)\d{9})$').hasMatch(value)) {
      return 'Please enter a valid contact number';
    }
    return null;
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
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
                  'Services Form',
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
                    label: 'Service Name',
                    hintText: 'Enter service name',
                    controller: _serviceNameController,
                    validator: textValidator,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Minimum Price',
                    hintText: 'Enter amount',
                    controller: _minPriceController,
                    validator: numberValidator,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Maximum Price',
                    hintText: 'Enter amount',
                    validator: numberValidator,
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
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
                        try{  
                          if(_serviceNameController.text.isEmpty && _maxPriceController.text.isEmpty && _minPriceController.text.isEmpty){
                            showDialog(
                              context: context, 
                              builder: (context) => const ErrorDialog(
                                title: 'Empty fields are detected', 
                                content: 'Please fill in the required fields.')
                              );
                          }else if (_serviceNameController.text.isEmpty){ 
                            showDialog(
                              context: context, 
                              builder: (context) => const ErrorDialog(
                                title: 'Service Name is empty.', 
                                content: 'Please fill in the required fields.')
                              );
                          }else if (_maxPriceController.text.isEmpty){ 
                            showDialog(
                              context: context, 
                              builder: (context) => const ErrorDialog(
                                title: 'Max Price field is empty.', 
                                content: 'Please fill in the required fields.')
                              );
                          }else if (_minPriceController.text.isEmpty){ 
                            showDialog(
                              context: context, 
                              builder: (context) => const ErrorDialog(
                                title: 'Min Price field is empty.', 
                                content: 'Please fill in the required fields.')
                              );
                          }else{
                            final addNewService = JcsdServices();

                            String serviceName = _serviceNameController.text;
                            double minPrice = double.parse(_minPriceController.text);
                            double maxPrice = double.parse(_maxPriceController.text);

                            await addNewService.addService(serviceName, minPrice, maxPrice);

                            //Force refresh
                            ref.invalidate(fetchAvailableServices);
                            ToastManager().showToast(context, 'Service "$serviceName" added successfully!', const Color.fromARGB(255, 0, 143, 19));
                            Navigator.pop(context); // To be updated
                          }
                        }catch(err){
                          ToastManager().showToast(context, 'Error adding service. $err', const Color.fromARGB(255, 255, 0, 0));
                          print('Error adding service. $err');
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
    required TextInputType keyboardType,
    String? Function(String?)? validator,
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
