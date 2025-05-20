// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_state.dart';
import 'package:jcsd_flutter/view/inventory/return_orders/modals/view_return_order_detail_modal.dart'; // Import the detail modal
import 'package:jcsd_flutter/widgets/header.dart';
import 'package:jcsd_flutter/widgets/sidebar.dart';
import 'package:shimmer/shimmer.dart';

class ReturnOrderListPage extends ConsumerWidget {
  const ReturnOrderListPage({super.key});

  final String _activeSubItem = '/returnOrders';
  void _showViewReturnOrderDetailModal(
      BuildContext context, WidgetRef ref, ReturnOrderData ro) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing detail modal
      builder: (_) => ViewReturnOrderDetailModal(roId: ro.returnOrderID),
    ).then((actionTaken) {
      if (actionTaken == true) {
        // If modal indicates an update happened
        ref.read(returnOrderListNotifierProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(returnOrderListNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        children: [
          Sidebar(activePage: _activeSubItem),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Return Orders',
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: Color(0xFF00AEEF)),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/inventory'); // Fallback to inventory main
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: asyncValue.when(
                      data: (roState) {
                        if (roState.errorMessage != null &&
                            roState.returnOrders.isEmpty) {
                          return _buildErrorWidget(
                              roState.errorMessage!, null, ref);
                        }
                        if (roState.returnOrders.isEmpty &&
                            roState.searchText.isEmpty &&
                            roState.statusFilter == null &&
                            roState.supplierFilter == null &&
                            roState.purchaseOrderFilter == null &&
                            !roState.isLoading) {
                          return _buildEmptyState(context, ref);
                        }
                        return _buildWebView(context, ref, roState);
                      },
                      loading: () => _buildLoadingIndicator(),
                      error: (error, stackTrace) =>
                          _buildErrorWidget(error, stackTrace, ref),
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

  Widget _buildWebView(
      BuildContext context, WidgetRef ref, ReturnOrderListState roState) {
    return Column(
      children: [
        _buildTopControls(context, ref, roState),
        const SizedBox(height: 16),
        if (roState.isLoading && roState.returnOrders.isEmpty)
          Expanded(child: _buildDataTableShimmer())
        else if (roState.errorMessage != null && roState.returnOrders.isEmpty)
          Expanded(
              child: Center(
                  child: Text("Error: ${roState.errorMessage}",
                      style: const TextStyle(color: Colors.red))))
        else
          Expanded(child: _buildDataTable(context, ref, roState)),
        const SizedBox(height: 16),
        if (roState.totalPages > 1 && !roState.isLoading)
          _buildPaginationControls(context, ref, roState),
      ],
    );
  }

  Widget _buildTopControls(
      BuildContext context, WidgetRef ref, ReturnOrderListState roState) {
    final activeSuppliersAsync = ref.watch(activeSuppliersForDropdownProvider);
    final notifier = ref.read(returnOrderListNotifierProvider.notifier);

    return Row(
      children: [
        SizedBox(
          width: 180,
          height: 40,
          child: DropdownButtonFormField<ReturnOrderStatus?>(
            value: roState.statusFilter,
            hint: const Text('Filter Status...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              isDense: true,
              suffixIcon: roState.statusFilter != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => notifier.applyFilters(clearStatus: true))
                  : null,
            ),
            isExpanded: true,
            items: [
              const DropdownMenuItem<ReturnOrderStatus?>(
                  value: null,
                  child: Text('All Statuses',
                      style: TextStyle(
                          fontSize: 12, fontStyle: FontStyle.italic))),
              ...ReturnOrderStatus.values
                  .where((s) => s != ReturnOrderStatus.Unknown)
                  .map((status) => DropdownMenuItem<ReturnOrderStatus?>(
                        value: status,
                        child: Text(status.name,
                            style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            ],
            onChanged: (value) => notifier.applyFilters(
                status: value, clearStatus: value == null),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          height: 40,
          child: activeSuppliersAsync.when(
            data: (suppliers) => DropdownButtonFormField<int?>(
              value: roState.supplierFilter,
              hint: const Text('Filter Supplier...',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                isDense: true,
                suffixIcon: roState.supplierFilter != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () =>
                            notifier.applyFilters(clearSupplier: true))
                    : null,
              ),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Suppliers',
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic))),
                ...suppliers.map((s) => DropdownMenuItem<int?>(
                    value: s.supplierID,
                    child: Text(s.supplierName,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (value) => notifier.applyFilters(
                  supplierId: value, clearSupplier: value == null),
            ),
            loading: () => const SizedBox(
                height: 20,
                width: 20,
                child:
                    Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (e, s) => const Text("Err Sup",
                style: TextStyle(fontSize: 10, color: Colors.red)),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          height: 40,
          child: TextFormField(
            // PO ID Filter
            decoration: InputDecoration(
              hintText: 'PO ID...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              isDense: true,
              suffixIcon: roState.purchaseOrderFilter != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () =>
                          notifier.applyFilters(clearPurchaseOrder: true))
                  : null,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // Debounce or submit on enter
              final poId = int.tryParse(value);
              notifier.applyFilters(
                  purchaseOrderId: poId, clearPurchaseOrder: value.isEmpty);
            },
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 250,
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search RO ID, Notes...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFABABAB),
                  fontFamily: 'NunitoSans'),
            ),
            onChanged: (searchText) => notifier.search(searchText),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(
      BuildContext context, WidgetRef ref, ReturnOrderListState roState) {
    final supplierMapAsync = ref.watch(supplierNameMapProvider);

    return supplierMapAsync.when(
      data: (supplierMap) {
        if (roState.isLoading && roState.returnOrders.isEmpty) {
          return _buildDataTableShimmer();
        }
        if (roState.returnOrders.isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              roState.searchText.isNotEmpty ||
                      roState.statusFilter != null ||
                      roState.supplierFilter != null ||
                      roState.purchaseOrderFilter != null
                  ? 'No Return Orders match your current filters.'
                  : 'No return orders found to display.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ));
        }
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
              _buildHeaderRow(context, ref, roState),
              const Divider(
                  height: 1, color: Color.fromARGB(255, 224, 224, 224)),
              Expanded(
                child: ListView.builder(
                  itemCount: roState.returnOrders.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = roState.returnOrders[index];
                    final rowColor =
                        index % 2 == 0 ? Colors.white : const Color(0xFFF8F8F8);
                    return _buildItemRow(context, ref, item, rowColor,
                        supplierMap, ValueKey(item.returnOrderID));
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildDataTableShimmer(),
      error: (e, s) => Center(
          child: Text("Error loading supplier data for table: $e",
              style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _buildHeaderRow(
      BuildContext context, WidgetRef ref, ReturnOrderListState roState) {
    final notifier = ref.read(returnOrderListNotifierProvider.notifier);
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
              context, ref, roState, 'RO ID', 'returnOrderID', headerTextStyle,
              flex: 1, notifier: notifier),
          _buildHeaderCell(context, ref, roState, 'Orig. PO ID',
              'purchaseOrderID', headerTextStyle,
              flex: 1, notifier: notifier),
          _buildHeaderCell(
              context, ref, roState, 'Supplier', 'supplierID', headerTextStyle,
              flex: 3, notifier: notifier),
          _buildHeaderCell(context, ref, roState, 'Return Date', 'returnDate',
              headerTextStyle,
              flex: 2, notifier: notifier),
          _buildHeaderCell(
              context, ref, roState, 'Status', 'status', headerTextStyle,
              flex: 2, notifier: notifier),
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
      ReturnOrderListState state,
      String columnTitle,
      String sortByColumn,
      TextStyle textStyle,
      {required int flex,
      required ReturnOrderListNotifier notifier}) {
    bool isCurrentlySorted = state.sortBy == sortByColumn;
    Icon? sortIcon = isCurrentlySorted
        ? Icon(state.ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: Colors.white, size: 18)
        : null;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => notifier.sort(sortByColumn),
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
      ReturnOrderData item,
      Color rowColor,
      Map<int, String> supplierMap,
      Key key) {
    String supplierNameDisplay =
        supplierMap[item.supplierID] ?? 'ID: ${item.supplierID}';
    String returnDate =
        DateFormat('MM/dd/yyyy').format(item.returnDate.toLocal());
    const rowTextStyle = TextStyle(fontFamily: 'NunitoSans', fontSize: 13);

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: rowColor,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(item.returnOrderID.toString(),
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 1,
              child: Text(item.purchaseOrderID.toString(),
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 3,
              child: Text(supplierNameDisplay,
                  style: rowTextStyle, overflow: TextOverflow.ellipsis)),
          Expanded(
              flex: 2,
              child: Text(returnDate,
                  style: rowTextStyle,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: _statusChip(item.status)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _showViewReturnOrderDetailModal(context, ref, item),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 11)),
                  child: const Text('View/Manage',
                      style: TextStyle(
                          fontFamily: 'NunitoSans', color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(ReturnOrderStatus status) {
    Color chipColor;
    String chipText = status.name;
    Color textColor = Colors.white;

    switch (status) {
      case ReturnOrderStatus.PendingApproval:
        chipColor = Colors.orange.shade600;
        break;
      case ReturnOrderStatus.Approved:
        chipColor = Colors.blue.shade600;
        break;
      case ReturnOrderStatus.ItemsSentToSupplier:
        chipColor = Colors.cyan.shade700;
        break;
      case ReturnOrderStatus.AwaitingReplacement:
        chipColor = Colors.deepPurple.shade400;
        break;
      case ReturnOrderStatus.ReplacementReceived:
        chipColor = Colors.teal.shade400;
        break;
      case ReturnOrderStatus.Completed:
        chipColor = Colors.green.shade600;
        break;
      case ReturnOrderStatus.Cancelled:
      case ReturnOrderStatus.Rejected:
        chipColor = Colors.red.shade600;
        break;
      default:
        chipColor = Colors.grey.shade500;
        textColor = Colors.black87;
    }
    return Chip(
      label: Text(chipText,
          style: TextStyle(
              color: textColor, fontSize: 10, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, WidgetRef ref, ReturnOrderListState roState) {
    final notifier = ref.read(returnOrderListNotifierProvider.notifier);
    if (roState.totalPages <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
            onPressed:
                roState.currentPage > 1 ? () => notifier.goToPage(1) : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
            onPressed: roState.currentPage > 1
                ? () => notifier.goToPage(roState.currentPage - 1)
                : null,
            splashRadius: 20),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Page ${roState.currentPage} of ${roState.totalPages}',
                style:
                    const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'))),
        IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
            onPressed: roState.currentPage < roState.totalPages
                ? () => notifier.goToPage(roState.currentPage + 1)
                : null,
            splashRadius: 20),
        IconButton(
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
            onPressed: roState.currentPage < roState.totalPages
                ? () => notifier.goToPage(roState.totalPages)
                : null,
            splashRadius: 20),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(children: [
        _buildTopControlsPlaceholder(),
        const SizedBox(height: 16),
        Expanded(child: _buildDataTableShimmer()),
        const SizedBox(height: 16),
        _buildPaginationPlaceholder(),
      ]),
    );
  }

  Widget _buildDataTableShimmer() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          _buildShimmerHeader(),
          const Divider(height: 1, color: Color.fromARGB(255, 224, 224, 224)),
          Expanded(
              child: ListView(
                  children: List.generate(8, (_) => _buildShimmerRow()))),
        ]));
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
              width: 180,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 10),
          Container(
              height: 40,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8))),
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

  Widget _buildShimmerHeader() {
    const headerPlaceholderColor = Color.fromRGBO(0, 174, 239, 0.5);
    final Map<String, int> columnFlex = {
      'RO ID': 1,
      'Orig. PO ID': 1,
      'Supplier': 3,
      'Return Date': 2,
      'Status': 2,
      'Actions': 2
    };
    return Container(
      color: headerPlaceholderColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Row(children: [
          Expanded(
              flex: columnFlex['RO ID']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Orig. PO ID']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Supplier']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Return Date']!,
              child: Container(height: 16, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
              flex: columnFlex['Status']!,
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
    final Map<String, int> columnFlex = {
      'RO ID': 1,
      'Orig. PO ID': 1,
      'Supplier': 3,
      'Return Date': 2,
      'Status': 2,
      'Actions': 2
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(children: [
        Expanded(
            flex: columnFlex['RO ID']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Orig. PO ID']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Supplier']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Return Date']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Status']!,
            child: Container(height: 14.0, color: Colors.white)),
        const SizedBox(width: 8),
        Expanded(
            flex: columnFlex['Actions']!,
            child: Container(height: 14.0, color: Colors.white)),
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
    print('Return Order List Page Error: $error \n $stackTrace');
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.circleExclamation,
          color: Colors.redAccent, size: 60),
      const SizedBox(height: 16),
      const Text('Error Loading Return Orders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700])),
      const SizedBox(height: 20),
      ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Retry"),
          onPressed: () => ref.invalidate(returnOrderListNotifierProvider)),
    ]));
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(FontAwesomeIcons.retweet, size: 80, color: Colors.grey),
      const SizedBox(height: 16),
      const Text('No Return Orders found.',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
      const SizedBox(height: 12),
      Text("Return Orders are initiated from a Purchase Order's details.",
          style: TextStyle(fontSize: 14, color: Colors.grey[600])),
    ]));
  }
}
