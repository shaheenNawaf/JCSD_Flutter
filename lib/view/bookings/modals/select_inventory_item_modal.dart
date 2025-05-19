import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';

final _modalSelectedProdDefProvider =
    StateProvider.autoDispose<ProductDefinitionData?>((ref) => null);

class SelectInventoryItemModal extends ConsumerWidget {
  final int bookingId;

  const SelectInventoryItemModal({super.key, required this.bookingId});

  Future<int?> _getCurrentEmployeeId() async {
    final user = supabaseDB.auth.currentUser;
    if (user == null) return null;
    final empRecord = await supabaseDB
        .from('employee')
        .select('employeeID')
        .eq('userID', user.id)
        .maybeSingle();
    return empRecord?['employeeID'] as int?;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDefsAsync =
        ref.watch(productDefinitionNotifierProvider(true)); // Active PDs
    final selectedPD = ref.watch(_modalSelectedProdDefProvider);
    final currentBookingAsync =
        ref.watch(bookingDetailNotifierProvider(bookingId));

    final Set<String> attachedSerialNumbers = currentBookingAsync
            .asData?.value?.bookingItems
            ?.map((item) => item.serialNumber)
            .toSet() ??
        {};

    final Map<String, int> bookingItemIdsBySerial = currentBookingAsync
            .asData?.value?.bookingItems
            ?.fold<Map<String, int>>({}, (map, item) {
          map[item.serialNumber] = item.id;
          return map;
        }) ??
        {};

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: const BoxDecoration(
                color: Color(0xFF00AEEF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      selectedPD == null
                          ? 'Select Product from Inventory'
                          : 'Select Serial for: ${selectedPD.prodDefName}',
                      style: const TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Adjusted size
                          color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Expanded(
              child: selectedPD == null
                  ? productDefsAsync.when(
                      data: (pdState) {
                        if (pdState.productDefinitions.isEmpty) {
                          return const Center(
                            child: Text("No products defined."),
                          );
                        }
                        return ListView.builder(
                          itemCount: pdState.productDefinitions.length,
                          itemBuilder: (context, index) {
                            final pdItem = pdState.productDefinitions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(pdItem.prodDefName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    pdItem.prodDefDescription ??
                                        'No description',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                trailing: ElevatedButton(
                                  child: const Text("View Serials"),
                                  onPressed: () {
                                    ref
                                        .read(_modalSelectedProdDefProvider
                                            .notifier)
                                        .state = pdItem;
                                  },
                                ),
                                // You can add more details like stock count if you fetch it
                                // For stock, you'd need to watch serializedItemNotifierProvider(pdItem.prodDefID!)
                                // and count available/unused items. This can become complex here.
                                // Simpler: just show product info.
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Center(child: Text("Error: $err")),
                    )
                  : _buildSerialNumbersList(
                      // Show Serial Numbers List
                      ref,
                      selectedPD.prodDefID!,
                      selectedPD.prodDefMSRP,
                      attachedSerialNumbers,
                      bookingItemIdsBySerial),
            ),
            if (selectedPD != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    ref.read(_modalSelectedProdDefProvider.notifier).state =
                        null;
                  },
                  child: const Text("← Back to Products"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSerialNumbersList(
      WidgetRef ref,
      String prodDefId,
      double? defaultPrice,
      Set<String> attachedSerials,
      Map<String, int> bookingItemIdsBySerial) {
    final serialsAsync = ref.watch(serializedItemNotifierProvider(prodDefId));

    return serialsAsync.when(
      data: (serialState) {
        final displaySerials = serialState.serializedItems.where((item) {
          final statusLower = item.status.toLowerCase();
          return statusLower == 'available' ||
              statusLower == 'unused' ||
              attachedSerials.contains(item.serialNumber);
        }).toList();

        if (displaySerials.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
                child: Text(
                    "No 'Available' or 'Unused' serials for this product.",
                    style: TextStyle(fontStyle: FontStyle.italic))),
          );
        }
        return ListView.builder(
          itemCount: displaySerials.length,
          itemBuilder: (context, index) {
            final serialItem = displaySerials[index];
            final bool isAttached =
                attachedSerials.contains(serialItem.serialNumber);
            final int? bookingItemIdToDetach = isAttached
                ? bookingItemIdsBySerial[serialItem.serialNumber]
                : null;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text("SN: ${serialItem.serialNumber}"),
                subtitle: Text(
                    "Status: ${serialItem.status} | Cost: ₱${(serialItem.costPrice ?? 0.0).toStringAsFixed(2)}"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAttached ? Colors.redAccent : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isAttached ? "Detach" : "Attach"),
                  onPressed: () async {
                    final employeeId = await _getCurrentEmployeeId();
                    if (employeeId == null) {
                      ToastManager().showToast(
                          context,
                          "Cannot identify employee. Please log in again.",
                          Colors.red);
                      return;
                    }

                    if (isAttached) {
                      final int? idToDetach = bookingItemIdToDetach;
                      if (idToDetach == null) {
                        ToastManager().showToast(
                            context,
                            "Error: Cannot find item in booking to detach.",
                            Colors.red);
                        return;
                      }
                      try {
                        await ref
                            .read(bookingDetailNotifierProvider(bookingId)
                                .notifier)
                            .removeItem(idToDetach);
                        ToastManager().showToast(
                            context,
                            "${serialItem.serialNumber} detached.",
                            Colors.orange);
                      } catch (e) {
                        ToastManager().showToast(
                            context, "Error detaching: $e", Colors.red);
                      }
                    } else {
                      try {
                        await ref
                            .read(bookingDetailNotifierProvider(bookingId)
                                .notifier)
                            .addItem(
                              serialItem.serialNumber,
                              defaultPrice ?? serialItem.costPrice ?? 0.0,
                              employeeId,
                            );
                        ToastManager().showToast(
                            context,
                            "${serialItem.serialNumber} attached!",
                            Colors.green);
                      } catch (e) {
                        ToastManager().showToast(
                            context, "Error attaching: $e", Colors.red);
                      }
                    }
                    // Refresh both booking details and serials list after action
                    ref.invalidate(
                      bookingDetailNotifierProvider(bookingId),
                    );
                    ref.invalidate(
                      serializedItemNotifierProvider(prodDefId),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text(
          "Error loading serials: $err",
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
