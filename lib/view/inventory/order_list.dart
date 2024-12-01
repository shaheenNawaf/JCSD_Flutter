// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/view/inventory/modals/confirmorder.dart';
import 'package:jcsd_flutter/view/inventory/modals/editorder.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
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

  void _showEditItemModal(
    String itemId,
    String itemName,
    String itemType,
    String supplier,
    String quantity,
    String price,
    String status,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditOrderModal(
          orderId: itemId,
          itemName: itemName,
          itemType: itemType,
          supplier: supplier,
          quantity: quantity,
          price: price,
          status: status,
        );
      },
    );
  }

  void _showConfirmItemModal(String id, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ConfirmOrderModal();
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
                'Order List',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.arrowLeft,
                                    color: Color(0xFF00AEEF),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Order List',
                                  style: TextStyle(
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00AEEF),
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const CircleAvatar(
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
          child: SizedBox(
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
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          title: const Text(
            'Item Name',
            style: TextStyle(
              fontFamily: 'NunitoSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text(
            'Description of item',
            style: TextStyle(
              fontFamily: 'NunitoSans',
            ),
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {},
            child: const Text(
              'Action',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
                label: Text(
                  'Item ID',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Item Name',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Item Type',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Supplier',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Quantity',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Price',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'NunitoSans',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.only(left: 60),
                  child: Center(
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontFamily: 'NunitoSans',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows: [
              _buildDataRow(
                '2',
                'Mechanical Keyboard',
                'Accessories',
                'Digital Center Enterprises',
                '1 pcs',
                'P 1,000,000',
                'Pending',
              ),
              _buildDataRow(
                '3',
                'Wireless Mouse',
                'Peripherals',
                'Gadget Hub Ltd.',
                '100 pcs',
                'P 200',
                'Processing',
              ),
              _buildDataRow(
                '4',
                '24" LED Monitor',
                'Components',
                'Gadget Hub Ltd.',
                '30 pcs',
                'P 200',
                'For Confirmation',
              ),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
    String id,
    String name,
    String type,
    String supplier,
    String quantity,
    String price,
    String status,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(id)),
        DataCell(Text(name)),
        DataCell(Text(type)),
        DataCell(Text(supplier)),
        DataCell(Text(quantity)),
        DataCell(Text(price)),
        DataCell(Text(status)),
        DataCell(
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _showEditItemModal(
                  id,
                  name,
                  type,
                  supplier,
                  quantity,
                  price,
                  status,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showConfirmItemModal(id, name),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
