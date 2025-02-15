// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

// Packages for usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/inventory_state.dart';

//For Animation
import 'package:shimmer/shimmer.dart';

// Pages
import 'package:jcsd_flutter/view/inventory/modals/additem.dart';
import 'package:jcsd_flutter/view/inventory/modals/edititem.dart';
import 'package:jcsd_flutter/view/inventory/modals/archiveitem.dart';
import 'package:jcsd_flutter/view/inventory/modals/stockinitem.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/view/inventory/borrowed_items/viewborroweditem.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';

// Inventory
import 'package:jcsd_flutter/backend/modules/inventory/inventory_data.dart';
import 'package:jcsd_flutter/view/inventory/item_types/item_types.dart';

// Suppliers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final String _activeSubItem = '/inventory';

  void _showAddItemModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddItemModal();
      },
    );
  }

  void _showBorrowedItemsModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const BorrowedItems();
      },
    );
  }

  _showEditItemModal(InventoryData items, int itemID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditItemModal(itemData: items, itemInventoryID: itemID);
      },
    );
  }

  _showArchiveItemModal(InventoryData items, int itemID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ArchiveItemModal(itemID: itemID, itemData: items);
      },
    );
  }

  void _showStockInItemModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const StockInItemModal();
      },
    );
  }

  void _navigateToItemTypesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ItemTypesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                const Header(
                  title: 'Inventory',
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildWebView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _navigateToItemTypesPage,
                icon: const Icon(Icons.topic_rounded, color: Colors.white),
                label: const Text(
                  'Item Types',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showBorrowedItemsModal,
                icon: const Icon(Icons.inventory, color: Colors.white),
                label: const Text(
                  'Borrowed Items',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 250,
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Color(0xFFABABAB),
                      fontFamily: 'NunitoSans',
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showStockInItemModal,
                icon: const Icon(Icons.inventory, color: Colors.white),
                label: const Text(
                  'Stock In',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _showAddItemModal,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildDataTable(context),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final fetchInventory = ref.watch(fetchActive);

    return fetchInventory.when(
        data: (items) {
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
                _buildHeaderRow(),
                const Divider(
                    height: 1, color: Color.fromARGB(255, 188, 188, 188)),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _buildItemRow(items, index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        error: (err, stackTrace) =>
            Text('Error fetching data from table: $err'),
        loading: () => Shimmer.fromColors(
              baseColor: const Color.fromARGB(255, 207, 233, 255),
              highlightColor: const Color.fromARGB(255, 114, 190, 253),
              child: Column(
                children: [
                  _buildShimmerRow(),
                  const Divider(
                    height: 1,
                    color: Color.fromARGB(255, 188, 188, 188),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _buildShimmerRow();
                        }),
                  )
                ],
              ),
            ));
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Item ID',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Item Name',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Item Type',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Supplier',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Quantity',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Price',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Actions',
              style: TextStyle(
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> fetchTypeName(int typeID) async {
    final fetchTypes = ItemtypesService();
    String typeName = await fetchTypes.getTypeNameByID(typeID);

    return typeName;
  }

  Widget _buildItemTypeCell(int typeID, BuildContext context) {
    final itemTypesProvider = ItemtypesService();

    return FutureBuilder(
      future: itemTypesProvider.getTypeNameByID(typeID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String typeName = snapshot.data ?? '';
          return Text(
            typeName,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ),
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  Widget _buildItemRow(List<InventoryData> items, int index) {
    final SuppliersService suppliersService = SuppliersService();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              items[index].itemID.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              items[index].itemName.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: _buildItemTypeCell(items[index].itemTypeID, context),
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: suppliersService
                  .getSupplierNameByID(items[index].supplierID.toInt()),
              builder: (context, supplierName) {
                if (supplierName.hasData) {
                  return Text(
                    supplierName.data!,
                    style: const TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                } else if (supplierName.hasError) {
                  return const Text(
                    "Error fetching",
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                } else {
                  return const Text(
                    "No supplier found",
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _itemQuantityColor(items[index].itemQuantity),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${items[index].itemQuantity.toString()} pcs',
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
              'P ${items[index].itemPrice.toString()}',
              style: const TextStyle(fontFamily: 'NunitoSans'),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    onPressed: () {
                      _showEditItemModal(items[index], items[index].itemID);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 75,
                  child: ElevatedButton(
                    onPressed: () {
                      _showArchiveItemModal(items[index], items[index].itemID);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Icon(
                      Icons.archive,
                      color: Colors.white,
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

  Color _itemQuantityColor(int itemQuantity) {
    if (itemQuantity < 10) {
      return Colors.red;
    } else if (itemQuantity < 20) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }
}
