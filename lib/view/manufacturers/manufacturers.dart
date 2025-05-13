// ignore_for_file: library_private_types_in_public_api, avoid_print

//Base Imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jcsd_flutter/view/inventory/inventory.dart';
import 'package:jcsd_flutter/view/manufacturers/manufacturers_archive.dart';
import 'package:shimmer/shimmer.dart';

// Backend & State Imports; Strictly for Manufacturers only
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';

// Widgets and Modals

import 'package:jcsd_flutter/view/manufacturers/modals/add_manufacturer_modal.dart';
import 'package:jcsd_flutter/view/manufacturers/modals/edit_manufacturer_modal.dart';
import 'package:jcsd_flutter/view/manufacturers/modals/archive_manufacturer_modal.dart';

//UI Only
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';

/// Displays the list of active Manufacturers.
class ManufacturersPage extends ConsumerWidget {
  const ManufacturersPage({super.key});

  final String _activeSubItem = '/manufacturers';
  final bool isVisibleFilter = true;

  void _showAddManufacturerModal(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            AddManufacturerModal(isVisibleContext: isVisibleFilter));
  }

  void _showEditManufacturerModal(
      BuildContext context, WidgetRef ref, ManufacturersData manufacturer) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => EditManufacturerModal(
            manufacturerData: manufacturer, isVisibleContext: isVisibleFilter));
  }

  void _showArchiveManufacturerModal(
      BuildContext context, WidgetRef ref, ManufacturersData manufacturer) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => ArchiveManufacturerModal(
            manufacturerID: manufacturer.manufacturerID,
            manufacturerName: manufacturer.manufacturerName,
            isVisibleContext: isVisibleFilter));
  }

  void _navigateToProductDefinitions(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const InventoryPage()));
  }

  void _navigateToArchivedManufacturers(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ManufacturersArchivePage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue =
        ref.watch(manufacturersNotifierProvider(isVisibleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
              child: Column(
            children: [
              const Header(title: 'Inventory - Manufacturers'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: asyncValue.when(
                    loading: () => _buildLoadingIndicator(),
                    error: (error, stackTrace) =>
                        _buildErrorWidget(error, stackTrace, ref),
                    data: (manufacturerState) {
                      if (manufacturerState.manufacturers.isEmpty &&
                          manufacturerState.searchText.isEmpty) {
                        return _buildEmptyState(context, ref);
                      }
                      return _buildWebView(context, ref, manufacturerState);
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

  // Builds the main view containing controls, table, and pagination
  Widget _buildWebView(BuildContext context, WidgetRef ref,
      ManufacturersState manufacturerState) {
    return Column(
      children: [
        _buildTopControls(context, ref),
        const SizedBox(height: 16),
        Expanded(child: _buildDataTable(context, ref, manufacturerState)),
        const SizedBox(height: 16),
        if (manufacturerState.totalPages > 1) // Only show pagination if needed
          _buildPaginationControls(context, ref, manufacturerState),
      ],
    );
  }

  Widget _buildTopControls(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => _navigateToArchivedManufacturers(context),
          icon: const Icon(
            Icons.category,
            color: Colors.white,
            size: 16,
          ),
          label: const Text(
            'Archived Manufacturers',
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
          onPressed: () => _navigateToProductDefinitions(context),
          icon: const Icon(
            Icons.category,
            color: Colors.white,
            size: 16,
          ),
          label: const Text(
            'Product Definitions',
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
              hintText: 'Search Name/Email/Contact...',
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
                .read(manufacturersNotifierProvider(isVisibleFilter).notifier)
                .search(searchText),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showAddManufacturerModal(context, ref),
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text(
            'Add Manufacturer',
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
      ManufacturersState manufacturerState) {
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
          _buildHeaderRow(context, ref, manufacturerState),
          const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
          Expanded(
            child: ListView.builder(
              itemCount: manufacturerState.manufacturers.length,
              itemBuilder: (BuildContext context, int index) {
                final item = manufacturerState.manufacturers[index];
                final rowColor =
                    index % 2 == 0 ? Colors.white : const Color(0xFFF8F8F8);
                return _buildItemRow(context, ref, item, rowColor,
                    ValueKey(item.manufacturerID));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, WidgetRef ref,
      ManufacturersState manufacturerState) {
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
          _buildHeaderCell(context, ref, manufacturerState, 'Name',
              'manufacturerName', headerTextStyle,
              flex: 3),
          _buildHeaderCell(context, ref, manufacturerState, 'Email',
              'manufacturerEmail', headerTextStyle,
              flex: 3),
          _buildHeaderCell(context, ref, manufacturerState, 'Contact',
              'contactNumber', headerTextStyle,
              flex: 2),
          _buildHeaderCell(context, ref, manufacturerState, 'Address',
              'address', headerTextStyle,
              flex: 4),
          const Expanded(
              flex: 2,
              child: Text('Actions',
                  style: headerTextStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  // Builds a single sortable header cell
  Widget _buildHeaderCell(
      BuildContext context,
      WidgetRef ref,
      ManufacturersState state,
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
            .read(manufacturersNotifierProvider(isVisibleFilter).notifier)
            .sort(sortByColumn),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(columnTitle,
                      style: textStyle, overflow: TextOverflow.ellipsis)),
              if (sortIcon != null) ...[const SizedBox(width: 2), sortIcon],
            ],
          ),
        ),
      ),
    );
  }

  // Builds a single data row for a Manufacturer
  Widget _buildItemRow(BuildContext context, WidgetRef ref,
      ManufacturersData item, Color rowColor, Key key) {
    String address = item.address ?? 'N/A';
    const rowTextStyle = TextStyle(fontFamily: 'NunitoSans', fontSize: 13);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: rowColor,
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(item.manufacturerName,
                  style: rowTextStyle, overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 3,
              child: Text(item.manufacturerEmail,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 2,
              child: Text(item.contactNumber ?? 'N/A',
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 4,
              child: Tooltip(
                  message: address,
                  child: Text(address,
                      style: rowTextStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1))),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: 'Edit Manufacturer',
                  child: ElevatedButton(
                    onPressed: () =>
                        _showEditManufacturerModal(context, ref, item),
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
                  message: 'Archive Manufacturer',
                  child: ElevatedButton(
                    onPressed: () =>
                        _showArchiveManufacturerModal(context, ref, item),
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
            ),
          ),
        ],
      ),
    );
  }

  // Builds the pagination controls
  Widget _buildPaginationControls(BuildContext context, WidgetRef ref,
      ManufacturersState manufacturerState) {
    final notifier =
        ref.read(manufacturersNotifierProvider(isVisibleFilter).notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
            onPressed: manufacturerState.currentPage > 1
                ? () => notifier.goToPage(1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
            onPressed: manufacturerState.currentPage > 1
                ? () => notifier.goToPage(manufacturerState.currentPage - 1)
                : null,
            splashRadius: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
                'Page ${manufacturerState.currentPage} of ${manufacturerState.totalPages}',
                style:
                    const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'))),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
            onPressed:
                manufacturerState.currentPage < manufacturerState.totalPages
                    ? () => notifier.goToPage(manufacturerState.currentPage + 1)
                    : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
            onPressed:
                manufacturerState.currentPage < manufacturerState.totalPages
                    ? () => notifier.goToPage(manufacturerState.totalPages)
                    : null,
            splashRadius: 20),
      ],
    );
  }

  // UI Related Shit

  Widget _buildShimmerHeader() {
    const headerPlaceholderColor = Color.fromRGBO(0, 174, 239, 0.5);
    return Container(
      color: headerPlaceholderColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Row(children: [
          Expanded(flex: 1, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Container(height: 16, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        Expanded(flex: 1, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: 2,
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
          const Spacer(),
          Container(
              height: 40,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 16),
          Container(
              height: 36,
              width: 120,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      8))), // Adjusted width for "Add Manufacturer"
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
    print('Manufacturers Page Error: $error \n $stackTrace');
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent, size: 60),
      const SizedBox(height: 16),
      const Text('Error Loading Manufacturers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700])),
      const SizedBox(height: 20),
      ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          onPressed: () =>
              ref.invalidate(manufacturersNotifierProvider(isVisibleFilter))),
    ]));
  }

  // Builds the empty state display widget
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.industry, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      const Text('No active Manufacturers found.',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddManufacturerModal(context, ref),
          label: const Text('Add New Manufacturer'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    ]));
  }
}
