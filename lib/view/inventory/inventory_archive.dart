// inventory_archive.dart (Refactored for Riverpod AsyncNotifier)
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print, use_build_context_synchronously

//Packages for usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart'; // Refactored State
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart'; // Refactored Providers
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart'; // Data Model

//Backend Pages
import 'package:jcsd_flutter/view/inventory/modals/unarchive_item.dart';

//Services 
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';

//Widgets
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';

// Shimmer for loading
import 'package:shimmer/shimmer.dart';

class ArchiveListPage extends ConsumerWidget {
  const ArchiveListPage({super.key});


  void _showUnarchiveConfirmationDialog(BuildContext context, int itemID, WidgetRef ref) {
     showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
         return UnarchiveItemModal( 
            itemID: itemID,
         );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    const String activeSubItem = '/archiveList';
    const bool isVisibleFilter = false; // For watching archived items

    // Watch the correct provider instance for archived items
    final inventoryAsyncValue = ref.watch(InventoryNotifierProvider(isVisibleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: activeSubItem),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Archive List'), 
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: inventoryAsyncValue.when(
                      loading: () => _buildLoadingIndicator(),
                      error: (error, stackTrace) => _buildErrorWidget(error, stackTrace),
                      data: (inventoryState) {
                         // Handle empty states after loading
                         if (inventoryState.filteredData.isEmpty) {
                            if (inventoryState.searchText.isEmpty) {
                               return _buildEmptyState(); // No archived items exist
                            } else {
                               return Center(child: Text('No archived items match your search: "${inventoryState.searchText}"'));
                            }
                         }
                         return _buildWebView(context, ref, inventoryState);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView(BuildContext context, WidgetRef ref, InventoryState inventoryState) {
     const bool isVisibleFilter = false; 
     return Column(
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: [
             SizedBox(
               width: 350, 
               height: 40,
               child: TextField(
                 decoration: InputDecoration(
                   hintText: 'Search Archived Items...', 
                   hintStyle: const TextStyle(color: Color(0xFFABABAB), fontFamily: 'NunitoSans'),
                   prefixIcon: const Icon(Icons.search),
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                 ),
                 onChanged: (value) {
                   ref.read(InventoryNotifierProvider(isVisibleFilter).notifier).searchItems(value);
                 },
               ),
             ),
           ],
         ),
         const SizedBox(height: 16),
         Expanded(
           child: _buildDataTable(context, ref, inventoryState),
         ),
         const SizedBox(height: 16),
         _buildPaginationControls(context, ref, inventoryState),
       ],
     );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, InventoryState inventoryState) {

    return Container(
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [ BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3)) ],
       ),
       child: Column(
          children: [
             _buildHeaderRow(context, ref, inventoryState), // Build header dynamically
             const Divider(height: 1, color: Color.fromARGB(255, 188, 188, 188)),
             Expanded(
                child: ListView.builder(
                   itemCount: inventoryState.filteredData.length, // Use current page data length
                   itemBuilder: (BuildContext context, int index) {
                      final item = inventoryState.filteredData[index]; // Get item for the row
                      return _buildItemRow(context, ref, item, inventoryState); // Pass item and state
                   },
                ),
             ),
          ],
       ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, WidgetRef ref, InventoryState inventoryState) {
    const bool isVisibleFilter = false;
    const headerTextStyle = TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white);

    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          _buildHeaderCell(context, ref, inventoryState, isVisibleFilter, 'Item ID', 'itemID', headerTextStyle),
          _buildHeaderCell(context, ref, inventoryState, isVisibleFilter, 'Item Name', 'itemName', headerTextStyle),
          _buildHeaderCell(context, ref, inventoryState, isVisibleFilter, 'Item Type', 'itemTypeID', headerTextStyle),
          _buildHeaderCell(context, ref, inventoryState, isVisibleFilter, 'Supplier', 'supplierID', headerTextStyle),
          _buildHeaderCell(context, ref, inventoryState, isVisibleFilter, 'Quantity', 'itemQuantity', headerTextStyle),
          _buildHeaderCell(context, ref, inventoryState, isVisibleFilter, 'Price', 'itemPrice', headerTextStyle),
          const Expanded(child: Text('Actions', style: headerTextStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, WidgetRef ref, InventoryState state, bool isVisibleFilter, String columnTitle, String sortByColumn, TextStyle textStyle) {
    bool isCurrentlySorted = state.sortBy == sortByColumn;
    Icon? sortIcon;
    if (isCurrentlySorted) {
       sortIcon = state.ascending ? const Icon(Icons.arrow_drop_up, color: Colors.white) : const Icon(Icons.arrow_drop_down, color: Colors.white);
    }
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(InventoryNotifierProvider(isVisibleFilter).notifier).sort(sortByColumn),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [ Text(columnTitle, style: textStyle), const SizedBox(width: 4), if (sortIcon != null) sortIcon ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemTypeCell(int typeID, BuildContext context) {
    // TODO: Replace FutureBuilder with more efficient provider-based approach or backend join - later nana not needed
    final itemTypesProvider = ItemtypesService(); // Temporary direct service call
    return FutureBuilder<String?>(
      future: itemTypesProvider.getTypeNameByID(typeID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: SizedBox(width:15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) return const Text('N/A', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center);
        return Text(snapshot.data!, style: const TextStyle(fontFamily: 'NunitoSans'), textAlign: TextAlign.center);
      },
    );
  }

  Widget _buildItemRow(BuildContext context, WidgetRef ref, InventoryData item, InventoryState inventoryState) {
    // Keep original comment if desired
    final SuppliersService suppliersService = SuppliersService(); // Temporary direct service call

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(color: (item.itemID % 2 == 0) ? Colors.grey[100] : Colors.white), // Use item ID for alternate color
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(item.itemID.toString(), style: const TextStyle(fontFamily: 'NunitoSans'), textAlign: TextAlign.center)),
          Expanded(child: Text(item.itemName.toString(), style: const TextStyle(fontFamily: 'NunitoSans'))),
          Expanded(child: _buildItemTypeCell(item.itemTypeID, context)), // Keep temporary call
          Expanded(
             child: FutureBuilder<String?>( // Temporary FutureBuilder for Supplier
                future: suppliersService.getSupplierNameByID(item.supplierID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: SizedBox(width:15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) return const Text('N/A', style: TextStyle(fontFamily: 'NunitoSans', color: Colors.grey), textAlign: TextAlign.center);
                  return Text(snapshot.data!, style: const TextStyle(fontFamily: 'NunitoSans'), textAlign: TextAlign.center);
                },
             ),
          ),
          // Keep original comment if desired
          Expanded(
            // Removed Container/Decoration, simpler Text display for archived quantity
            child: Text('${item.itemQuantity} pcs', style: const TextStyle(fontFamily: 'NunitoSans'), textAlign: TextAlign.center),
          ),
          Expanded(child: Text('P ${item.itemPrice.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'NunitoSans'), textAlign: TextAlign.center)),
          Expanded(
            child: Center( // Center the single action button
              child: ElevatedButton.icon(
                 icon: const Icon(Icons.unarchive, size: 16, color: Colors.white),
                 label: const Text('Unarchive', style: TextStyle(fontFamily: 'NunitoSans', fontSize: 12, color: Colors.white)),
                 style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Example color for Unarchive
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 ),
                 // Call the confirmation dialog method
                 onPressed: () => _showUnarchiveConfirmationDialog(context, item.itemID, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, WidgetRef ref, InventoryState inventoryState) {
    const bool isVisibleFilter = false;
    final notifier = ref.read(InventoryNotifierProvider(isVisibleFilter).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: const Icon(Icons.first_page), tooltip: 'First Page', onPressed: inventoryState.currentPage > 1 ? () => notifier.goToPage(1) : null, splashRadius: 20),
        IconButton(icon: const Icon(Icons.chevron_left), tooltip: 'Previous Page', onPressed: inventoryState.currentPage > 1 ? () => notifier.goToPage(inventoryState.currentPage - 1) : null, splashRadius: 20),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: Text('Page ${inventoryState.currentPage} of ${inventoryState.totalPages}', style: const TextStyle(fontSize: 14))),
        IconButton(icon: const Icon(Icons.chevron_right), tooltip: 'Next Page', onPressed: inventoryState.currentPage < inventoryState.totalPages ? () => notifier.goToPage(inventoryState.currentPage + 1) : null, splashRadius: 20),
        IconButton(icon: const Icon(Icons.last_page), tooltip: 'Last Page', onPressed: inventoryState.currentPage < inventoryState.totalPages ? () => notifier.goToPage(inventoryState.totalPages) : null, splashRadius: 20),
      ],
    );
  }

   Widget _buildLoadingIndicator() {
     return Column(children: List.generate(5, (_) => _buildShimmerRow()));
   }

   Widget _buildShimmerRow() {
      return Padding(
         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
         child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) => Expanded(
               child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 20.0, color: Colors.white, margin: const EdgeInsets.symmetric(horizontal: 4)),
               ),
            )),
         ),
      );
   }

   Widget _buildErrorWidget(Object error, StackTrace? stackTrace) {
      print("Archive List Error: $error \n$stackTrace");
      return Center(
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.error_outline, color: Colors.red, size: 60),
               const SizedBox(height: 16),
               const Text('Error loading archived items.', style: TextStyle(fontSize: 18)),
               const SizedBox(height: 8),
               Text('$error', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            ],
         )
      );
   }

   Widget _buildEmptyState() {
      return const Center(
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.archive_outlined, size: 80, color: Colors.grey),
               SizedBox(height: 16),
               Text('No archived items found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
         ),
      );
   }
}