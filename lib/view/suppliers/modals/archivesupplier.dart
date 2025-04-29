// lib/view/suppliers/modals/archivesupplier.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- UPDATED: Import Notifier & State ---
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_notifiers.dart';
// --- Removed Service import ---
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';

class ArchiveSupplierModal extends ConsumerStatefulWidget {
  final SuppliersData supplierData;
  // final int supplierID; // ID is inside supplierData

  const ArchiveSupplierModal({super.key, required this.supplierData}); // Simplified constructor

  @override
  ConsumerState<ArchiveSupplierModal> createState() => _ArchiveSupplierModalState();
}

class _ArchiveSupplierModalState extends ConsumerState<ArchiveSupplierModal> {
  // late int _supplierID; // No longer needed locally
  late SuppliersData _supplierData;
  bool _isArchiving = false; // Keep loading state

  @override
  void initState(){
    super.initState();
    _supplierData = widget.supplierData;
    // _supplierID = widget.supplierID; // No longer needed
  }

  // Handles the archive action using the notifier
  Future<void> _archiveSupplier() async {
    setState(() => _isArchiving = true); // Show loading

    try {
      // Call the notifier for the active list (true) to set visibility to false
      await ref.read(suppliersNotifierProvider(true).notifier).updateSupplierVisibility(
        supplierID: _supplierData.supplierID, // Get ID from data
        newIsActive: false // Set to inactive (archive)
      );

      ToastManager().showToast(context, 'Supplier "${_supplierData.supplierName}" archived successfully!', Colors.green);
      Navigator.pop(context); // Close on success

    } catch (err) {
      print('Error archiving supplier: $err');
      ToastManager().showToast(context, 'Error archiving supplier. $err', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isArchiving = false); // Hide loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth > 600 ? 400 : screenWidth * 0.9;
    const double containerHeight = 180; // Adjusted height for confirmation

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 50.0 : 16.0),
      child: SizedBox( // Use SizedBox for sizing
        width: containerWidth,
        height: containerHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Keep existing, maybe change color to orange?)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: const BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.vertical(top: Radius.circular(10))), // Warning color
              child: const Center(child: Text('Confirm Archive', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white))),
            ),
            // Confirmation Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Are you sure you want to archive\n"${_supplierData.supplierName}"?', // Show name
                  style: const TextStyle(fontFamily: 'NunitoSans', fontSize: 16, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(), // Push buttons down
            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isArchiving ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(color: Colors.grey))),
                      child: const Text('Cancel', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isArchiving ? null : _archiveSupplier, // Call updated archive function
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                      child: _isArchiving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Archive', style: TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold)),
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
