// lib/view/inventory/serials/serialized_item_list_page.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


// Backend & State Imports
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart'; // For supplier name lookup
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';

// Widgets & Modals
import 'package:jcsd_flutter/widgets/sidebar.dart'; 
import 'package:jcsd_flutter/widgets/header.dart'; 

//Item Serials Modals
import 'package:jcsd_flutter/view/inventory/item_serials/modals/add_item_serials.dart';
import 'package:jcsd_flutter/view/inventory/item_serials/modals/edit_item_serials.dart';
import 'package:jcsd_flutter/view/inventory/item_serials/modals/dispose_item_serials.dart';

// For UI and User-Feedback
import 'package:shimmer/shimmer.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart'; 

class SerializedItemListPage extends ConsumerWidget {
  final String prodDefID; 
  final String prodDefName; 

  const SerializedItemListPage({
    super.key,
    required this.prodDefID,
    required this.prodDefName,
  });

  void _showAddSerializedItemModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddSerializedItemModal(prodDefID: prodDefID, prodDefName: prodDefName)
    );
  }

  void _showEditSerializedItemModal(BuildContext context, WidgetRef ref, SerializedItem item) {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (_) => EditSerializedItemModal(item: item)
     );
  }

  void _showDisposeSerializedItemModal(BuildContext context, WidgetRef ref, SerializedItem item) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => DisposeSerializedItemModal(item: item)
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(serializedItemNotifierProvider(prodDefID));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/inventory'),
          Expanded(
              child: Column(
            children: [
              Header(title: 'Serials for "$prodDefName"'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: asyncValue.when(
                    loading: () => _buildLoadingIndicator(),
                    error: (error, stackTrace) => _buildErrorWidget(error, stackTrace, ref),
                    data: (serialItemState) {
                      if (serialItemState.serializedItems.isEmpty) {
                        return serialItemState.searchText.isEmpty && serialItemState.statusFilter == null
                            ? _buildEmptyState(context, ref) // No items and no filters
                            : const Center(child: Text('No Serial Items match current filters/search.')); // No results
                      }
                      final suppliersMapGetter  =ref.watch(supplierNameMapProvider);
                      return suppliersMapGetter.when(
                        data: (supplierMap) => _buildWebView(context, ref, serialItemState, supplierMap),
                        loading: () => _buildLoadingIndicator(),
                        error: (err, stack) => _buildErrorWidget(err, stack, ref),
                      );
                    },
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildWebView(BuildContext context, WidgetRef ref, SerializedItemState serialItemState, Map<int, String> supplierMap) {
    return Column(
      children: [
        _buildTopControls(context, ref, serialItemState),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTable(context, ref, serialItemState, supplierMap)
        ),
        const SizedBox(height: 16),
        _buildPaginationControls(context, ref, serialItemState),
      ],
    );
  }

  Widget _buildTopControls(BuildContext context, WidgetRef ref, SerializedItemState serialItemState){
    return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Product Definitions',
            onPressed: () => context.go('/inventory'), /// Added this route, adjust if needed
          ),
          const SizedBox(width: 10),
          // Status Filter Dropdown
          SizedBox(
            width: 180, // Adjust width as needed
            height: 40,
            child: _buildStatusFilterDropdown(ref, serialItemState),
          ),
          const Spacer(),
          SizedBox(width: 250, height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Serial/Notes...', 
                prefixIcon: const Icon(
                  Icons.search, size: 20
                ), 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                contentPadding: 
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10), 
                hintStyle: const TextStyle(fontSize: 12
                )
              ),
              onChanged: (searchText) => ref.read(serializedItemNotifierProvider(prodDefID).notifier).search(searchText),
            ),
          ),
          const SizedBox(width: 16),
          // Add Button
          ElevatedButton.icon(
            onPressed: () => _showAddSerializedItemModal(context, ref), 
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text('Add Serial', style: TextStyle(color: Colors.white)), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, 
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10)
          )
        ),
      ],
    );
  }

  // New Status Filter Dropdown
  Widget _buildStatusFilterDropdown(WidgetRef ref, SerializedItemState serialItemState) {
    final statusesAsync = ref.watch(allItemStatusesProvider); 

    return statusesAsync.when(
      data: (statuses) => DropdownButtonFormField<String?>(
        value: serialItemState.statusFilter, // Current filter value from state
        hint: const Text('Filter by Status...', style: TextStyle(fontSize: 12, color: Colors.grey)),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          
          // Add clear button if filter is active
          suffixIcon: serialItemState.statusFilter != null ? IconButton(
            icon: const Icon(Icons.clear, size: 16),
            tooltip: 'Clear Filter',
            onPressed: () => ref.read(serializedItemNotifierProvider(prodDefID).notifier).filterByStatus(null),
          ) : null,
        ),
        isExpanded: true,
        items: [

          // Add an "All" option to clear the filter
          const DropdownMenuItem<String?>(
            value: null, // Value null represents no filter
            child: Text('All Statuses', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ),
          // Add items for each status fetched
          ...statuses.map((status) => DropdownMenuItem<String?>(
              value: status,
              child: Text(status, style: const TextStyle(fontSize: 12)),
            )).toList(),
        ],
        onChanged: (value) {
          // Call notifier to update filter
          ref.read(serializedItemNotifierProvider(prodDefID).notifier).filterByStatus(value);
        },
      ),
      loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, SerializedItemState serialItemState, Map<int, String> supplierMap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(8), 
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.3), 
        spreadRadius: 2, 
        blurRadius: 5
        )
      ]
    ),
    child: Column(
      children: [
        _buildHeaderRow(context, ref, serialItemState),
        const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
        Expanded(
          child: ListView.builder(
            itemCount: serialItemState.serializedItems.length,
            itemBuilder: (BuildContext context, int index) {
              final item = serialItemState.serializedItems[index];
              final rowColor = index % 2 == 0 ? Colors.white : const Color(0xFFF8F8F8);
              return _buildItemRow(context, ref, item, rowColor, supplierMap, ValueKey(item)); //Serial as the Key
            },
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, WidgetRef ref, SerializedItemState serialItemState) {
    const headerTextStyle = TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13);
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildHeaderCell(context, ref, serialItemState, 'Serial Number', 'serialNumber', headerTextStyle, flex: 3),
          _buildHeaderCell(context, ref, serialItemState, 'Status', 'status', headerTextStyle, flex: 2),
          _buildHeaderCell(context, ref, serialItemState, 'Supplier', 'supplierID', headerTextStyle, flex: 3), // Sort by ID
          _buildHeaderCell(context, ref, serialItemState, 'Cost Price', 'costPrice', headerTextStyle, flex: 2),
          _buildHeaderCell(context, ref, serialItemState, 'Purchase Date', 'purchaseDate', headerTextStyle, flex: 2),
          _buildHeaderCell(context, ref, serialItemState, 'Notes', 'notes', headerTextStyle, flex: 4),
          const Expanded(flex: 2, child: Text('Actions', style: headerTextStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, WidgetRef ref, SerializedItemState state, String columnTitle, String sortByColumn, TextStyle textStyle, {int flex = 1}) {
    bool isCurrentlySorted = state.sortBy == sortByColumn;
    Icon? sortIcon = isCurrentlySorted ? Icon(state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.white, size: 18) : null;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => ref.read(serializedItemNotifierProvider(prodDefID).notifier).sort(sortByColumn),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: Text(columnTitle, style: textStyle, overflow: TextOverflow.ellipsis)),
              if (sortIcon != null) ...[const SizedBox(width: 2), sortIcon],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, WidgetRef ref, SerializedItem item, Color rowColor, Map<int, String> supplierMap, Key key) {
    String costPrice = 'P ${item.costPrice!.toStringAsFixed(2)}';
    String purchaseDate = item.purchaseDate != null ? DateFormat('yyyy-MM-dd').format(item.purchaseDate!) : 'N/A';
    String notes = item.notes ?? '';
    String supplierName = supplierMap[item.supplierID] ?? 'N/A'; // Lookup name from map
    const rowTextStyle = TextStyle(fontFamily: 'NunitoSans', fontSize: 13);

    return Container(
      key: key, 
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: rowColor, 
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item.serialNumber, style: rowTextStyle, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(item.status, style: rowTextStyle, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(supplierName, style: rowTextStyle, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(costPrice, style: rowTextStyle, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(purchaseDate, style: rowTextStyle, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 4, child: Tooltip(message: notes, child: Text(notes, style: rowTextStyle, overflow: TextOverflow.ellipsis, maxLines: 1))),
          // Action Buttons
          Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Tooltip(message: 'Edit Item', child: IconButton(icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18), onPressed: () => _showEditSerializedItemModal(context, ref, item), splashRadius: 18, constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 5))),
              const SizedBox(width: 4),
              Tooltip(message: 'Mark as Disposed', child: IconButton(icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 18), onPressed: () => _showDisposeSerializedItemModal(context, ref, item), splashRadius: 18, constraints: const BoxConstraints(), padding: const EdgeInsets.symmetric(horizontal: 5))),
            ],
          )),
        ],
      ),
    );
  }

  // Builds the pagination controls
  Widget _buildPaginationControls(BuildContext context, WidgetRef ref, SerializedItemState serialItemState) {
    final notifier = ref.read(serializedItemNotifierProvider(prodDefID).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.first_page), tooltip: 'First Page', onPressed: serialItemState.currentPage > 1 ? () => notifier.goToPage(1) : null, splashRadius: 20),
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: 'Previous Page', onPressed: serialItemState.currentPage > 1 ? () => notifier.goToPage(serialItemState.currentPage - 1) : null, splashRadius: 20),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('Page ${serialItemState.currentPage} of ${serialItemState.totalPages}', style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'))),
        IconButton(icon: const Icon(Icons.chevron_right), tooltip: 'Next Page', onPressed: serialItemState.currentPage < serialItemState.totalPages ? () => notifier.goToPage(serialItemState.currentPage + 1) : null, splashRadius: 20),
        IconButton(icon: const Icon(Icons.last_page), tooltip: 'Last Page', onPressed: serialItemState.currentPage < serialItemState.totalPages ? () => notifier.goToPage(serialItemState.totalPages) : null, splashRadius: 20),
      ],
    );
  }

  //Reused Shimmer Row
  Widget _buildShimmerHeader() {
     const headerPlaceholderColor = Color.fromRGBO(0, 174, 239, 0.5);
     return Container(color: headerPlaceholderColor, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Shimmer.fromColors(baseColor: Colors.white.withValues(alpha: 0.3), highlightColor: Colors.white.withValues(alpha: 0.6),
        child: Row(children: [ 
           Expanded(flex: 3, child: Container(height: 16, color: Colors.white)), const SizedBox(width: 8),
           Expanded(flex: 2, child: Container(height: 16, color: Colors.white)), const SizedBox(width: 8),
           Expanded(flex: 3, child: Container(height: 16, color: Colors.white)), const SizedBox(width: 8),
           Expanded(flex: 2, child: Container(height: 16, color: Colors.white)), const SizedBox(width: 8),
           Expanded(flex: 2, child: Container(height: 16, color: Colors.white)), const SizedBox(width: 8),
           Expanded(flex: 4, child: Container(height: 16, color: Colors.white)), const SizedBox(width: 8),
           Expanded(flex: 2, child: Container(height: 16, color: Colors.white)),
        ]),
      ),
    );
  }
  Widget _buildShimmerRow() {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
         Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)), const SizedBox(width: 8),
         Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)), const SizedBox(width: 8),
         Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)), const SizedBox(width: 8),
         Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)), const SizedBox(width: 8),
         Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)), const SizedBox(width: 8),
         Expanded(flex: 4, child: Container(height: 14.0, color: Colors.white)), const SizedBox(width: 8),
         Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
           Container(
            width: 18, 
            height: 18, 
            decoration: 
            const BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle
            )
          ), 
          const SizedBox(width: 10),
           Container(
            width: 18, 
            height: 18, 
            decoration: 
            const BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle
            )
          ),
          ]
          )
        ),
      ]
    ),
  );
  }
  Widget _buildLoadingIndicator() {
     return Column(children: [
       _buildTopControlsPlaceholder(), SizedBox(height: 16),
       Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
         child: Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
           child: Column(children: [
             _buildShimmerHeader(), Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
             Expanded(child: ListView(children: List.generate(8, (_) => _buildShimmerRow()))),
           ]),
         ),
       )), SizedBox(height: 16),
       _buildPaginationPlaceholder(),
     ]);
  }
  Widget _buildTopControlsPlaceholder() {
     return Padding(padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
        child: Row(children: [
          Container(height: 36, width: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), SizedBox(width: 10), // Back button
          Container(height: 40, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))), // Filter dropdown
          const Spacer(),
          Container(height: 40, width: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))), SizedBox(width: 16), // Search
          Container(height: 36, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))), // Add button
        ]),
      ),
    );
  }
  Widget _buildPaginationPlaceholder() {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
         child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(height: 36, width: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), SizedBox(width: 8),
            Container(height: 36, width: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), SizedBox(width: 12),
            Container(height: 20, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))), SizedBox(width: 12),
            Container(height: 36, width: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), SizedBox(width: 8),
            Container(height: 36, width: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ]),
        ),
      );
  }

  // Builds the error display widget
  Widget _buildErrorWidget(Object error, StackTrace? stackTrace, WidgetRef ref) {
    print('Serialized Item List Page Error: $error \n $stackTrace');
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation, color: Colors.redAccent, size: 60), SizedBox(height: 16),
      const Text('Error Loading Serialized Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 8),
      Text('$error', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])), SizedBox(height: 20),
      ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text("Retry"), onPressed: () => ref.invalidate(serializedItemNotifierProvider(prodDefID))),
    ]));
  }

  // Builds the empty state display widget
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.barcode, size: 80, color: Colors.grey), SizedBox(height: 16),
      Text('No Serial Items found for "$prodDefName".', style: const TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center), SizedBox(height: 12),
      ElevatedButton.icon(icon: const Icon(Icons.add), onPressed: () => _showAddSerializedItemModal(context, ref), label: const Text('Add First Serial Item'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    ]));
  }
}
