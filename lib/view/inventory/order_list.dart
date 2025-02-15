import 'package:flutter/material.dart';
import 'package:jcsd_flutter/view/inventory/modals/confirmorder.dart';
import 'package:jcsd_flutter/view/inventory/modals/deleteitem.dart';
import 'package:jcsd_flutter/view/inventory/modals/editorder.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final String _activeSubItem = '/orderList';

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

  void _showDeleteItemModal(String id, String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const DeleteOrderModal();
      },
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
                const Header(title: 'Order List'),
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
            headingRowColor: WidgetStateProperty.all(const Color(0xFF00AEEF)),
            columnSpacing: 10, // Adjust column spacing for better alignment
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
                label: Align(
                  alignment: Alignment.centerLeft, // Shift "Quantity" text left
                  child: Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
                  padding: EdgeInsets.only(left: 70),
                  child: Center(
                    child: Text(
                      'Actions',
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
        DataCell(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(quantity),
          ),
        ),
        DataCell(Text(price)),
        DataCell(Text(status)),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                child: ElevatedButton(
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
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 50,
                child: ElevatedButton(
                  onPressed: () => _showConfirmItemModal(id, name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.check_box,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 50,
                child: ElevatedButton(
                  onPressed: () => _showDeleteItemModal(id, name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
