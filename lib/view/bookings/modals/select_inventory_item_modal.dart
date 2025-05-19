// lib/modals/select_inventory_item_modal.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart';
import 'dart:async'; // For Timer

// State for the currently selected product definition for viewing serials
final _modalSelectedProdDefProvider =
    StateProvider.autoDispose<ProductDefinitionData?>((ref) => null);

// State for the accumulated list of product definitions in the modal
final _modalProductDefinitionsListProvider =
    StateProvider.autoDispose<List<ProductDefinitionData>>((ref) => []);

// State for the current page of product definitions loaded IN THE MODAL for its own pagination
final _modalProductDefinitionsCurrentPageProvider =
    StateProvider.autoDispose<int>((ref) => 1);

// State to track if all product definitions have been loaded for the current search/filter
final _modalAllProductDefinitionsLoadedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

// State for the search text specifically within this modal for Product Definitions
final _modalPdSearchTextProvider =
    StateProvider.autoDispose<String>((ref) => '');

class SelectInventoryItemModal extends ConsumerWidget {
  final int bookingId;
  final bool _isVisibleFilter = true; // For active product definitions

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

  // Function to fetch and append product definitions
  Future<void> _fetchMoreProductDefinitions(
      WidgetRef ref, BuildContext context) async {
    final notifier =
        ref.read(productDefinitionNotifierProvider(_isVisibleFilter).notifier);
    final currentNotifierState = ref
        .read(productDefinitionNotifierProvider(_isVisibleFilter))
        .asData
        ?.value;

    final modalCurrentPage =
        ref.read(_modalProductDefinitionsCurrentPageProvider);

    if (currentNotifierState == null || currentNotifierState.isLoadingMore!) {
      return;
    }

    if (modalCurrentPage > currentNotifierState.totalPages &&
        currentNotifierState.totalPages != 0) {
      // Check totalPages != 0 to handle initial state where totalPages might be 1 but no items
      ref.read(_modalAllProductDefinitionsLoadedProvider.notifier).state = true;
      print("All PDs loaded or notifier state not ready.");
      return;
    }

    print(
        "Modal fetching page: $modalCurrentPage for PDs from Notifier (which is at page ${currentNotifierState.currentPage})");
    // We want the notifier to go to the *modal's* next desired page
    await notifier.goToPage(modalCurrentPage, forLoadMore: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Watch the main ProductDefinitionNotifier state
    final productDefsNotifierStateAsync =
        ref.watch(productDefinitionNotifierProvider(_isVisibleFilter));

    // Listen to changes in the main ProductDefinitionNotifier state to update modal's list
    ref.listen<AsyncValue<ProductDefinitionState>>(
        productDefinitionNotifierProvider(_isVisibleFilter), (previous, next) {
      next.whenData((pdState) {
        final modalCurrentPage =
            ref.read(_modalProductDefinitionsCurrentPageProvider);

        // If it's the first page (either initial load or after a search reset)
        if (pdState.currentPage == 1 && modalCurrentPage == 1) {
          ref.read(_modalProductDefinitionsListProvider.notifier).state =
              pdState.productDefinitions;
        }
        // If the notifier has loaded the page the modal was expecting for "load more"
        else if (pdState.currentPage == modalCurrentPage &&
            pdState.currentPage > (previous?.asData?.value?.currentPage ?? 0)) {
          final currentModalList =
              ref.read(_modalProductDefinitionsListProvider);
          final Set<String?> existingIds =
              currentModalList.map((e) => e.prodDefID).toSet();
          final newItems = pdState.productDefinitions
              .where((item) => !existingIds.contains(item.prodDefID))
              .toList();
          if (newItems.isNotEmpty) {
            ref.read(_modalProductDefinitionsListProvider.notifier).state = [
              ...currentModalList,
              ...newItems
            ];
          }
        }

        if (pdState.currentPage >= pdState.totalPages &&
            pdState.totalPages != 0) {
          ref.read(_modalAllProductDefinitionsLoadedProvider.notifier).state =
              true;
        } else {
          ref.read(_modalAllProductDefinitionsLoadedProvider.notifier).state =
              false;
        }
      });
    });

    final displayedProductDefinitions =
        ref.watch(_modalProductDefinitionsListProvider);
    final allPDsLoaded = ref.watch(_modalAllProductDefinitionsLoadedProvider);
    final modalSearchText = ref.watch(_modalPdSearchTextProvider);

    // Client-side search/filter for the accumulated list
    final List<ProductDefinitionData> filteredDisplayedProductDefinitions =
        modalSearchText.isEmpty
            ? displayedProductDefinitions
            : displayedProductDefinitions
                .where((pd) =>
                    pd.prodDefName
                        .toLowerCase()
                        .contains(modalSearchText.toLowerCase()) ||
                    (pd.prodDefDescription
                            ?.toLowerCase()
                            .contains(modalSearchText.toLowerCase()) ??
                        false))
                .toList();

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
                      context,
                      ref,
                      productDefsNotifierStateAsync,
                      filteredDisplayedProductDefinitions, // Use filtered list
                      allPDsLoaded,
                    )
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
    AsyncValue<ProductDefinitionState> productDefsNotifierStateAsync,
    List<ProductDefinitionData> itemsToDisplay,
    bool allItemsLoaded,
  ) {
    Timer? searchDebounce;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
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
              searchDebounce = Timer(const Duration(milliseconds: 400), () {
                ref.read(_modalPdSearchTextProvider.notifier).state = value;
                // If server-side search is desired for PDs, trigger notifier search
                ref
                    .read(productDefinitionNotifierProvider(_isVisibleFilter)
                        .notifier)
                    .search(value);
                ref
                    .read(_modalProductDefinitionsCurrentPageProvider.notifier)
                    .state = 1;
                ref.read(_modalProductDefinitionsListProvider.notifier).state =
                    [];
                ref
                    .read(_modalAllProductDefinitionsLoadedProvider.notifier)
                    .state = false;
              });
            },
          ),
        ),
        Expanded(
          child: productDefsNotifierStateAsync.when(
            // Still use the notifier's overall loading/error for the container
            loading: () =>
                (ref.read(_modalProductDefinitionsListProvider).isEmpty)
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPdList(context, ref, itemsToDisplay, allItemsLoaded,
                        true), // Show list + load more if loading more
            error: (err, st) => Center(
                child: Text("Error: $err",
                    style: const TextStyle(color: Colors.red))),
            data: (pdState) {
              if (itemsToDisplay.isEmpty &&
                  pdState.searchText.isNotEmpty &&
                  !pdState.isLoadingMore!) {
                return const Center(
                    child: Text("No products match your search."));
              }
              if (itemsToDisplay.isEmpty && !pdState.isLoadingMore!) {
                return const Center(
                    child: Text("No products defined or loaded yet."));
              }
              return _buildPdList(
                  context, ref, itemsToDisplay, allItemsLoaded, true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPdList(
    BuildContext context,
    WidgetRef ref,
    List<ProductDefinitionData> itemsToDisplay,
    bool allItemsLoaded,
    bool isLoadingMore,
  ) {
    return ListView.builder(
      itemCount:
          itemsToDisplay.length + (allItemsLoaded || isLoadingMore ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == itemsToDisplay.length &&
            !allItemsLoaded &&
            !isLoadingMore) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  final currentPage =
                      ref.read(_modalProductDefinitionsCurrentPageProvider);
                  ref
                      .read(
                          _modalProductDefinitionsCurrentPageProvider.notifier)
                      .state = currentPage + 1;
                  _fetchMoreProductDefinitions(ref, context);
                },
                child: const Text("Load More Products"),
              ),
            ),
          );
        }
        if (index >= itemsToDisplay.length) {
          return isLoadingMore
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : const SizedBox.shrink();
        }

        final pdItem = itemsToDisplay[index];
        return Card(
          elevation: 1.5,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: ListTile(
            title: Text(pdItem.prodDefName,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            subtitle: Text(
              "Stock: ${pdItem.serialsCount ?? 'N/A'} | MSRP: ₱${(pdItem.prodDefMSRP ?? 0.0).toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 11),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  textStyle: const TextStyle(fontSize: 11)),
              child: const Text("View Serials"),
              onPressed: () {
                ref.read(_modalSelectedProdDefProvider.notifier).state = pdItem;
              },
            ),
          ),
        );
      },
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
