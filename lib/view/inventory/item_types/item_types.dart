// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/view/inventory/item_types/additemtype.dart';
import 'package:jcsd_flutter/view/inventory/item_types/archiveitemtype.dart';
import 'package:jcsd_flutter/view/inventory/item_types/edititemtype.dart';
import 'package:jcsd_flutter/view/inventory/item_types/item_types_archive.dart';

class ItemTypesPage extends StatefulWidget {
  const ItemTypesPage({super.key});

  @override
  _ItemTypesPageState createState() => _ItemTypesPageState();
}

class _ItemTypesPageState extends State<ItemTypesPage> {
  final String _activeSubItem = '/inventory';

  void _showAddItemTypeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AddItemTypeModal();
      },
    );
  }

  void _showEditItemTypeModal(
      String itemId, String typeName, String description) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EditItemTypeModal(
          itemId: itemId,
          typeName: typeName,
          description: description,
        );
      },
    );
  }

  void _showArchiveItemTypeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ArchiveItemTypeModal();
      },
    );
  }

  void _navigateToArchiveItemTypesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ItemTypesArchivePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: null,
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Item Types',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _navigateToArchiveItemTypesPage,
                        icon: const FaIcon(
                          FontAwesomeIcons.boxArchive,
                          color: Colors.white,
                          size: 18,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          minimumSize: const Size(180, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        label: const Text(
                          'Archive Item Types',
                          style: TextStyle(
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                        onPressed: _showAddItemTypeModal,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _buildDataTable(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Type Name',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Center(
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'NunitoSans',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Padding(
                  padding: EdgeInsets.only(left: 130),
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
              _buildDataRow('IT001', 'Electronics', 'Electronic devices'),
              _buildDataRow('IT002', 'Furniture', 'Home and office furniture'),
              _buildDataRow('IT003', 'Groceries', 'Daily grocery items'),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String itemId, String typeName, String description) {
    return DataRow(
      cells: [
        DataCell(
            Text(itemId, style: const TextStyle(fontFamily: 'NunitoSans'))),
        DataCell(
            Text(typeName, style: const TextStyle(fontFamily: 'NunitoSans'))),
        DataCell(Text(description,
            style: const TextStyle(fontFamily: 'NunitoSans'))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 75,
                child: ElevatedButton(
                  onPressed: () =>
                      _showEditItemTypeModal(itemId, typeName, description),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
              ),
              SizedBox(
                width: 75,
                child: ElevatedButton(
                  onPressed: _showArchiveItemTypeModal,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Icon(Icons.archive, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
