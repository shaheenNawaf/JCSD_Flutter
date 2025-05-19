// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/services/jcsd_services.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/services/services_data.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class EditServiceModal extends ConsumerStatefulWidget {
  final ServicesData servicesData;
  final int serviceID;

  const EditServiceModal({
    super.key,
    required this.serviceID,
    required this.servicesData,
  });

  @override
  ConsumerState<EditServiceModal> createState() => _EditServiceModalState();
}

class _EditServiceModalState extends ConsumerState<EditServiceModal> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ServicesData _serviceData = widget.servicesData;

    _serviceNameController.text = _serviceData.serviceName;
    _maxPriceController.text = _serviceData.maxPrice.toString();
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
                    label: 'Service Name',
                    hintText: 'Enter service name',
                    controller: _serviceNameController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Minimum Price',
                    hintText: 'Enter minimum price',
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Maximum Price',
                    hintText: 'Enter Maximum price',
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
                        try {
                          int serviceID = widget.serviceID;
                          String serviceName = _serviceNameController.text;
                          double minPrice =
                              double.parse(_minPriceController.text);
                          double maxPrice =
                              double.parse(_maxPriceController.text);

                          final editService = JcsdServices();
                          await editService.updateService(
                              serviceID, serviceName, minPrice, maxPrice);

                          ref.invalidate(fetchAvailableServices);
                          Navigator.pop(context);
                          ToastManager().showToast(
                              context,
                              'Service "$serviceName" edited successfully!',
                              const Color.fromARGB(255, 0, 143, 19));
                        } catch (err) {
                          ToastManager().showToast(
                              context,
                              'Error editing service. $err',
                              const Color.fromARGB(255, 255, 0, 0));
                          print('Error editing service. $err');
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
