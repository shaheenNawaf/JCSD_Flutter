// ignore_for_file: library_private_types_in_public_api, avoid_print

//Default Imports
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//UI Imports
import 'package:shimmer/shimmer.dart';
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/accounts/role_state.dart'; // For role-based actions
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/purchase_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart'; // For activeSuppliersForDropdownProvider

// Purchase Orders Modal
import 'package:jcsd_flutter/view/inventory/purchase_orders/modals/create_po_modal.dart';
import 'package:jcsd_flutter/view/inventory/purchase_orders/modals/view_approve_po_modal.dart';
import 'package:jcsd_flutter/view/inventory/purchase_orders/modals/receive_po_items_modal.dart';

class PurchaseOrderPage extends ConsumerWidget {
  const PurchaseOrderPage({super.key});

  final String _activeSubItem =
      '/orderList'; // Or a new route like '/purchaseOrders'
  // Update in sidebar.dart as well

  void _showCreatePurchaseOrderModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CreatePurchaseOrderModal(),
    ).then((success) {
      if (success == true) {
        ref.read(purchaseOrderListNotifierProvider.notifier).refresh();
      }
    });
  }

  void _showViewApprovePurchaseOrderModal(
      BuildContext context, WidgetRef ref, PurchaseOrderData po) {
    showDialog(
      context: context,
      barrierDismissible: false, // Admin should explicitly close or act
      builder: (_) => ViewApprovePurchaseOrderModal(purchaseOrder: po),
    ).then((updated) {
      // Modal might return true if PO was updated
      if (updated == true) {
        ref.read(purchaseOrderListNotifierProvider.notifier).refresh();
      }
    });
  }

  void _showReceiveItemsModal(
      BuildContext context, WidgetRef ref, PurchaseOrderData po) {
    showDialog(
      context: context,
      barrierDismissible: false, // Usually, you complete or cancel receiving
      builder: (_) => ReceivePurchaseOrderItemsModal(purchaseOrder: po),
    ).then((updated) {
      if (updated == true) {
        ref.read(purchaseOrderListNotifierProvider.notifier).refresh();
        // Potentially refresh stock counts for involved product definitions
        // po.items?.forEach((item) => ref.invalidate(serializedItemNotifierProvider(item.prodDefID)));
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(purchaseOrderListNotifierProvider);
    final userRole = ref.watch(userRoleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Purchase Orders'), // Update title
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: asyncValue.when(
                      loading: () => _buildLoadingIndicator(),
                      error: (error, stackTrace) =>
                          _buildErrorWidget(error, stackTrace, ref),
                      data: (poState) {
                        if (poState.purchaseOrders.isEmpty &&
                            poState.searchText.isEmpty &&
                            poState.statusFilter == null &&
                            poState.supplierFilter == null) {
                          return _buildEmptyState(
                              context, ref, userRole.asData?.value);
                        }
                        return _buildWebView(
                            context, ref, poState, userRole.asData?.value);
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

  Widget _buildWebView(BuildContext context, WidgetRef ref,
      PurchaseOrderListState poState, String? currentUserRole) {
    return Column(
      children: [
        _buildTopControls(context, ref, poState, currentUserRole),
        const SizedBox(height: 16),
        Expanded(
            child: _buildDataTable(context, ref, poState, currentUserRole)),
        const SizedBox(height: 16),
        if (poState.totalPages > 1)
          _buildPaginationControls(context, ref, poState),
      ],
    );
  }

  Widget _buildTopControls(BuildContext context, WidgetRef ref,
      PurchaseOrderListState poState, String? currentUserRole) {
    final activeSuppliersAsync = ref.watch(activeSuppliersForDropdownProvider);

    return Row(
      children: [
        // Status Filter Dropdown
        SizedBox(
          width: 200,
          height: 40,
          child: DropdownButtonFormField<PurchaseOrderStatus?>(
            value: poState.statusFilter,
            hint: const Text('Filter by Status...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              suffixIcon: poState.statusFilter != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      tooltip: "Clear Status Filter",
                      onPressed: () => ref
                          .read(purchaseOrderListNotifierProvider.notifier)
                          .applyFilters(clearStatus: true),
                    )
                  : null,
            ),
            isExpanded: true,
            items: [
              const DropdownMenuItem<PurchaseOrderStatus?>(
                value: null,
                child: Text('All Statuses',
                    style:
                        TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              ),
              ...PurchaseOrderStatus.values
                  .where((s) => s != PurchaseOrderStatus.Unknown)
                  .map((status) => DropdownMenuItem<PurchaseOrderStatus?>(
                        value: status,
                        child: Text(
                            status.dbValue
                                .replaceAllMapped(RegExp(r'[A-Z]'),
                                    (match) => ' ${match.group(0)}')
                                .trim(),
                            style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ],
            onChanged: (value) {
              ref
                  .read(purchaseOrderListNotifierProvider.notifier)
                  .applyFilters(status: value, clearStatus: value == null);
            },
          ),
        ),
        const SizedBox(width: 10),
        // Supplier Filter Dropdown
        SizedBox(
          width: 200,
          height: 40,
          child: activeSuppliersAsync.when(
              data: (suppliers) => DropdownButtonFormField<int?>(
                    value: poState.supplierFilter,
                    hint: const Text('Filter by Supplier...',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 10),
                      suffixIcon: poState.supplierFilter != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              tooltip: "Clear Supplier Filter",
                              onPressed: () => ref
                                  .read(purchaseOrderListNotifierProvider
                                      .notifier)
                                  .applyFilters(clearSupplier: true),
                            )
                          : null,
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Suppliers',
                            style: TextStyle(
                                fontSize: 12, fontStyle: FontStyle.italic)),
                      ),
                      ...suppliers.map((supplier) => DropdownMenuItem<int?>(
                            value: supplier.supplierID,
                            child: Text(supplier.supplierName,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (value) {
                      ref
                          .read(purchaseOrderListNotifierProvider.notifier)
                          .applyFilters(
                              supplierId: value, clearSupplier: value == null);
                    },
                  ),
              loading: () => const SizedBox(
                  height: 40,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2))),
              error: (e, s) => const SizedBox(
                  height: 40,
                  child: Center(
                      child: Text("Err",
                          style: TextStyle(fontSize: 10, color: Colors.red))))),
        ),
        const Spacer(),
        SizedBox(
          width: 250,
          height: 40,
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Search PO ID/Note/Supplier...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFABABAB),
                    fontFamily: 'NunitoSans')),
            onChanged: (searchText) => ref
                .read(purchaseOrderListNotifierProvider.notifier)
                .search(searchText),
          ),
        ),
        const SizedBox(width: 16),
        if (currentUserRole == 'admin' || currentUserRole == 'employee')
          ElevatedButton.icon(
            onPressed: () => _showCreatePurchaseOrderModal(context, ref),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label:
                const Text('Create PO', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(0, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
          ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref,
      PurchaseOrderListState poState, String? currentUserRole) {
    final Map<String, int> columnFlex = {
      'ID': 1,
      'Supplier': 3,
      'Order Date': 2,
      'Est. Delivery': 2,
      'Status': 2,
      'Total Cost': 2,
      'Actions': 3,
    };

    final AsyncValue<Map<int, String>> supplierNamesMapAsync =
        ref.watch(supplierNameMapProvider);
    return supplierNamesMapAsync.when(
      data: (supplierMap) {
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
              _buildHeaderRow(context, ref, poState, columnFlex),
              const Divider(
                  height: 1, color: Color.fromARGB(255, 224, 224, 224)),
              Expanded(
                child: poState.purchaseOrders.isEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          poState.searchText.isNotEmpty ||
                                  poState.statusFilter != null ||
                                  poState.supplierFilter != null
                              ? 'No Purchase Orders match your current filters.'
                              : 'No purchase orders found.',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ))
                    : ListView.builder(
                        itemCount: poState.purchaseOrders.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = poState.purchaseOrders[index];
                          final rowColor = index % 2 == 0
                              ? Colors.white
                              : const Color(0xFFF8F8F8);
                          return _buildItemRow(
                              context,
                              ref,
                              item,
                              rowColor,
                              ValueKey(item.poId),
                              currentUserRole,
                              columnFlex,
                              supplierMap);
                        },
                      ),
              ),
            ],
          ),
        );
      },
      error: (err, sty) =>
          Center(child: Text("Error loading supplier names: $err")),
      loading: () => _buildLoadingIndicator(),
    );
  }

  Widget _buildHeaderRow(BuildContext context, WidgetRef ref,
      PurchaseOrderListState poState, Map<String, int> columnFlex) {
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
              context, ref, poState, 'PO ID', 'po_id', headerTextStyle,
              flex: columnFlex['ID']!),
          _buildHeaderCell(
              context, ref, poState, 'Supplier', 'supplierID', headerTextStyle,
              flex:
                  columnFlex['Supplier']!), // Sort by supplierID, displays name
          _buildHeaderCell(
              context, ref, poState, 'Order Date', 'orderDate', headerTextStyle,
              flex: columnFlex['Order Date']!),
          _buildHeaderCell(context, ref, poState, 'Est. Delivery',
              'expectedDeliveryDate', headerTextStyle,
              flex: columnFlex['Est. Delivery']!),
          _buildHeaderCell(
              context, ref, poState, 'Status', 'status', headerTextStyle,
              flex: columnFlex['Status']!),
          _buildHeaderCell(context, ref, poState, 'Total Cost',
              'totalEstimatedCost', headerTextStyle,
              flex: columnFlex['Total Cost']!),
          Expanded(
              flex: columnFlex['Actions']!,
              child: const Text('Actions',
                  style: headerTextStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
      BuildContext context,
      WidgetRef ref,
      PurchaseOrderListState state,
      String columnTitle,
      String sortByColumn,
      TextStyle textStyle,
      {required int flex}) {
    bool isCurrentlySorted = state.sortBy == sortByColumn;
    Icon? sortIcon = isCurrentlySorted
        ? Icon(state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.white, size: 18)
        : null;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => ref
            .read(purchaseOrderListNotifierProvider.notifier)
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

  Widget _buildItemRow(
    BuildContext context,
    WidgetRef ref,
    PurchaseOrderData item,
    Color rowColor,
    Key key,
    String? currentUserRole,
    Map<String, int> columnFlex,
    Map<int, String> supplierMap,
  ) {
    //Receiving the suplier map
    String supplierNameDisplay =
        supplierMap[item.supplierID] ?? 'ID: ${item.supplierID}';

    String totalCost = item.totalEstimatedCost != null
        ? 'P ${item.totalEstimatedCost!.toStringAsFixed(2)}'
        : 'N/A';
    String orderDate = DateFormat('MM/dd/yyyy').format(item.orderDate);
    String expectedDate = item.expectedDeliveryDate != null
        ? DateFormat('MM/dd/yyyy').format(item.expectedDeliveryDate!)
        : 'N/A';
    const rowTextStyle = TextStyle(fontFamily: 'NunitoSans', fontSize: 13);

    // Determine actions based on PO status and user role
    List<Widget> actions = [];
    if (currentUserRole == 'admin') {
      if (item.status == PurchaseOrderStatus.PendingApproval ||
          item.status == PurchaseOrderStatus.Revised) {
        actions.add(_actionButton(context, 'View/Approve', Colors.orangeAccent,
            () => _showViewApprovePurchaseOrderModal(context, ref, item)));
      }
    }
    if (currentUserRole == 'admin' || currentUserRole == 'employee') {
      if (item.status == PurchaseOrderStatus.Approved ||
          item.status == PurchaseOrderStatus.PartiallyReceived) {
        actions.add(_actionButton(context, 'Receive Items', Colors.blueAccent,
            () => _showReceiveItemsModal(context, ref, item)));
      }
      if (item.status == PurchaseOrderStatus.Draft ||
          item.status == PurchaseOrderStatus.PendingApproval ||
          item.status == PurchaseOrderStatus.Revised) {
        // Placeholder for Edit button if POs are editable in these states by employees/admin
        // actions.add(_actionButton(context, 'Edit', Colors.blueGrey, () => _showEditPOModal(context, ref, item)));
      }
    }
    // All roles can likely view details if it's not pending their action
    if (actions.isEmpty &&
        (item.status == PurchaseOrderStatus.Approved ||
            item.status == PurchaseOrderStatus.PartiallyReceived ||
            item.status == PurchaseOrderStatus.Received ||
            item.status == PurchaseOrderStatus.Cancelled)) {
      actions.add(_actionButton(context, 'View Details', Colors.grey,
          () => _showViewApprovePurchaseOrderModal(context, ref, item)));
    }

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: rowColor,
      child: Row(
        children: [
          Expanded(
              flex: columnFlex['ID']!,
              child: Text(item.poId.toString(),
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: columnFlex['Supplier']!,
              child: Text(supplierNameDisplay,
                  style: rowTextStyle,
                  overflow: TextOverflow
                      .ellipsis)), // Assuming supplierName is populated by join
          Expanded(
              flex: columnFlex['Order Date']!,
              child: Text(orderDate,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: columnFlex['Est. Delivery']!,
              child: Text(expectedDate,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: columnFlex['Status']!, child: _statusChip(item.status)),
          Expanded(
              flex: columnFlex['Total Cost']!,
              child: Text(totalCost,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: columnFlex['Actions']!,
              child: actions.isEmpty
                  ? const Center(child: Text("-", style: rowTextStyle))
                  : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: actions)),
        ],
      ),
    );
  }

  Widget _actionButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            textStyle: const TextStyle(fontSize: 11, fontFamily: 'NunitoSans')),
        child: Text(label));
  }

  Widget _statusChip(PurchaseOrderStatus status) {
    Color chipColor;
    String chipText = status.dbValue
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim();

    switch (status) {
      case PurchaseOrderStatus.Draft:
        chipColor = Colors.blueGrey.shade300;
        break;
      case PurchaseOrderStatus.PendingApproval:
        chipColor = Colors.orange.shade600;
        break;
      case PurchaseOrderStatus.Approved:
        chipColor = Colors.blue.shade600;
        break;
      case PurchaseOrderStatus.Revised:
        chipColor = Colors.purple.shade400;
        break;
      case PurchaseOrderStatus.Cancelled:
        chipColor = Colors.red.shade600;
        break;
      case PurchaseOrderStatus.PartiallyReceived:
        chipColor = Colors.teal.shade400;
        break;
      case PurchaseOrderStatus.Received:
        chipColor = Colors.green.shade600;
        break;
      default:
        chipColor = Colors.grey.shade500;
        chipText = "Unknown";
    }
    return Chip(
      label: Text(chipText,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, WidgetRef ref, PurchaseOrderListState poState) {
    final notifier = ref.read(purchaseOrderListNotifierProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
            onPressed:
                poState.currentPage > 1 ? () => notifier.goToPage(1) : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
            onPressed: poState.currentPage > 1
                ? () => notifier.goToPage(poState.currentPage - 1)
                : null,
            splashRadius: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Page ${poState.currentPage} of ${poState.totalPages}',
                style:
                    const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'))),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
            onPressed: poState.currentPage < poState.totalPages
                ? () => notifier.goToPage(poState.currentPage + 1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
            onPressed: poState.currentPage < poState.totalPages
                ? () => notifier.goToPage(poState.totalPages)
                : null,
            splashRadius: 20),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    // Using similar shimmer structure from InventoryPage
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
            _buildShimmerHeader(), // Adapt for PO columns
            const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
            Expanded(
                child: ListView(
                    children: List.generate(
                        8, (_) => _buildShimmerRow()))), // Adapt for PO columns
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
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Container(
              height: 40,
              width: 200,
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
              width: 100,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
        ]),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    const headerPlaceholderColor = Color.fromRGBO(0, 174, 239, 0.5);
    // Adapt flex values to match PO table
    final Map<String, int> columnFlex = {
      'ID': 1,
      'Supplier': 3,
      'Order Date': 2,
      'Est. Delivery': 2,
      'Status': 2,
      'Total Cost': 2,
      'Actions': 3,
    };
    return Container(
      color: headerPlaceholderColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Row(children: [
          Expanded(
              flex: columnFlex['ID']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Supplier']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Order Date']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Est. Delivery']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Status']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Total Cost']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Actions']!,
              child: Container(height: 16, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildShimmerRow() {
    // Adapt flex values
    final Map<String, int> columnFlex = {
      'ID': 1,
      'Supplier': 3,
      'Order Date': 2,
      'Est. Delivery': 2,
      'Status': 2,
      'Total Cost': 2,
      'Actions': 3,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        Expanded(
            flex: columnFlex['ID']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Supplier']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Order Date']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Est. Delivery']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Status']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Total Cost']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Actions']!,
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
    print('Purchase Order Page Error: $error \n $stackTrace');
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent, size: 60),
      const SizedBox(height: 16),
      const Text('Error Loading Purchase Orders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700])),
      const SizedBox(height: 20),
      ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          onPressed: () => ref.invalidate(purchaseOrderListNotifierProvider)),
    ]));
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, String? currentUserRole) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.fileCirclePlus, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      const Text('No Purchase Orders found.',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
      const SizedBox(height: 12),
      if (currentUserRole == 'admin' || currentUserRole == 'employee')
        ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePurchaseOrderModal(context, ref),
            label: const Text('Create New Purchase Order'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12))),
    ]));
  }
}
