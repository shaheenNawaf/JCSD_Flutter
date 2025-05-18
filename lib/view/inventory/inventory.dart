// lib/view/inventory/inventory.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, deprecated_member_use

//Default Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jcsd_flutter/view/manufacturers/manufacturers.dart';
import 'package:shimmer/shimmer.dart';

// Product Definition Imports
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';

// For Dropdowns and Search (mainly for JOINS but yeah)
import 'package:jcsd_flutter/backend/modules/inventory/item_types/itemtypes_service.dart'; // Needed for name lookup

// -- UI Imports here -- //

// New Modals for Product Definition
import 'package:jcsd_flutter/view/inventory/product_definitions/modals/add_prod_def_modal.dart';
import 'package:jcsd_flutter/view/inventory/product_definitions/modals/edit_prod_def_modal.dart';
import 'package:jcsd_flutter/view/inventory/product_definitions/modals/archive_prod_def_modal.dart';

// Generic Imports
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  final String _activeSubItem = '/inventory';
  final bool isVisibleFilter = true;

  void _showAddProductDefinitionModal(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddProdDefModal(isVisible: isVisibleFilter));
  }

  void _showEditProductDefinitionModal(BuildContext context, WidgetRef ref,
      ProductDefinitionData productDefinition) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => EditProductDefinitionModal(
            productDefinition: productDefinition,
            isVisibleContext: isVisibleFilter));
  }

  void _showArchiveProductDefinitionModal(BuildContext context, WidgetRef ref,
      ProductDefinitionData productDefinition) {
    if (productDefinition.prodDefID == null) {
      print("Error: Cannot archive product definition with null ID.");
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => ArchiveProductDefinitionModal(
            prodDefID: productDefinition.prodDefID!,
            prodDefName: productDefinition.prodDefName,
            isVisibleContext: isVisibleFilter));
  }

  //Navigation Buttons
  void _navigateToItemTypesPage(BuildContext context) {
    context.push('/itemTypes');
  }

  void _navigateToManufacturersPage(BuildContext context) {
    context.push('/manufacturers');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue =
        ref.watch(productDefinitionNotifierProvider(isVisibleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
              child: Column(
            children: [
              const Header(title: 'Inventory - Product Definitions'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: asyncValue.when(
                    loading: () => _buildLoadingIndicator(),
                    error: (error, stackTrace) =>
                        _buildErrorWidget(error, stackTrace, ref),
                    data: (productDefState) {
                      if (productDefState.productDefinitions.isEmpty &&
                          productDefState.searchText.isEmpty) {
                        return _buildEmptyState(context, ref);
                      }
                      return _buildWebView(context, ref, productDefState);
                    },
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildWebView(BuildContext context, WidgetRef ref,
      ProductDefinitionState productDefState) {
    return Column(
      children: [
        _buildTopControls(context, ref),
        const SizedBox(height: 16),
        Expanded(child: _buildDataTable(context, ref, productDefState)),
        const SizedBox(height: 16),
        _buildPaginationControls(context, ref, productDefState),
      ],
    );
  }

  Widget _buildTopControls(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _navigateToItemTypesPage(context),
          icon: const Icon(
            Icons.category,
            color: Colors.white,
            size: 16,
          ),
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
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => context.push('/manufacturers'),
          icon: const Icon(
            Icons.precision_manufacturing,
            color: Colors.white,
            size: 16,
          ),
          label: const Text(
            'Manufacturers',
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
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => context.go('/suppliers'),
          icon: const Icon(
            Icons.local_shipping,
            color: Colors.white,
            size: 16,
          ),
          label: const Text(
            'Suppliers',
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
              hintText: 'Search Name/Desc/Type/Mfg...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              hintStyle: const TextStyle(
                color: Color(0xFFABABAB),
                fontFamily: 'NunitoSans',
              ),
            ),
            onChanged: (searchText) => ref
                .read(
                    productDefinitionNotifierProvider(isVisibleFilter).notifier)
                .search(searchText),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddProductDefinitionModal(context, ref),
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text(
            'Add Product',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'NunitoSans',
                fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref,
      ProductDefinitionState productDefState) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5)
          ]),
      child: Column(
        children: [
          _buildHeaderRow(context, ref, productDefState),
          const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
          Expanded(
            child: ListView.builder(
              itemCount: productDefState.productDefinitions.length,
              itemBuilder: (BuildContext context, int index) {
                final item = productDefState.productDefinitions[index];
                final rowColor =
                    index % 2 == 0 ? Colors.white : const Color(0xFFF8F8F8);
                return _buildItemRow(context, ref, item, rowColor,
                    ValueKey(item.prodDefID)); // Use ID as key
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, WidgetRef ref,
      ProductDefinitionState productDefState) {
    const headerTextStyle = TextStyle(
        fontFamily: 'NunitoSans',
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 13);
    return Container(
      color: const Color.fromRGBO(0, 174, 239, 1),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildHeaderCell(
              context, ref, productDefState, 'ID', 'prodDefID', headerTextStyle,
              flex: 1),
          _buildHeaderCell(context, ref, productDefState, 'Name', 'prodDefName',
              headerTextStyle,
              flex: 3),
          _buildHeaderCell(context, ref, productDefState, 'Type', 'itemTypeID',
              headerTextStyle,
              flex: 2),
          _buildHeaderCell(context, ref, productDefState, 'Manufacturer',
              'manufacturerName', headerTextStyle,
              flex: 2),
          _buildHeaderCell(context, ref, productDefState, 'MSRP', 'prodDefMSRP',
              headerTextStyle,
              flex: 1),
          _buildHeaderCell(context, ref, productDefState, 'Current Stock',
              'item_serials.count', headerTextStyle,
              flex: 2),
          _buildHeaderCell(context, ref, productDefState, 'Description',
              'prodDefDescription', headerTextStyle,
              flex: 3),
          const Expanded(
              flex: 2,
              child: Text('Actions',
                  style: headerTextStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
      BuildContext context,
      WidgetRef ref,
      ProductDefinitionState state,
      String columnTitle,
      String sortByColumn,
      TextStyle textStyle,
      {int flex = 1}) {
    bool isCurrentlySorted = state.sortBy == sortByColumn;
    Icon? sortIcon = isCurrentlySorted
        ? Icon(state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.white, size: 18)
        : null;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => ref
            .read(productDefinitionNotifierProvider(isVisibleFilter).notifier)
            .sort(sortByColumn),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Tooltip(
                  message: columnTitle,
                  child: Text(columnTitle,
                      style: textStyle, overflow: TextOverflow.ellipsis),
                ),
              ),
              if (sortIcon != null) ...[const SizedBox(width: 1), sortIcon],
            ],
          ),
        ),
      ),
    );
  }

  // Builds a single data row for a Product Definition
  Widget _buildItemRow(BuildContext context, WidgetRef ref,
      ProductDefinitionData item, Color rowColor, Key key) {
    //Formatting the data, prior presentation and ensuring data integrity
    String formattedID =
        item.prodDefID?.split('-').first ?? 'N/A'; // Handle potential null ID
    String msrp = item.prodDefMSRP != null
        ? '₱ ${item.prodDefMSRP!.toStringAsFixed(2)}'
        : 'N/A';
    String description = item.prodDefDescription ?? 'N/A';
    String manufacturer = item.manufacturerName;
    String desiredStockLevel = item.desiredStockLevel.toString();
    String currentStock = item.serialsCount?.toString() ?? '0';

    const rowTextStyle = TextStyle(fontFamily: 'NunitoSans', fontSize: 13);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: rowColor,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(formattedID,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 3,
              child: Text(item.prodDefName,
                  style: rowTextStyle, overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: FutureBuilder<String>(
              future: ItemtypesService().getTypeNameByID(item.itemTypeID),
              builder: (context, snapshot) => Text(snapshot.data ?? '...',
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(manufacturer,
                style: rowTextStyle,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 2,
            child: Text(msrp,
                style: rowTextStyle,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 1,
            child: _stockStatusChip(
              currentQuantity: int.tryParse(currentStock) ?? 0,
              desiredStockLevel: int.tryParse(desiredStockLevel) ?? 0,
            ),
          ),
          Expanded(
            flex: 3,
            child: Tooltip(
              message: description,
              child: Text(description,
                  style: rowTextStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
          ),
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'View Serials',
                    child: ElevatedButton(
                      onPressed: () {
                        // Ensure ID is not null before navigating
                        if (item.prodDefID != null) {
                          final String? productDefinitionId = item.prodDefID;
                          final String productDefinitionName = item.prodDefName;
                          context.go(
                            '/inventory/serials',
                            extra: {
                              'prodDefId': productDefinitionId,
                              'prodDefName': productDefinitionName
                            },
                          );
                        } else {
                          print(
                              "Error: Cannot view serials for null prodDefID");
                          // Optionally show feedback to user
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.list_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Edit Product',
                    child: ElevatedButton(
                      onPressed: () =>
                          _showEditProductDefinitionModal(context, ref, item),
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
                  Tooltip(
                    message: 'Archive Product',
                    child: ElevatedButton(
                      onPressed: () => _showArchiveProductDefinitionModal(
                          context, ref, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.archive,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _stockStatusChip({
    required int currentQuantity,
    required int desiredStockLevel,
    double lowStockThreshold = 0.3, //30% total serial items remaining
    double mediumStockThreshold = 0.7, //70% total serial items remaining
  }) {
    Color chipColor = Colors.grey; // Default
    Color textColor = Colors.white;

    final double stockRatio = currentQuantity / desiredStockLevel;

    if (stockRatio < lowStockThreshold) {
      chipColor = Colors.red;
    } else if (stockRatio < mediumStockThreshold) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.green;
    }

    return Tooltip(
      message: "The desired stock level is $desiredStockLevel",
      child: Center(
        child: Chip(
          label: Text(
            currentQuantity.toString(),
            style: TextStyle(color: textColor, fontSize: 11),
          ),
          backgroundColor: chipColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, WidgetRef ref,
      ProductDefinitionState productDefState) {
    final notifier =
        ref.read(productDefinitionNotifierProvider(isVisibleFilter).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
            onPressed: productDefState.currentPage > 1
                ? () => notifier.goToPage(1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
            onPressed: productDefState.currentPage > 1
                ? () => notifier.goToPage(productDefState.currentPage - 1)
                : null,
            splashRadius: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
                'Page ${productDefState.currentPage} of ${productDefState.totalPages}',
                style:
                    const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'))),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
            onPressed: productDefState.currentPage < productDefState.totalPages
                ? () => notifier.goToPage(productDefState.currentPage + 1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
            onPressed: productDefState.currentPage < productDefState.totalPages
                ? () => notifier.goToPage(productDefState.totalPages)
                : null,
            splashRadius: 20),
      ],
    );
  }

  Widget _buildShimmerHeader() {
    const headerPlaceholderColor = Color.fromRGBO(0, 174, 239, 0.5);
    return Container(
      color: headerPlaceholderColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Row(children: [
          Expanded(flex: 2, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 5, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        // Match row flex values
        Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 5, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: 3,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle))
            ])),
      ]),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(children: [
      _buildTopControlsPlaceholder(),
      const SizedBox(height: 16),
      Expanded(
          child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(children: [
            _buildShimmerHeader(),
            const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
            Expanded(
                child: ListView(
                    children: List.generate(8, (_) => _buildShimmerRow()))),
          ]),
        ),
      )),
      const SizedBox(height: 16),
      _buildPaginationPlaceholder(),
    ]);
  }

  Widget _buildTopControlsPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(children: [
          Container(
              height: 36,
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Container(
              height: 36,
              width: 120,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Container(
              height: 36,
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const Spacer(),
          Container(
              height: 40,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 16),
          Container(
              height: 36,
              width: 80,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
        ]),
      ),
    );
  }

  Widget _buildPaginationPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 12),
          Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
        ]),
      ),
    );
  }

  Widget _buildErrorWidget(
      Object error, StackTrace? stackTrace, WidgetRef ref) {
    print('Inventory Page Error: $error \n $stackTrace');
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent, size: 60),
      const SizedBox(height: 16),
      const Text('Error Loading Product Definitions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700])),
      const SizedBox(height: 20),
      ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          onPressed: () => ref
              .invalidate(productDefinitionNotifierProvider(isVisibleFilter))),
    ]));
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.boxOpen, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      const Text('No active Product Definitions found.',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddProductDefinitionModal(context, ref),
          label: const Text('Add New Product Definition'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    ]));
  }
}
