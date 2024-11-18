// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/modals/additem.dart';
import 'package:jcsd_flutter/modals/edititem.dart';
import 'package:jcsd_flutter/modals/archiveitem.dart';
import 'package:jcsd_flutter/modals/stockinitem.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';

//Inventory Backend Imports -- Please don't touch
import 'package:jcsd_flutter/api/supa_details.dart';
import 'package:jcsd_flutter/providers/inventory_state.dart';
import 'package:jcsd_flutter/services/inventory_service.dart';
import 'package:jcsd_flutter/models/inventory_data.dart';

//Suppliers Mini-Service
// To be added later

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final String _activeSubItem = '/inventory';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _animationController.forward();
  }

  void _closeDrawer() {
    _animationController.reverse();
  }

  void _showAddItemModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddItemModal();
      },
    );
  }

  void _showEditItemModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const EditItemModal();
      },
    );
  }

  void _showArchiveItemModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ArchiveItemModal();
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

  void _navigateToProfile() {}

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF00AEEF),
              title: const Text(
                'Inventory',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.bars,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                    _openDrawer();
                  },
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: _showAddItemModal,
                ),
              ],
            )
          : null,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF00AEEF),
              child: Sidebar(
                activePage: _activeSubItem,
                onClose: _closeDrawer,
              ),
            )
          : null,
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          _closeDrawer();
        }
      },
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) Sidebar(activePage: _activeSubItem),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile)
                      Header(
                        title: 'Inventory',
                        onAvatarTap: _navigateToProfile,
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildMobileSearchBar(),
                                  const SizedBox(height: 16),
                                  Expanded(child: _buildMobileListView()),
                                ],
                              )
                            : _buildWebView(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMobile)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animationController.value * 0.6,
                  child: _animationController.value > 0
                      ? Container(
                          color: Colors.black,
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchBar() {
    return SizedBox(
      width: double.infinity,
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

  Widget _buildMobileListView() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              title: const Text(
                'Samsung SSD 500GB',
                style: TextStyle(
                  fontFamily: 'NunitoSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Samsung',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.yellow,
                    child: const Text(
                      'In stock: 50',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '0126546',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                  Text(
                    'Technology',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              height: 1,
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDataTable(BuildContext context) {
  final fetchInventory = ref.watch(fetchInventoryList);

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
            const Divider(height: 1, color: Colors.grey),
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
    error: (err, stackTrace) => Text('Error fetching data from table: $err'),
    loading: () => const LinearProgressIndicator(
      backgroundColor: Color.fromRGBO(0, 134, 239, 1),
    ),
  );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromRGBO(0, 134, 239, 1),
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

  Widget _buildItemRow(List<InventoryData> items, int index) {
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
              textAlign: TextAlign.center, // Center-align Item ID
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
            child: Text(
              items[index].itemType.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              items[index].supplierID.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
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
                'P ${items[index].itemQuantity.toString()}',
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
              items[index].itemQuantity.toString(),
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: _showEditItemModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: _showArchiveItemModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Archive',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
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
    );
  }


  Color _itemQuantityColor (int itemQuantity){
    if (itemQuantity < 10){
      return Colors.red;
    }else if(itemQuantity < 20){
      return Colors.yellow;
    }else{
      return Colors.green;
    }
  }
}