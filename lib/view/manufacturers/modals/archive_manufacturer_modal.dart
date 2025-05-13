// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

//Base Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class ArchiveManufacturerModal extends ConsumerStatefulWidget {
  final int manufacturerID;
  final String manufacturerName;
  final bool isVisibleContext;

  const ArchiveManufacturerModal(
      {super.key,
      required this.manufacturerID,
      required this.manufacturerName,
      this.isVisibleContext = true});

  @override
  ConsumerState<ArchiveManufacturerModal> createState() =>
      _ArchiveManufacturerModalState();
}

class _ArchiveManufacturerModalState
    extends ConsumerState<ArchiveManufacturerModal> {
  bool _isArchiving = false;

  Future<void> _archiveItem() async {
    setState(() => _isArchiving = true);
    try {
      await ref
          .read(manufacturersNotifierProvider(widget.isVisibleContext).notifier)
          .updateManufacturerVisibility(
              manufacturerID: widget.manufacturerID, newIsActive: false);
      ToastManager().showToast(context,
          'Manufacturer "${widget.manufacturerName}" archived.', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      print("Error archiving manufacturer ${widget.manufacturerID}: $e");
      ToastManager().showToast(context, 'Failed to archive: $e', Colors.red);
      if (mounted) setState(() => _isArchiving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 450 : screenWidth * 0.9;
    const double dialogHeight = 210;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: containerWidth,
        height: dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Confirm Archive',
                  style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                    'Are you sure you want to archive\n"${widget.manufacturerName}"?',
                    style: const TextStyle(
                        fontFamily: 'NunitoSans', fontSize: 16, height: 1.4),
                    textAlign: TextAlign.center),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isArchiving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isArchiving
                          ? Container()
                          : const Icon(Icons.archive, size: 18),
                      label: _isArchiving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Archive'),
                      onPressed: _isArchiving ? null : _archiveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        textStyle: const TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold),
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
