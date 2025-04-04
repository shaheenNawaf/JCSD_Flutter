// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

// Packages for usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Inventory Backend
import 'package:jcsd_flutter/backend/modules/inventory/inventory_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

//For Animation
import 'package:shimmer/shimmer.dart';

// Pages
import 'package:jcsd_flutter/view/inventory/modals/add_item.dart';
import 'package:jcsd_flutter/view/inventory/modals/edit_item.dart';
import 'package:jcsd_flutter/view/inventory/modals/archive_item.dart';
import 'package:jcsd_flutter/view/inventory/modals/stock_in_item.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/view/inventory/borrowed_items/view_borrowed.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';

// Inventory
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/view/inventory/item_types/item_types.dart';

// Suppliers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';

class InventoryPage extends ConsumerWidget{
  const InventoryPage({super.key});

  final String _activeSubItem = '/inventory';
  final bool isVisibleFilter = true; //Default Value, since in this page, only Active items are displayed

  //Update Theses after the main inventory module
  void _showAddItemModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddItemModal();
      },
    );
  }

  void _showBorrowedItemsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const BorrowedItems();
      },
    );
  }

  _showEditItemModal(BuildContext context, InventoryData itemData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditItemModal(item: itemData); // Adjust the parameter inside Edit Item Modal itself to accept the InventoryData
      },
    );
  }

  _showArchiveItemModal(BuildContext context, int itemID, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return ArchiveItemModal(itemID: itemID);
      },
    );
  }

  void _showStockInItemModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const StockInItemModal();
      },
    );
  }

  void _navigateToItemTypesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ItemTypesPage()),
    );
  }

  //UI and Some fetch methods
  Color _itemQuantityColor(int itemQuantity) {
    if (itemQuantity < 10) {
      return Colors.red;
    } else if (itemQuantity < 20) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  Future<String> fetchTypeName(int typeID) async {
    final fetchTypes = ItemtypesService();
    String typeName = await fetchTypes.getTypeNameByID(typeID);

    return typeName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bool isVisibleFilter = true;

    final inventoryAsyncValue = ref.watch(InventoryNotifierProvider(isVisibleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                const Header(
                  title: 'Inventory'
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: inventoryAsyncValue.when(
                      loading: () => _buildLoadingIndicator(),
                      error:(error, stackTrace) => _buildErrorWidget(
                        error.toString(), stackTrace),
                      data: (inventoryData) {
                        if(inventoryData.filteredData.isEmpty){
                          if(inventoryData.searchText.isEmpty){
                            return _buildEmptyState(context, ref);
                          }else{
                            return Center(
                              child: Text('No items match your search query. ${inventoryData.searchText}'
                              ),
                            );
                          }
                        }
                        return _buildWebView(context, ref, inventoryData);
                      },
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );  
  }

  //Shimmer Row Loading indicator nako hehe
  Widget _buildLoadingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildShimmerRow(),
        _buildShimmerRow(),
        _buildShimmerRow(),
        _buildShimmerRow(),
        _buildShimmerRow(),
        _buildShimmerRow(),
        _buildShimmerRow(),
      ],
    );
  }

  //Dedicated Error Widget to display error messages, mainly for UI but goods for debugging
  Widget _buildErrorWidget(String error, StackTrace? stackTrace) {
    print('General Inventory Error. Kindly check: $error \n $stackTrace');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.bug, color: Color.fromARGB(255, 25, 122, 206), size: 70),
          const SizedBox(height: 16),
          _buildGenericTextInformation('Error loading inventory data.'),
          const SizedBox(height: 8),
          _buildGenericTextInformation(error),
        ],
      )
    );
  }

  //Generic Text Widget, for cleaner code
  Widget _buildGenericTextInformation(String textMessage){
    return Text(
      textMessage,
      style: const TextStyle(
        fontFamily: 'NunitoSans',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  //Empty State Widget - just to show na "hey walay data sa imong gisearch boo!"
  //Michael or Bea, just adjust the design for this thx
  Widget _buildEmptyState(BuildContext context, WidgetRef ref){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const Icon(FontAwesomeIcons.xmark, color: Color.fromARGB(255, 25, 122, 206), size: 70),
          const SizedBox(height: 16),
          _buildGenericTextInformation('No active inventory items found.'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.plus, color: Colors.blue, size: 12,),
            onPressed: () => _showAddItemModal(context, ref), 
            label: _buildGenericTextInformation('Add a new item'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            )
          )
        ],
      ),
    );
  }

  //Leaving Notes kay it's not that readable ba, sakit sa mata
  Widget _buildWebView(BuildContext context, WidgetRef ref, InventoryState inventoryState){
    return Column(
      children: [
        //First Row: Item Types and Borrowed Items
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                onPressed: () => _navigateToItemTypesPage(context),
                icon: const Icon(
                  Icons.topic_rounded, 
                  color: Colors.white
                ),
                label: const Text(
                  'Item Types', 
                  style: TextStyle(
                    color: Colors.white
                  )
                ),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AEEF)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showBorrowedItemsModal(context),
                  icon: const Icon(Icons.topic_rounded, color: Colors.white),
                  label: const Text('Borrowed Items', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AEEF)),
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Name/Description....',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (searchText) {
                      ref.read(InventoryNotifierProvider(isVisibleFilter).notifier).searchItems(searchText);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showStockInItemModal(context),
                  icon: const Icon(Icons.add_business, color: Colors.white),
                  label: const Text('Stock In', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00AEEF)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemModal(context, ref),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Item', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                ),
              ],
            )
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          _buildHeaderRow(context, ref, inventoryState),
          const Divider(height: 1, color: Color.fromARGB(255, 188, 188, 188)),
          Expanded(
            child: ListView.builder(
              itemCount: inventoryState.filteredData.length,
              itemBuilder: (BuildContext context, int index) {
                final item = inventoryState.filteredData[index];
                return _buildItemRow(context, ref, item, inventoryState);
              },
            ),
          ),
        ],
      ),
    );
  }

  //Refactoring _buildHeaderCell first
  Widget _buildHeaderRow(BuildContext context, WidgetRef ref, InventoryState inventoryState) {
      // Use a helper for consistency or define style here
      const headerTextStyle = TextStyle(fontFamily: 'NunitoSans', fontWeight: FontWeight.bold, color: Colors.white);

      return Container(
          color: const Color.fromRGBO(0, 174, 239, 1),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderCell(context: context,ref: ref, state: inventoryState, columnTitle: 'Item ID', sortByColumn: 'itemID', textStyle: headerTextStyle),
              _buildHeaderCell(context: context,ref: ref, state: inventoryState, columnTitle: 'Item Name', sortByColumn: 'itemName', textStyle: headerTextStyle),
              _buildHeaderCell(context: context,ref: ref, state: inventoryState, columnTitle: 'Product Type', sortByColumn: 'itemTypeID', textStyle: headerTextStyle), // Sort by ID, display name later
              _buildHeaderCell(context: context,ref: ref, state: inventoryState, columnTitle: 'Supplier', sortByColumn: 'supplierID', textStyle: headerTextStyle), // Sort by ID, display name later
              _buildHeaderCell(context: context,ref: ref, state: inventoryState, columnTitle: 'Quantity', sortByColumn: 'itemQuantity', textStyle: headerTextStyle),
              _buildHeaderCell(context: context,ref: ref, state: inventoryState, columnTitle: 'Price', sortByColumn: 'itemPrice', textStyle: headerTextStyle),
              const Expanded( 
                  child: Text('Actions', style: headerTextStyle, textAlign: TextAlign.center),
              ),
            ],
          ),
      );
  }

  Widget _buildHeaderCell({
    required BuildContext context, 
    required WidgetRef ref,
    required InventoryState state, 
    required String columnTitle,
    required String sortByColumn,
    required TextStyle textStyle,
  }) {
    bool isCurrentlySorted = state.sortBy == sortByColumn;
    Icon? sortIcon;

    //For the icon activity -- UI Only
    if(isCurrentlySorted){
      sortIcon = state.ascending
      ? const Icon(Icons.arrow_drop_up, color: Colors.white)
      : const Icon(Icons.arrow_drop_down, color: Colors.white);
    }

    return Expanded(
        child: InkWell(
      onTap: () {
        ref.read(InventoryNotifierProvider(isVisibleFilter).notifier).sort(sortByColumn);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(columnTitle, style: textStyle),
            const SizedBox(width: 4),
            if(sortIcon != null) sortIcon,
          ],
        ))
    ));
  }

  Widget _buildItemRow(
      BuildContext context, WidgetRef ref, InventoryData items, InventoryState inventorystate) {
    final SuppliersService suppliersService = SuppliersService();
    final ItemtypesService itemTypesService = ItemtypesService();
    String itemIDForDisplay = 'PROD ${items.itemID.toString()}'; 

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: items.itemID % 2 == 0 ? Colors.grey[100] : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              itemIDForDisplay,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              items.itemName,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<String?>(
              future: itemTypesService.getTypeNameByID(items.itemTypeID), 
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: Text('Loading..'),
                    ),
                  );
                }else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null){
                  return const Text(
                    'Type N/A',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                }else {
                  return Text(snapshot.data!,
                  textAlign: TextAlign.center
                  );
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<String?>(
              future: suppliersService
                  .getSupplierNameByID(items.supplierID.toInt()),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: Text('Loading..'),
                    ),
                  );
                }else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null){
                  return const Text(
                    'Supplier N/A',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                }else {
                  return Text(snapshot.data!,
                  textAlign: TextAlign.center
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _itemQuantityColor(items.itemQuantity),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${items.itemQuantity.toString()} pcs',
                style: const TextStyle(
                  fontFamily: 'NunitoSans',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PHP ${items.itemPrice.toStringAsFixed(3)}',
              style: const TextStyle(fontFamily: 'NunitoSans'),
              textAlign: TextAlign.start,
            ),
          ),
          //Actions
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon:const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    _showEditItemModal(context, items);
                  },
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                ), 
                IconButton(
                  icon:const Icon(Icons.archive, color: Colors.red),
                  onPressed: () {
                    _showArchiveItemModal(context, items.itemID, ref);
                  },
                  splashRadius: 20,
                  constraints: const BoxConstraints(),
                ), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, WidgetRef ref, InventoryState inventoryState){
    final inventoryNotifierAccess = ref.read(InventoryNotifierProvider(isVisibleFilter).notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          tooltip: 'First Page',
          onPressed: inventoryState.currentPage > 1 ? () => inventoryNotifierAccess.goToPage(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous Page',
          onPressed: inventoryState.currentPage > 1 ? () => inventoryNotifierAccess.goToPage(inventoryState.currentPage - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Page ${inventoryState.currentPage} of ${inventoryState.totalPages}',
            style: const TextStyle(
              fontSize: 14, 
              fontFamily: 'NunitoSans'
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next Page',
          onPressed: inventoryState.currentPage < inventoryState.totalPages ? () => inventoryNotifierAccess.goToPage(inventoryState.currentPage + 1) : null,
          splashRadius: 20,
        ),
         IconButton(
          icon: const Icon(Icons.last_page),
          tooltip: 'Last Page',
          onPressed: inventoryState.currentPage < inventoryState.totalPages ? () => inventoryNotifierAccess.goToPage(inventoryState.totalPages) : null,
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: const Color.fromARGB(255, 94, 157, 208)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromARGB(255, 201, 215, 227),
                  highlightColor: const Color.fromARGB(255, 94, 157, 208),
                  child: SizedBox(
                    width: 200,
                    height: 10,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
