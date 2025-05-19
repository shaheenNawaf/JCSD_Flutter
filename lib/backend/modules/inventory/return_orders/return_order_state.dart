// lib/backend/modules/inventory/return_orders/return_order_state.dart
import 'package:flutter/foundation.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_service.dart'; // For defaultItemsPerPage

@immutable
class ReturnOrderListState {
  final List<ReturnOrderData> returnOrders;
  final String searchText;
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final String sortBy;
  final bool ascending;
  final ReturnOrderStatus? statusFilter;
  final int? supplierFilter;
  final int? purchaseOrderFilter; // New filter for PO ID
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  const ReturnOrderListState({
    this.returnOrders = const [],
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = defaultReturnOrderItemsPerPage, // from service
    this.sortBy = 'returnDate', // Default sort
    this.ascending = false, // Default to newest first
    this.statusFilter,
    this.supplierFilter,
    this.purchaseOrderFilter,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  ReturnOrderListState copyWith({
    List<ReturnOrderData>? returnOrders,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? sortBy,
    bool? ascending,
    ValueGetter<ReturnOrderStatus?>? statusFilter,
    ValueGetter<int?>? supplierFilter,
    ValueGetter<int?>? purchaseOrderFilter,
    bool? isLoading,
    bool? isLoadingMore,
    ValueGetter<String?>? errorMessage,
  }) {
    return ReturnOrderListState(
      returnOrders: returnOrders ?? this.returnOrders,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      supplierFilter:
          supplierFilter != null ? supplierFilter() : this.supplierFilter,
      purchaseOrderFilter: purchaseOrderFilter != null
          ? purchaseOrderFilter()
          : this.purchaseOrderFilter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
