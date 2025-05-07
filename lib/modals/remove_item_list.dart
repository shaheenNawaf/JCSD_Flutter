import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart'; // For bookingDetailNotifierProvider
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart'; // For ToastManager

class RemoveItemModal extends ConsumerStatefulWidget {
  final int bookingId;
  final int bookingItemId; // The ID of the record in the 'booking_items' table
  final String itemName; // Name or serial of the item for display

  const RemoveItemModal({
    super.key,
    required this.bookingId,
    required this.bookingItemId,
    required this.itemName,
  });

  @override
  ConsumerState<RemoveItemModal> createState() => _RemoveItemModalState();
}

class _RemoveItemModalState extends ConsumerState<RemoveItemModal> {
  bool _isRemoving = false;

  Future<void> _removeItemFromBooking() async {
    setState(() => _isRemoving = true);
    try {
      await ref
          .read(bookingDetailNotifierProvider(widget.bookingId).notifier)
          .removeItem(widget.bookingItemId);

      ToastManager().showToast(context,
          'Item "${widget.itemName}" removed successfully!', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      ToastManager().showToast(
          context, 'Failed to remove item: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isRemoving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: Container(
        width: containerWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 239, 0, 0),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  'Confirm Removal',
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
              child: Center(
                child: Text(
                  'Are you sure you want to remove "${widget.itemName}" from this booking?',
                  style: const TextStyle(
                    fontFamily: 'NunitoSans',
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isRemoving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 158, 158, 158),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 80, 80, 80),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRemoving ? null : _removeItemFromBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 239, 0, 0),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: _isRemoving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Remove',
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
