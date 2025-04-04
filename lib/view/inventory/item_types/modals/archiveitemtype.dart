// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Things
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_state.dart';
import 'package:jcsd_flutter/view/generic/notification.dart';

class ArchiveItemTypeModal extends ConsumerStatefulWidget {
  final int typeID;

  const ArchiveItemTypeModal(
      {super.key, required this.typeID});

  @override
  ConsumerState<ArchiveItemTypeModal> createState() => _ArchiveItemTypeModalState();
}

class _ArchiveItemTypeModalState extends ConsumerState<ArchiveItemTypeModal> {
  late int _intItemTypeID;

  @override
  void initState() {
    super.initState();
    _intItemTypeID = widget.typeID;
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
                  'Do you want to archive this item type?',
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
                        refreshTables();
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
                        try {
                          final ItemtypesService updateVisibility = ItemtypesService();
                          await updateVisibility.updateTypeVisibility(_intItemTypeID, false);

                          print('Successfully ARCHIVED: $_intItemTypeID');
                          ToastManager().showToast(context, 'Item Type archived successfully!', Color.fromARGB(255, 0, 143, 19));
                        } catch (err, stackTrace) {
                          ToastManager().showToast(context, 'Archived Item Type failed. $err -- $stackTrace', Color.fromARGB(255, 0, 143, 19));
                          print('Archived Item Type failed. $err -- $stackTrace');
                        }
                        refreshTables();
                        Navigator.pop(context);
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

  void refreshTables(){
    ref.invalidate(fetchActiveTypes);
    ref.invalidate(fetchArchivedTypes);
  }
}
