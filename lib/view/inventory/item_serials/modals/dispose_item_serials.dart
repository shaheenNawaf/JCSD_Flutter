// lib/view/inventory/modals/dispose_serialized_item_modal.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

//Defauly Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//Item Serials Imports
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';

//User Feedback 
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class DisposeSerializedItemModal extends ConsumerStatefulWidget {
  final SerializedItem item; // The item to mark as disposed

  const DisposeSerializedItemModal({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<DisposeSerializedItemModal> createState() => _DisposeSerializedItemModalState();
}

class _DisposeSerializedItemModalState extends ConsumerState<DisposeSerializedItemModal> {
  bool _isProcessing = false; // Loading state for the button
  final String _disposeStatus = 'Disposed'; // Target status

  // Handles the status update to 'Disposed'
  Future<void> _disposeItem() async {
    setState(() => _isProcessing = true);

    try {
      // Call the notifier method to update the status
      await ref.read(serializedItemNotifierProvider(widget.item.prodDefID).notifier)
               .updateItemStatus(widget.item.serialNumber, _disposeStatus);

      ToastManager().showToast(context, 'Item "${widget.item.serialNumber}" marked as Disposed.', Colors.green);
      Navigator.pop(context); // Close dialog on success

    } catch (e, st) {
      print("Error disposing Serialized Item ${widget.item.serialNumber}: $e\n$st");
      ToastManager().showToast(context, 'Failed to update status: ${e.toString()}', Colors.red);
       if (mounted) {
         setState(() => _isProcessing = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 450 : screenWidth * 0.9;
    const double dialogHeight = 190; // Similar height to archive confirmation

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox(
        width: containerWidth,
        height: dialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Dialog Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: const BoxDecoration(
                color: Colors.redAccent, // Use a distinct color for disposal/warning
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Center(
                child: Text('Confirm Disposal', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
              ),
            ),

            // --- Confirmation Text ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Mark serial number\n"${widget.item.serialNumber}" as $_disposeStatus?\nThis action cannot be easily undone.',
                  style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 16, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),

            // --- Action Buttons ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isProcessing ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Colors.grey)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isProcessing ? Container() : const Icon(Icons.delete_forever, size: 18),
                      label: _isProcessing
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_disposeStatus), // Button text matches action
                      onPressed: _isProcessing ? null : _disposeItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // Warning color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                         textStyle: const TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold)
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
