import 'package:flutter/foundation.dart'; // For listEquals and immutable
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import related files
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_data.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_notifiers.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_service.dart';
import 'package:jcsd_flutter/backend/modules/suppliers/suppliers_notifiers.dart'; // Will be created next

// --- State Class Definition ---

@immutable // Ensures the state class is immutable
class SuppliersState {
  final List<SuppliersData> suppliers; // Current page's data
  final String searchText; // Current search query
  final int currentPage; // Current page number
  final int totalPages; // Total number of pages
  final int itemsPerPage; // Items displayed per page
  final String sortBy; // Column currently sorted by
  final bool ascending; // Current sort direction

  // Constructor with default values
  const SuppliersState({
    this.suppliers = const [], // Default to empty list
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1, // Default to 1 page until calculated
    this.itemsPerPage = 10, // Match default in service or make configurable
    this.sortBy = 'supplierName', // Default sort column
    this.ascending = true,
  });

  // Creates a copy of the state, updating specified fields
  SuppliersState copyWith({
    List<SuppliersData>? suppliers,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? sortBy,
    bool? ascending,
  }) {
    return SuppliersState(
      suppliers: suppliers ?? this.suppliers,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  // Equality operator for state comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuppliersState &&
        listEquals(other.suppliers, suppliers) &&
        other.searchText == searchText &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.itemsPerPage == itemsPerPage &&
        other.sortBy == sortBy &&
        other.ascending == ascending;
  }

  // Hash code implementation
  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(suppliers), // Use Object.hashAll for lists
      searchText,
      currentPage,
      totalPages,
      itemsPerPage,
      sortBy,
      ascending,
    );
  }

  // String representation for debugging
  @override
  String toString() {
    return 'SuppliersState(suppliers: ${suppliers.length} items, searchText: $searchText, currentPage: $currentPage, totalPages: $totalPages, itemsPerPage: $itemsPerPage, sortBy: $sortBy, ascending: $ascending)';
  }
}

// --- Provider Definitions ---

/// Provider that creates and exposes an instance of [SuppliersService].
final suppliersServiceProvider = Provider<SuppliersService>((ref) {
  return SuppliersService(); // Creates a new instance of the service
});

/// Notifier provider for managing Suppliers (Active/Archived). Family param bool: true=Active, false=Archived.
final suppliersNotifierProvider = AutoDisposeAsyncNotifierProviderFamily<
    SuppliersNotifier, SuppliersState, bool>(
  () => SuppliersNotifier(),
);

/// FutureProvider specifically for fetching active suppliers for dropdowns.
final activeSuppliersForDropdownProvider = FutureProvider.autoDispose<List<SuppliersData>>((ref) async {
  final service = ref.watch(suppliersServiceProvider);
  // Fetch only active suppliers using the service method
  // Assuming getAllSuppliersForSelect is similar to manufacturers or a dedicated method exists
  // Let's use availableSuppliers for now, adjust if needed.
  return service.availableSuppliers();
  // Or ideally: return service.getAllSuppliersForSelect(activeOnly: true); if you add that method.
});

///Fetches only active suppliers
final supplierNameMapProvider = FutureProvider.autoDispose<Map<int, String>>((ref) async {
  final suppliersList = await ref.watch(activeSuppliersForDropdownProvider.future);
  return {
    for (var supplier in suppliersList) supplier.supplierID : supplier.supplierName
  };
});