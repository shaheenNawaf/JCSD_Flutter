import 'package:flutter/foundation.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/services/purchase_order_service.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_data.dart';

@immutable
class PurchaseOrderListState {
  final List<PurchaseOrderData> purchaseOrders;
  final String searchText;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final String sortBy;
  final bool ascending;
  final PurchaseOrderStatus? statusFilter;
  final int? supplierFilter; // Supplier ID Filter

  const PurchaseOrderListState({
    this.purchaseOrders = const [],
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = defaultPOItemsPerPage,
    this.sortBy = 'orderDate',
    this.ascending = false,
    this.statusFilter,
    this.supplierFilter,
  });

  PurchaseOrderListState copyWith({
    List<PurchaseOrderData>? purchaseOrders,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? sortBy,
    bool? ascending,
    ValueGetter<PurchaseOrderStatus?>? statusFilter,
    ValueGetter<int?>? supplierFilter,
  }) {
    return PurchaseOrderListState(
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      supplierFilter:
          supplierFilter != null ? supplierFilter() : this.supplierFilter,
    );
  }
}
