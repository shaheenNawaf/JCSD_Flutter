// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

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
                  onPressed: () {
                    // Add functionality here
                  },
                ),
              ],
            )
          : null,
      drawer: isMobile
          ? Drawer(
              backgroundColor: const Color(0xFF00AEEF),
              child: Sidebar(
                activePage: 'inventory',
                onClose: _closeDrawer,
              ),
            )
          : null,
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          _closeDrawer(); // Ensure dimming effect reverses when drawer is closed
        }
      },
      body: Stack(
        children: [
          Row(
            children: [
              if (!isMobile) const Sidebar(activePage: 'inventory'),
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
                              'Inventory',
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
          // Dark overlay when drawer is open on mobile
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
                onPressed: () {},
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
          child: _buildDataTable(),
        ),
      ],
    );
  }

  Widget _buildMobileListView() {
    return ListView.builder(
      itemCount: 10, // Example data count
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
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
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

  Widget _buildDataTable() {
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
          ),
        ],
      ),
      child: ListView(
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFF00AEEF),
            ),
            columns: const [
              DataColumn(
                label: Center(
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
              ),
              DataColumn(
                label: Center(
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
              ),
              DataColumn(
                label: Center(
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
              ),
              DataColumn(
                label: Center(
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
              ),
              DataColumn(
                label: Center(
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
              ),
              DataColumn(
                label: Center(
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
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.only(left: 75),
                  child: Center(
                    child: Text(
                      'Update',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
            rows: [
              _buildDataRow(
                '0126546',
                'Samsung SSD 500GB',
                'Technology',
                'Samsung',
                '12 pcs',
                'P500',
                Colors.green,
              ),
              _buildDataRow(
                '0126546',
                'Samsung SSD 500GB',
                'Technology',
                'Samsung',
                '2 pcs',
                'P500',
                Colors.red,
              ),
              _buildDataRow(
                '0126546',
                'Samsung SSD 500GB',
                'Technology',
                'Samsung',
                '5 pcs',
                'P500',
                Colors.yellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String id, String name, String type, String supplier,
      String quantity, String price, Color quantityColor) {
    return DataRow(
      color: WidgetStateProperty.all(Colors.white),
      cells: [
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(
            id,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(
            type,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(
            supplier,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: quantityColor,
              // border: Border.all(
              //     color: const Color.fromARGB(255, 225, 225, 225), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              quantity,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Text(
            price,
            style: const TextStyle(
              fontFamily: 'NunitoSans',
            ),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {},
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
              const SizedBox(width: 4),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
