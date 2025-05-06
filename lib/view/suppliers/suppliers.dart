// lib/view/suppliers/suppliers.dart
// ignore_for_file: library_private_types_in_public_api, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For potential icons
import 'package:shimmer/shimmer.dart'; // For loading

// --- UPDATED: Import New Providers/State/Notifier ---
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';

// Pages & Widgets
import 'package:jcsd_flutter/view/suppliers/modals/addsupplier.dart';
import 'package:jcsd_flutter/view/suppliers/modals/archivesupplier.dart';
import 'package:jcsd_flutter/view/suppliers/modals/editsupplier.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:jcsd_flutter/view/generic/dialogs/notification.dart'; // For feedback

// Displays the list of active Suppliers
class SupplierPage extends ConsumerStatefulWidget {
  const SupplierPage({super.key});

  @override
  ConsumerState<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends ConsumerState<SupplierPage>
    with SingleTickerProviderStateMixin {
  // Keep AnimationController if needed for other animations, otherwise remove
  late AnimationController _animationController;
  final bool isVisibleFilter = true; // Filter for active suppliers

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    // Initial fetch is handled by the notifier's build method
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Shows the modal to add a new supplier
  void _showAddSupplierModal() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AddSupplierModal());
  }

  // Shows the modal to edit an existing supplier
  void _showEditSupplierModal(SuppliersData supplier) {
    // Pass the data object
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => EditSupplierModal(
            supplierData: supplier)); // Assuming modal takes SuppliersData
  }

  // Shows the confirmation modal to archive a supplier
  void _showArchiveSupplierModal(SuppliersData supplier) {
    // Pass the data object
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ArchiveSupplierModal(
            supplierData: supplier)); // Assuming modal takes SuppliersData
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state for active suppliers
    final asyncValue = ref.watch(suppliersNotifierProvider(isVisibleFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          const Sidebar(activePage: '/suppliers'), // Keep sidebar
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Suppliers'), // Keep header
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    // Handle loading, error, and data states from the notifier
                    child: asyncValue.when(
                      loading: () => _buildLoadingIndicator(),
                      error: (error, stackTrace) =>
                          _buildErrorWidget(error, stackTrace, ref),
                      data: (supplierState) {
                        // Display empty state or the data table
                        if (supplierState.suppliers.isEmpty) {
                          return supplierState.searchText.isEmpty
                              ? _buildEmptyState(context)
                              : Center(
                                  child: Text(
                                      'No Suppliers match search: "${supplierState.searchText}"'));
                        }
                        return _buildWebView(context, ref, supplierState);
                      },
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

  // Builds the main view (controls, table, pagination)
  Widget _buildWebView(
      BuildContext context, WidgetRef ref, SuppliersState supplierState) {
    return Column(
      children: [
        _buildTopControls(context, ref), // Top controls row
        const SizedBox(height: 16),
        Expanded(
            child: _buildDataTable(context, ref, supplierState)), // Data table
        const SizedBox(height: 16),
        _buildPaginationControls(
            context, ref, supplierState), // Pagination controls
      ],
    );
  }

  // Builds the top row with search and add button
  Widget _buildTopControls(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Align controls to the right
      children: [
        SizedBox(
          width: 250, height: 40, // Search Field
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Search Name/Email/Contact...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                hintStyle: const TextStyle(fontSize: 12)),
            onChanged: (searchText) => ref
                .read(suppliersNotifierProvider(isVisibleFilter).notifier)
                .search(searchText), // Connect to notifier search
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          // Add Button
          onPressed: _showAddSupplierModal,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label:
              const Text('Add Supplier', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
        ),
      ],
    );
  }

  // Builds the data table structure
  Widget _buildDataTable(
      BuildContext context, WidgetRef ref, SuppliersState supplierState) {
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
          _buildHeaderRow(context, ref, supplierState), // Sortable header
          const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
          Expanded(
            child: ListView.builder(
              // Use ListView for performance
              itemCount: supplierState.suppliers.length,
              itemBuilder: (BuildContext context, int index) {
                final supplier = supplierState.suppliers[index];
                final rowColor =
                    index % 2 == 0 ? Colors.white : const Color(0xFFF8F8F8);
                return _buildSuppliersRow(context, ref, supplier, rowColor,
                    ValueKey(supplier.supplierID)); // Pass data and key
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builds the header row with sortable columns
  Widget _buildHeaderRow(
      BuildContext context, WidgetRef ref, SuppliersState supplierState) {
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
              context, ref, supplierState, 'ID', 'supplierID', headerTextStyle,
              flex: 1),
          _buildHeaderCell(context, ref, supplierState, 'Name', 'supplierName',
              headerTextStyle,
              flex: 3),
          _buildHeaderCell(context, ref, supplierState, 'Email',
              'supplierEmail', headerTextStyle,
              flex: 3),
          _buildHeaderCell(context, ref, supplierState, 'Contact',
              'contactNumber', headerTextStyle,
              flex: 2),
          _buildHeaderCell(context, ref, supplierState, 'Address', 'address',
              headerTextStyle,
              flex: 4), // Added Address
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
      SuppliersState state,
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
            .read(suppliersNotifierProvider(isVisibleFilter).notifier)
            .sort(sortByColumn), // Connect to notifier sort
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

  // Builds a single data row for a Supplier
  Widget _buildSuppliersRow(BuildContext context, WidgetRef ref,
      SuppliersData supplier, Color rowColor, Key key) {
    const rowTextStyle = TextStyle(fontFamily: 'NunitoSans', fontSize: 13);
    String address =
        supplier.supplierAddress ?? 'N/A'; // Handle nullable address

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: rowColor,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(supplier.supplierID.toString(),
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 3,
              child: Text(supplier.supplierName,
                  style: rowTextStyle, overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 3,
              child: Text(supplier.supplierEmail,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 2,
              child: Text(supplier.contactNumber ?? 'N/A',
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
                      maxLines: 1))), // Added Address
          // Action Buttons
          Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                      message: 'Edit Supplier',
                      child: IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blueAccent, size: 18),
                          onPressed: () => _showEditSupplierModal(supplier),
                          splashRadius: 18,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 5))),
                  const SizedBox(width: 4),
                  Tooltip(
                      message: 'Archive Supplier',
                      child: IconButton(
                          icon: const Icon(Icons.archive,
                              color: Colors.redAccent, size: 18),
                          onPressed: () => _showArchiveSupplierModal(supplier),
                          splashRadius: 18,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 5))),
                ],
              )),
        ],
      ),
    );
  }

  // Builds the pagination controls
  Widget _buildPaginationControls(
      BuildContext context, WidgetRef ref, SuppliersState supplierState) {
    final notifier = ref.read(suppliersNotifierProvider(isVisibleFilter)
        .notifier); // Get correct notifier instance
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
            onPressed: supplierState.currentPage > 1
                ? () => notifier.goToPage(1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
            onPressed: supplierState.currentPage > 1
                ? () => notifier.goToPage(supplierState.currentPage - 1)
                : null,
            splashRadius: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
                'Page ${supplierState.currentPage} of ${supplierState.totalPages}',
                style:
                    const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'))),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
            onPressed: supplierState.currentPage < supplierState.totalPages
                ? () => notifier.goToPage(supplierState.currentPage + 1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
            onPressed: supplierState.currentPage < supplierState.totalPages
                ? () => notifier.goToPage(supplierState.totalPages)
                : null,
            splashRadius: 20),
      ],
    );
  }

  // --- Shimmer Placeholders (Adapted for Supplier columns) ---
  Widget _buildShimmerHeader() {
    const headerPlaceholderColor = Color.fromRGBO(0, 174, 239, 0.5);
    return Container(
      color: headerPlaceholderColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Row(children: [
          // Match header flex values
          Expanded(flex: 1, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8), // Address
          Expanded(
              flex: 2,
              child: Container(height: 16, color: Colors.white)), // Actions
        ]),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        // Match row flex values
        Expanded(flex: 1, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8), // Address
        Expanded(
            flex: 2,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Actions
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

  // Builds the error display widget
  Widget _buildErrorWidget(
      Object error, StackTrace? stackTrace, WidgetRef ref) {
    print('Suppliers Page Error: $error \n $stackTrace');
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent, size: 60),
      const SizedBox(height: 16),
      const Text('Error Loading Suppliers',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700])),
      const SizedBox(height: 20),
      ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          onPressed: () => ref.invalidate(suppliersNotifierProvider(
              isVisibleFilter))), // Invalidate correct provider
    ]));
  }

  // Builds the empty state display widget
  Widget _buildEmptyState(BuildContext context) {
    // Removed ref as Add button calls local method
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.truckFast, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      const Text('No active Suppliers found.',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddSupplierModal(),
          label: const Text('Add New Supplier'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    ]));
  }
}
