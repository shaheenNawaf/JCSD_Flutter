import 'package:flutter/foundation.dart'; // For listEquals and immutable
import 'package:jcsd_flutter/backend/modules/inventory/manufacturers/manufacturers_data.dart'; // Import your data model

@immutable // Ensures the state class is immutable
class ManufacturersState {
  final List<ManufacturersData> manufacturers; // Current page's data
  final String searchText; // Current search query
  final int currentPage; // Current page number
  final int totalPages; // Total number of pages
  final int itemsPerPage; // Items displayed per page
  final String sortBy; // Column currently sorted by
  final bool ascending; // Current sort direction

  // Constructor with default values
  const ManufacturersState({
    this.manufacturers = const [], // Default to empty list
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1, // Default to 1 page until calculated
    this.itemsPerPage = 10, // Match default in service or make configurable
    this.sortBy = 'manufacturerName', // Default sort column
    this.ascending = true,
  });

  // Creates a copy of the state, updating specified fields
  ManufacturersState copyWith({
    List<ManufacturersData>? manufacturers,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? sortBy,
    bool? ascending,
  }) {
    return ManufacturersState(
      manufacturers: manufacturers ?? this.manufacturers,
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

    return other is ManufacturersState &&
        listEquals(other.manufacturers, manufacturers) &&
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
      Object.hashAll(manufacturers), // Use Object.hashAll for lists
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
    return 'ManufacturersState(manufacturers: ${manufacturers.length} items, searchText: $searchText, currentPage: $currentPage, totalPages: $totalPages, itemsPerPage: $itemsPerPage, sortBy: $sortBy, ascending: $ascending)';
  }
}