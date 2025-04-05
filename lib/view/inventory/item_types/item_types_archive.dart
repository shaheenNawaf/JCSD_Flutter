// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

//Default Imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_data.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/view/inventory/item_types/modals/unarchiveitemtype.dart';

//Backend Things
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_providers.dart';
import 'package:shimmer/shimmer.dart';

class ItemTypesArchivePage extends ConsumerStatefulWidget {
  const ItemTypesArchivePage({super.key});

  @override
  ConsumerState<ItemTypesArchivePage> createState() =>
      _ItemTypesArchivePageState();
}

class _ItemTypesArchivePageState extends ConsumerState<ItemTypesArchivePage> {
  final String _activeSubItem = '/inventory';

  void _showUnarchiveItemTypeModal(int typeID) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UnarchiveItemTypeModal(typeID: typeID);
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
                Header(
                  title: 'Item Types Archive',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () => Navigator.pop(context),
                  ),
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
    final fetchItemTypes = ref.watch(fetchArchivedTypes);

    return fetchItemTypes.when(
      data: (archivedTypes) {
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
          child: Column(
            children: [
            _buildHeaderRow(),
            const Divider(
                height: 1, color: Color.fromARGB(255, 188, 188, 188)),
            Expanded(
              child: ListView.builder(
                  itemCount: archivedTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildItemRow(archivedTypes, index);
                  }
                )
              ),
            ],
          ),
        );
      }, 
      error: (err, stackTrace) => Text('Error fetching data from table: $err'), 
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
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(List<ItemTypesData> items, int index) {
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
              items[index].itemType,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              items[index].itemDescription,
              style: const TextStyle(
                fontFamily: 'NunitoSans',
              ),
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
                      _showUnarchiveItemTypeModal(items[index].itemTypeID);
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

  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
              'Description',
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
}
