//Default Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';

//Backend Imports
//Suppliers Data and Providers
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_providers.dart';

//VRO
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_notifier.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/vendor_return_order_providers.dart';
import 'package:jcsd_flutter/backend/modules/inventory/vendor_return_orders/models/vendor_return_order_data.dart';

//Generic
import 'package:jcsd_flutter/widgets/header.dart';

//Inventory
import 'package:jcsd_flutter/view/inventory/vendor_return/modals/create_vro_modal.dart';
import 'package:jcsd_flutter/view/inventory/vendor_return/modals/view_vro_modal.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/notifiers/purchase_order_notifier.dart';

class VendorReturnOrdersListPage extends ConsumerStatefulWidget {
  const VendorReturnOrdersListPage({super.key});

  @override
  ConsumerState<VendorReturnOrdersListPage> createState() =>
      _VendorReturnOrdersListPageState();
}

class _VendorReturnOrdersListPageState
    extends ConsumerState<VendorReturnOrdersListPage> {
  String _searchTerm = '';
  VendorReturnOrderStatus? _selectedStatusFilter;
  SuppliersData? _selectedSupplierFilter;

  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  Timer? _debounce;

  // For PaginatedDataTable
  int _currentPage = 1;
  final int _rowsPerPage = 10; // Or PaginatedDataTable.defaultRowsPerPage

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFiltersAndSearch();
      // activeSuppliersForDropdownProvider is a FutureProvider, it will be fetched by watch
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _searchTerm = query;
        _currentPage = 1; // Reset to first page on new search
      });
      // Client-side search is handled in _processVROList, no server refetch needed for search ONLY
      // However, if filters change, server refetch occurs via _applyFiltersAndSearch
    });
  }

  void _applyFiltersAndSearch() {
    if (!mounted) return;
    setState(() {
      _currentPage = 1; // Reset to first page on filter change
    });
    ref
        .read(vendorReturnOrderNotifierProvider.notifier)
        .fetchVendorReturnOrders(
          statusFilter: _selectedStatusFilter,
          supplierId: _selectedSupplierFilter?.supplierID,
        );
  }

  List<VendorReturnOrder> _processVROList(
    List<VendorReturnOrder> vros,
    List<SuppliersData> allSuppliers,
    Map<int, PurchaseOrderData> allPOsMap, // Pass map for quick lookup
  ) {
    List<VendorReturnOrder> localFilteredList = List.from(vros);

    if (_searchTerm.isNotEmpty) {
      localFilteredList = localFilteredList.where((vro) {
        final supplier = allSuppliers.firstWhere(
            (s) => s.supplierID == vro.supplierID,
            orElse: () => SuppliersData(
                supplierID: 0,
                supplierName: '',
                supplierEmail: '',
                contactNumber: '',
                supplierAddress: '',
                isActive: false));
        final po = allPOsMap[vro.originalPoID];

        return vro.vroNumber
                .toLowerCase()
                .contains(_searchTerm.toLowerCase()) ||
            (supplier.supplierName?.toLowerCase() ?? '')
                .contains(_searchTerm.toLowerCase()) ||
            (po?.poId.toString().toLowerCase() ?? '').contains(_searchTerm
                .toLowerCase()); // Use poId if poNumber not available
      }).toList();
    }

    localFilteredList.sort((a, b) {
      int compare;
      switch (_sortColumnIndex) {
        case 0:
          compare = a.vroNumber.compareTo(b.vroNumber);
          break;
        case 1:
          compare = a.status.compareTo(b.status);
          break;
        case 2:
          final supplierA = allSuppliers.firstWhere(
              (s) => s.supplierID == a.supplierID,
              orElse: () => SuppliersData(
                  supplierID: 0,
                  supplierName: '',
                  supplierEmail: '',
                  contactNumber: '',
                  supplierAddress: '',
                  isActive: false));
          final supplierB = allSuppliers.firstWhere(
              (s) => s.supplierID == b.supplierID,
              orElse: () => SuppliersData(
                  supplierID: 0,
                  supplierName: '',
                  supplierEmail: '',
                  contactNumber: '',
                  supplierAddress: '',
                  isActive: false));
          compare = (supplierA.supplierName ?? '')
              .compareTo(supplierB.supplierName ?? '');
          break;
        case 3:
          final poA = allPOsMap[a.originalPoID];
          final poB = allPOsMap[b.originalPoID];
          compare = (poA?.poId.toString() ?? '')
              .compareTo(poB?.poId.toString() ?? '');
          break;
        case 4:
          compare = a.returnInitiationDate.compareTo(b.returnInitiationDate);
          break;
        default:
          return 0;
      }
      return _sortAscending ? compare : -compare;
    });
    return localFilteredList;
  }

  @override
  Widget build(BuildContext context) {
    final vroListAsync = ref.watch(vroListProvider);
    final vroNotifier = ref.read(vendorReturnOrderNotifierProvider.notifier);
    final suppliersListAsync = ref.watch(activeSuppliersForDropdownProvider);
    // Fetch all POs to create a lookup map for PO numbers/IDs
    // This assumes purchaseOrderListNotifierProvider gives all POs or can be made to
    final allPOsAsync = ref.watch(purchaseOrderListNotifierProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(title: 'Vendor Return Orders (VRO)'),
            const SizedBox(height: 20),
            _buildFilterAndSearchControls(
                context, vroNotifier, suppliersListAsync),
            const SizedBox(height: 20),
            Expanded(
              child: vroListAsync.when(
                data: (vroList) {
                  return suppliersListAsync.when(
                      data: (allSuppliers) {
                        return allPOsAsync.when(
                          // Nest POs fetch
                          data: (poListState) {
                            final Map<int, PurchaseOrderData> poMap = {
                              for (var po in poListState.purchaseOrders)
                                po.poId: po
                            };
                            final processedList =
                                _processVROList(vroList, allSuppliers, poMap);

                            if (processedList.isEmpty &&
                                _searchTerm.isEmpty &&
                                _selectedStatusFilter == null &&
                                _selectedSupplierFilter == null &&
                                vroList.isNotEmpty) {
                              return const Center(
                                  child: Text(
                                      'No Vendor Return Orders match your criteria.'));
                            }
                            if (vroList.isEmpty &&
                                _searchTerm.isEmpty &&
                                _selectedStatusFilter == null &&
                                _selectedSupplierFilter == null) {
                              return const Center(
                                  child: Text(
                                      'No Vendor Return Orders found. Click "Create VRO" to add one.'));
                            }
                            if (processedList.isEmpty) {
                              return const Center(
                                  child: Text(
                                      'No Vendor Return Orders match your criteria.'));
                            }

                            return _VROPaginatedDataTable(
                              key: ValueKey(_searchTerm +
                                  (_selectedStatusFilter?.toString() ?? '') +
                                  (_selectedSupplierFilter?.toString() ?? '') +
                                  _sortColumnIndex.toString() +
                                  _sortAscending.toString()),
                              vroList: processedList,
                              allSuppliers: allSuppliers,
                              allPOsMap: poMap,
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              onSort: (columnIndex, ascending) {
                                if (!mounted) return;
                                setState(() {
                                  _sortColumnIndex = columnIndex;
                                  _sortAscending = ascending;
                                });
                              },
                              rowsPerPage: _rowsPerPage,
                              onPageChanged: (pageIndex) {
                                // PaginatedDataTable gives page index (0-based)
                                // Our _currentPage is 1-based for display/logic
                                // This example doesn't use server-side pagination for the VRO list itself,
                                // but if it did, this is where you'd call a method like `vroNotifier.goToPage(pageIndex + 1);`
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Center(
                              child:
                                  Text('Error loading POs: ${e.toString()}')),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(
                          child: Text(
                              'Error loading Suppliers: ${e.toString()}')));
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error loading VROs: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterAndSearchControls(
      BuildContext context, VendorReturnOrderNotifier vroNotifier) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Search VRO #, Supplier, PO #...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onChanged: (value) {
                  // Basic debouncing can be added here if client-side filtering is heavy
                  setState(() {
                    _searchTerm = value;
                    // If using client-side filtering only, no need to call fetch here
                    // If backend search: _onSearchChanged(value);
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 200, // Adjust width as needed
              child: DropdownButtonFormField<VendorReturnOrderStatus?>(
                value: _selectedStatusFilter,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                items: [
                  const DropdownMenuItem<VendorReturnOrderStatus?>(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...VendorReturnOrderStatus.values.map((status) {
                    return DropdownMenuItem<VendorReturnOrderStatus>(
                      value: status,
                      child: Text(status.toDbValue), // Or status.name
                    );
                  }).toList(),
                ],
                onChanged: (VendorReturnOrderStatus? newValue) {
                  setState(() {
                    _selectedStatusFilter = newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            // TODO: Add Dropdown for Suppliers
            // TODO: Add Dropdown for Original POs (might be complex to populate)
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create VRO'),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const CreateVROModal(),
                ).then(
                    (_) => _applyFilters()); // Refresh list after modal closes
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VRODataTableSource extends DataTableSource {
  final List<VendorReturnOrder> _vroList;
  final BuildContext _context;
  final WidgetRef _ref;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final List<SuppliersData> _allSuppliers;
  final Map<int, PurchaseOrderData> _allPOsMap;

  _VRODataTableSource(this._vroList, this._allSuppliers, this._allPOsMap,
      this._context, this._ref);

  @override
  DataRow? getRow(int index) {
    if (index >= _vroList.length) return null;
    final vro = _vroList[index];

    final supplier = _allSuppliers.firstWhere(
        (s) => s.supplierID == vro.supplierID,
        orElse: () => SuppliersData(
            supplierID: 0,
            supplierName: 'N/A',
            supplierEmail: '',
            contactNumber: '',
            supplierAddress: '',
            isActive: false));
    final po = _allPOsMap[vro.originalPoID];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(vro.vroNumber)),
        DataCell(Text(vro.status.toDbValue)),
        DataCell(Text(supplier.supplierName ?? 'N/A')),
        DataCell(Text(po?.poId.toString() ?? 'N/A')), // Using poId as display
        DataCell(Text(_dateFormat.format(vro.returnInitiationDate))),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blueGrey),
            tooltip: 'View Details',
            onPressed: () {
              _ref
                  .read(vendorReturnOrderNotifierProvider.notifier)
                  .getVROById(vro.vroID);
              showDialog(
                context: _context,
                barrierDismissible: false,
                builder: (context) => ViewVROModal(vroId: vro.vroID),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _vroList.length;
  @override
  int get selectedRowCount => 0;
}

class _VROPaginatedDataTable extends StatelessWidget {
  final List<VendorReturnOrder> vroList;
  final List<SuppliersData> allSuppliers;
  final Map<int, PurchaseOrderData> allPOsMap;
  final int sortColumnIndex;
  final bool sortAscending;
  final Function(int, bool) onSort;
  final int rowsPerPage;
  final Function(int) onPageChanged;

  const _VROPaginatedDataTable({
    super.key,
    required this.vroList,
    required this.allSuppliers,
    required this.allPOsMap,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.rowsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final columns = [
        DataColumn(
            label: const Text('VRO #'), onSort: (i, asc) => onSort(i, asc)),
        DataColumn(
            label: const Text('Status'), onSort: (i, asc) => onSort(i, asc)),
        DataColumn(
            label: const Text('Supplier'), onSort: (i, asc) => onSort(i, asc)),
        DataColumn(
            label: const Text('Original PO #'),
            onSort: (i, asc) => onSort(i, asc)),
        DataColumn(
            label: const Text('Initiated'), onSort: (i, asc) => onSort(i, asc)),
        const DataColumn(label: Text('Actions')),
      ];

      return PaginatedDataTable(
        columns: columns,
        source:
            _VRODataTableSource(vroList, allSuppliers, allPOsMap, context, ref),
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        rowsPerPage: rowsPerPage,
        // onPageChanged: onPageChanged, // PaginatedDataTable handles its own paging, this is for server-side
        showCheckboxColumn: false,
        headingRowHeight: 40,
        dataRowMaxHeight: 45,
        columnSpacing: 20,
      );
    });
  }
}
