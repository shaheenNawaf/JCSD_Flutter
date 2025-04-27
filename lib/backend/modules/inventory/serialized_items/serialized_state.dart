import 'package:flutter/foundation.dart'; // For listEquals and immutable
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart'; // Import SerializedItem data model

@immutable // Ensures the state class is immutable
class SerializedItemState {
  final List<SerializedItem> serializedItems; // Current page's serial items
  final String searchText; // Current search query within this PD
  final int currentPage; // Current page number for this PD's serials
  final int totalPages; // Total number of pages for this PD's serials
  final int itemsPerPage; // Items displayed per page
  final String sortBy; // Column currently sorted by (e.g., 'serialNumber', 'status')
  final bool ascending; // Current sort direction
  final String? statusFilter; // Optional filter for item status

  // Constructor with default values
  const SerializedItemState({
    this.serializedItems = const [], // Default to empty list
    this.searchText = '',
    this.currentPage = 1,
    this.totalPages = 1, // Default to 1 page until calculated
    this.itemsPerPage = 10, // Match default or make configurable
    this.sortBy = 'serialNumber', // Default sort column
    this.ascending = true,
    this.statusFilter, // Default to no status filter
  });

  // Creates a copy of the state, updating specified fields
  SerializedItemState copyWith({
    List<SerializedItem>? serializedItems,
    String? searchText,
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    String? sortBy,
    bool? ascending,
    // Use ValueGetter to explicitly handle null for filters
    ValueGetter<String?>? statusFilter,
  }) {
    return SerializedItemState(
      serializedItems: serializedItems ?? this.serializedItems,
      searchText: searchText ?? this.searchText,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
    );
  }

  // Equality operator for state comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SerializedItemState &&
        listEquals(other.serializedItems, serializedItems) &&
        other.searchText == searchText &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.itemsPerPage == itemsPerPage &&
        other.sortBy == sortBy &&
        other.ascending == ascending &&
        other.statusFilter == statusFilter;
  }

  // Hash code implementation
  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(serializedItems),
      searchText,
      currentPage,
      totalPages,
      itemsPerPage,
      sortBy,
      ascending,
      statusFilter,
    );
  }

  // String representation for debugging
  @override
  String toString() {
    return 'SerializedItemState(items: ${serializedItems.length}, search: $searchText, page: $currentPage/$totalPages, sort: $sortBy $ascending, status: $statusFilter)';
  }
}