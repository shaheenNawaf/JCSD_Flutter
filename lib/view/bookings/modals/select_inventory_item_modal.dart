// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_providers.dart'; // For allActiveProductDefinitionsProvider
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'dart:async'; // For Timer

// State for the currently selected product definition for viewing serials
final _modalSelectedProdDefProvider =
    StateProvider.autoDispose<ProductDefinitionData?>((ref) => null);

// State for the search text specifically within this modal for Product Definitions
final _modalPdSearchTextProvider =
    StateProvider.autoDispose<String>((ref) => '');

class SelectInventoryItemModal extends ConsumerWidget {
  final int bookingId;

  const SelectInventoryItemModal({super.key, required this.bookingId});

  Future<int?> _getCurrentEmployeeId() async {
    final user = supabaseDB.auth.currentUser;
    if (user == null) return null;
    try {
      final empRecord = await supabaseDB
          .from('employee')
          .select('employeeID')
          .eq('userID', user.id)
          .maybeSingle();
      return empRecord?['employeeID'] as int?;
    } catch (e) {
      print("Error fetching employee ID: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPD = ref.watch(_modalSelectedProdDefProvider);
    final currentBookingAsync =
        ref.watch(bookingDetailNotifierProvider(bookingId));
    final modalSearchText = ref.watch(_modalPdSearchTextProvider);

    // Fetch all active product definitions based on the current search text
    final allProductDefsAsync =
        ref.watch(allActiveProductDefinitionsProvider(modalSearchText));

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                  Flexible(
                    child: Text(
                      selectedPD == null
                          ? 'Select Product from Inventory'
                          : 'Serials for: ${selectedPD.prodDefName}',
                      style: const TextStyle(
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Expanded(
              child: selectedPD == null
                  ? _buildProductDefinitionListView(
                      context, ref, allProductDefsAsync)
                  : _buildSerialNumbersListView(
                      ref,
                      selectedPD.prodDefID!,
                      selectedPD.prodDefMSRP,
                      attachedSerialNumbers,
                      bookingItemIdsBySerial,
                    ),
            ),
            if (selectedPD != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                  label: const Text("Back to Products"),
                  onPressed: () {
                    ref.read(_modalSelectedProdDefProvider.notifier).state =
                        null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDefinitionListView(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ProductDefinitionData>> productDefsAsync,
  ) {
    Timer? searchDebounce;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Product Definitions...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              isDense: true,
            ),
            onChanged: (value) {
              searchDebounce?.cancel();
              searchDebounce = Timer(const Duration(milliseconds: 350), () {
                // Update the search text provider, which will trigger the family provider to refetch
                ref.read(_modalPdSearchTextProvider.notifier).state = value;
              });
            },
          ),
        ),
        Expanded(
          child: productDefsAsync.when(
            data: (pdList) {
              if (pdList.isEmpty) {
                return Center(
                  child: Text(
                    ref.read(_modalPdSearchTextProvider).isEmpty
                        ? "No products defined."
                        : "No products match your search.",
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: pdList.length,
                itemBuilder: (context, index) {
                  final pdItem = pdList[index];
                  return Card(
                    elevation: 1.5,
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    child: ListTile(
                      title: Text(pdItem.prodDefName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      subtitle: Text(
                        "Available Stock: ${pdItem.serialsCount ?? 0} | MSRP: ₱${(pdItem.prodDefMSRP ?? 0.0).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            textStyle: const TextStyle(fontSize: 11)),
                        onPressed: (pdItem.serialsCount ?? 0) > 0
                            ? () {
                                // Only allow viewing if stock > 0
                                ref
                                    .read(
                                        _modalSelectedProdDefProvider.notifier)
                                    .state = pdItem;
                              }
                            : null,
                        child: const Text(
                            "View Serials"), // Disable button if no stock
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(
                child: Text("Error loading products: $err",
                    style: const TextStyle(color: Colors.red))),
          ),
        ),
      ],
    );
  }

  Widget _buildSerialNumbersListView(
    WidgetRef ref,
    String prodDefId,
    double? defaultPriceFromPD,
    Set<String> attachedSerials,
    Map<String, int> bookingItemIdsBySerial,
  ) {
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
            final int? bookingItemIdForDetach = isAttached
                ? bookingItemIdsBySerial[serialItem.serialNumber]
                : null;

            return Card(
              elevation: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              child: ListTile(
                dense: true,
                title: Text("SN: ${serialItem.serialNumber}",
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Text(
                    "Status: ${serialItem.status} | Cost: ₱${(serialItem.costPrice ?? 0.0).toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 11)),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isAttached
                          ? Colors.redAccent.shade100
                          : Colors.green.shade300,
                      foregroundColor: isAttached
                          ? Colors.red.shade900
                          : Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                  child: Text(isAttached ? "Detach" : "Attach"),
                  onPressed: () async {
                    final employeeId = await _getCurrentEmployeeId();
                    if (employeeId == null) {
                      ToastManager().showToast(
                          context, "Cannot identify employee.", Colors.red);
                      return;
                    }

                    if (isAttached) {
                      if (bookingItemIdForDetach == null) {
                        ToastManager().showToast(
                            context,
                            "Error: Could not find item in booking to detach.",
                            Colors.red);
                        return;
                      }
                      try {
                        await ref
                            .read(bookingDetailNotifierProvider(bookingId)
                                .notifier)
                            .removeItem(bookingItemIdForDetach);
                        ToastManager().showToast(
                            context,
                            "${serialItem.serialNumber} detached.",
                            Colors.orange);
                      } catch (e) {
                        ToastManager().showToast(
                            context, "Error detaching: $e", Colors.red);
                      }
                    } else {
                      // Attach
                      if (serialItem.status.toLowerCase() != 'available' &&
                          serialItem.status.toLowerCase() != 'unused') {
                        ToastManager().showToast(
                            context,
                            "Item is not in an attachable state (${serialItem.status}).",
                            Colors.orange);
                        return;
                      }
                      try {
                        await ref
                            .read(bookingDetailNotifierProvider(bookingId)
                                .notifier)
                            .addItem(
                              serialItem.serialNumber,
                              defaultPriceFromPD ?? serialItem.costPrice ?? 0.0,
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
                    ref.invalidate(bookingDetailNotifierProvider(bookingId));
                    ref.invalidate(serializedItemNotifierProvider(prodDefId));
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
              child: Text("Error loading serials: $err",
                  style: const TextStyle(color: Colors.red)))),
    );
  }
}
