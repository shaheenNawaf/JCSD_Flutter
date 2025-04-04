// unarchive_item.dart (Refactored)
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the inventory providers
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';

// Removed direct service import

class UnarchiveItemModal extends ConsumerStatefulWidget {
  final int itemID;

  const UnarchiveItemModal({super.key, required this.itemID});

  @override
  ConsumerState<UnarchiveItemModal> createState() => _UnarchiveItemModalState();
}

class _UnarchiveItemModalState extends ConsumerState<UnarchiveItemModal> {
  bool _isRestoring = false; // State for loading indicator

  // No need for initState just to copy itemID

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;
    // Adjust height slightly if needed
    const double containerHeight = 180; // Increased slightly for consistency

    // Determine which notifier instance to use (false for archive page context)
    const bool isVisibleContext = false;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox( // Use SizedBox for sizing
        width: containerWidth,
        height: containerHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header (No change needed) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: const Center(
                child: Text('Confirmation', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
              ),
            ),
            // --- Confirmation Text ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Are you sure you want to restore item ${widget.itemID}?', // Updated text
                  style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(), // Push buttons to bottom

            // --- Action Buttons ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Cancel Button ---
                  Expanded(
                    child: TextButton(
                      onPressed: _isRestoring ? null : () => Navigator.pop(context), // Disable while restoring
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Color(0xFF00AEEF))),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Color(0xFF00AEEF))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // --- Restore Button ---
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRestoring ? null : () async { // Disable while restoring
                        setState(() => _isRestoring = true); // Start loading

                        try {
                          // Call the notifier for the ARCHIVE context (false)
                          // Tell it to set visibility to TRUE (unarchive)
                          await ref.read(InventoryNotifierProvider(isVisibleContext).notifier)
                                   .setItemVisibility(widget.itemID, true); // true = unarchive

                          // Optional: Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Item ${widget.itemID} restored successfully!'), backgroundColor: Colors.green),
                          );

                          Navigator.pop(context); // Close dialog on success

                        } catch (err) {
                          print('Error restoring item ${widget.itemID}: $err');
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to restore item: $err'), backgroundColor: Colors.red),
                          );
                           // Reset loading state on error to allow retry
                           if (mounted) {
                             setState(() => _isRestoring = false);
                           }
                        }
                        // No finally needed here, handled in success/error paths
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Or Colors.green for restore action
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      // Show loading indicator or text
                      child: _isRestoring
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Restore', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white)),
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