// ignore_for_file: library_private_types_in_public_api

//Base Imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class EditItemTypeModal extends ConsumerStatefulWidget {
  final ItemTypesData typeData;
  final int typeID;

  const EditItemTypeModal({
    super.key,
    required this.typeData,
    required this.typeID,
  });

  @override
  ConsumerState<EditItemTypeModal> createState() => _EditItemTypeModalState();
}

class _EditItemTypeModalState extends ConsumerState<EditItemTypeModal> {
  // Default Input
  final TextEditingController _typeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    ItemTypesData typesData = widget.typeData;
    _typeNameController.text = typesData.itemType;
    _descriptionController.text = typesData.itemDescription;
  }

  @override
  void dispose() {
    _typeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;
    const double containerHeight = 320;

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
                  'Edit Item Type',
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
                    label: 'Type Name',
                    hintText: 'Enter item type name',
                    controller: _typeNameController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description',
                    hintText: 'Enter description',
                    controller: _descriptionController,
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
                          final ItemtypesService updateService = ItemtypesService();
                          
                          String typeName = _typeNameController.text;
                          String typeDescription = _descriptionController.text;

                          await updateService.updateItemDetails(typeName, typeDescription, widget.typeID);
                          print(widget.typeID);
                          ToastManager().showToast(context, 'Item "$typeName" edited successfully!', const Color.fromARGB(255, 0, 143, 19));
                        }catch(err){
                          ToastManager().showToast(context, 'Error in updating item type. $err', const Color.fromARGB(255, 255, 0, 0));
                          print('Error in updating item type. $err');
                        }
                        refreshTables();
                        Navigator.pop(context);
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

  void refreshTables(){
    ref.invalidate(fetchActiveTypes);
    ref.invalidate(fetchArchivedTypes);
  }
}
