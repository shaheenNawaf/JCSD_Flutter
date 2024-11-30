// ignore_for_file: library_private_types_in_public_api

//Packages for Usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Pages
import 'package:jcsd_flutter/backend/services/suppliers_service.dart';

// Suppliers
import 'package:jcsd_flutter/backend/models/suppliers_data.dart';
import 'package:jcsd_flutter/backend/providers/suppliers_state.dart';
class ArchiveSupplierModal extends ConsumerStatefulWidget {
  final SuppliersData supplierData;
  final int supplierID;

  const ArchiveSupplierModal({super.key, required this.supplierData, required this.supplierID});

  @override
  ConsumerState<ArchiveSupplierModal> createState() => _ArchiveSupplierModalState();
}

class _ArchiveSupplierModalState extends ConsumerState<ArchiveSupplierModal> {
  late int _supplierID;
  late SuppliersData _supplierData;

  @override
  void initState(){
    super.initState();
    print('Archive Supplier - initState()');
    _supplierID = widget.supplierID;
    _supplierData = widget.supplierData;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;
    const double containerHeight = 160;

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
                  'Confirmation',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Are you sure you want to archive supplier?',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
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
                        ref.invalidate(fetchAvailableSuppliers);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                        print('Archive Item - Save changes');
                        try{
                          final SuppliersService updateVisibility = SuppliersService();
                          await updateVisibility.updateSupplierVisbility(_supplierID, false);

                          print('Successfully hid the item. ${_supplierData.supplierName}');
                        }catch(err){
                          print('Error archiving an item. $_supplierData');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00AEEF),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
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
          ],
        ),
      ),
    );
  }
}
