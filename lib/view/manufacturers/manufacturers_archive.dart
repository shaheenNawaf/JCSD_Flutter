// ignore_for_file: library_private_types_in_public_api, avoid_print

//Base Imports
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Backend & State Imports
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_providers.dart';

// Widgets and Modals
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/view/manufacturers/modals/unarchive_manufacturer_modal.dart';

class ManufacturersArchivePage extends ConsumerWidget {
  const ManufacturersArchivePage({super.key});

  final String _activeSubItem = '/manufacturers-archive';
  final bool isVisibleFilter = false;

  void _showUnarchiveManufacturerModal(
      BuildContext context, WidgetRef ref, ManufacturersData manufacturer) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => UnarchiveManufacturerModal(
            manufacturerID: manufacturer.manufacturerID,
            manufacturerName: manufacturer.manufacturerName,
            isVisibleContext: isVisibleFilter));
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
              const Header(title: 'Inventory - Archived Manufacturers'),
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
                        return _buildEmptyState();
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

  Widget _buildWebView(BuildContext context, WidgetRef ref,
      ManufacturersState manufacturerState) {
    return Column(
      children: [
        _buildTopControls(context, ref),
        const SizedBox(height: 16),
        Expanded(child: _buildDataTable(context, ref, manufacturerState)),
        const SizedBox(height: 16),
        if (manufacturerState.totalPages > 1)
          _buildPaginationControls(context, ref, manufacturerState),
      ],
    );
  }

  Widget _buildTopControls(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Spacer(),
        SizedBox(
          width: 250,
          height: 40,
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Search Archived Manufacturers...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                hintStyle: const TextStyle(fontSize: 12)),
            onChanged: (searchText) => ref
                .read(manufacturersNotifierProvider(isVisibleFilter).notifier)
                .search(searchText),
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
            child: manufacturerState.manufacturers.isEmpty
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                            'No Archived Manufacturers match search: "${manufacturerState.searchText}"',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                            textAlign: TextAlign.center)))
                : ListView.builder(
                    itemCount: manufacturerState.manufacturers.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = manufacturerState.manufacturers[index];
                      final rowColor = index % 2 == 0
                          ? Colors.white
                          : const Color(0xFFF8F8F8);
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
                      message: 'Restore Manufacturer',
                      child: IconButton(
                          icon: const Icon(Icons.unarchive,
                              color: Colors.green, size: 18),
                          onPressed: () => _showUnarchiveManufacturerModal(
                              context, ref, item),
                          splashRadius: 18,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 5))),
                ],
              )),
        ],
      ),
    );
  }

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

  // Builds the error display widget
  Widget _buildErrorWidget(
      Object error, StackTrace? stackTrace, WidgetRef ref) {
    print('Manufacturers Archive Page Error: $error \n $stackTrace');
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent, size: 60),
      const SizedBox(height: 16),
      const Text('Error Loading Archived Manufacturers',
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
  Widget _buildEmptyState() {
    return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(FontAwesomeIcons.boxArchive, size: 80, color: Colors.grey),
      SizedBox(height: 16),
      Text('No archived Manufacturers found.',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
    ]));
  }
}
