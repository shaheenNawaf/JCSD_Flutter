// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Packages for usage
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Pages
import 'package:jcsd_flutter/view/inventory/modals/unarchiveitem.dart';
import 'package:jcsd_flutter/backend/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

//Inventory
import 'package:jcsd_flutter/backend/inventory/inventory_state.dart';
import 'package:jcsd_flutter/backend/inventory/inventory_data.dart';

//Suppliers
import 'package:jcsd_flutter/backend/suppliers/suppliers_service.dart';

class ArchiveListPage extends ConsumerStatefulWidget {
  const ArchiveListPage({super.key});

  @override
  ConsumerState createState() => _ArchiveListPageState();
}

class _ArchiveListPageState extends ConsumerState<ArchiveListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final String _activeSubItem = '/archiveList';

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

  _showUnarchiveItemModal(InventoryData items, int itemID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UnarchiveItemModal(itemData: items, itemID: itemID);
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: isMobile
          ? AppBar(
              backgroundColor: const Color(0xFF00AEEF),
              title: const Text(
                'Archive List',
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
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) Sidebar(activePage: _activeSubItem),
              Expanded(
                child: Column(
                  children: [
                    if (!isMobile)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Archive List',
                              style: TextStyle(
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00AEEF),
                                fontSize: 20,
                              ),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/avatars/cat2.jpg'),
                            ),
                          ],
                        ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 350,
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
      itemCount: 1,
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
              subtitle: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type: Technology',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                  Text(
                    'Supplier: Samsung',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {},
                child: const Text(
                  'Unarchive',
                  style: TextStyle(color: Colors.white),
                ),
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
  final fetchInventory = ref.watch(fetchHiddenList);

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
            const Divider(height: 1, color: Color.fromARGB(255, 188, 188, 188)),
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

  Widget _buildItemTypeCell (int typeID, BuildContext context){
    final itemTypesProvider = ItemtypesService();

    return FutureBuilder(
      future: itemTypesProvider.getTypeNameByID(typeID), 
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Center the loading indicator
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
              future: suppliersService.getSupplierNameByID(items[index].supplierID.toInt()),
              builder: (context, supplierName) {
                if (supplierName.hasData){
                  return Text(
                    supplierName.data!,
                    style: const TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                }else if(supplierName.hasError){
                  return const Text(
                    "Error fetching",
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                    ),
                    textAlign: TextAlign.center,
                  );
                }else{
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
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () => _showUnarchiveItemModal(items[index], items[index].itemID),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 26, 118, 60),
                    ),
                    child: const Text(
                      'Unarchive',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        color: Colors.white,
                        fontSize: 12,
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
