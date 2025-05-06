import 'package:flutter/foundation.dart';

// Booking Imports
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';

class BookingListState {
  final List<Booking> bookings; 


  // Filters under here
  final String? customerUserIdFilter;
  final int? assignedEmployeeIdFilter;
  final List<BookingStatus>? statusFilter;
  final DateTime? dateFromFilter;
  final DateTime? dateToFilter;
  final String searchText; 

  // Pagination Function here
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;

  // Sorting 
  final String sortBy;
  final bool ascending;

  const BookingListState({
    this.bookings = const [],

    // Filters
    this.customerUserIdFilter,
    this.assignedEmployeeIdFilter,
    this.statusFilter,
    this.dateFromFilter,
    this.dateToFilter,
    this.searchText = '',

    // Pagination
    this.currentPage = 1,
    this.totalPages = 1,
    this.itemsPerPage = 10, 
    
    // Sorting
    this.sortBy = 'created_at',
    this.ascending = false,
  });

  BookingListState copyWith({
    List<Booking>? bookings,
    // Filters (use ValueGetter for nullables)
    ValueGetter<String?>? customerUserIdFilter,
    ValueGetter<int?>? assignedEmployeeIdFilter,
    ValueGetter<List<BookingStatus>?>? statusFilter,
    ValueGetter<DateTime?>? dateFromFilter,
    ValueGetter<DateTime?>? dateToFilter,
    String? searchText,
    // Pagination
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    // Sorting
    String? sortBy,
    bool? ascending,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      // Filters
      customerUserIdFilter: customerUserIdFilter != null ? customerUserIdFilter() : this.customerUserIdFilter,
      assignedEmployeeIdFilter: assignedEmployeeIdFilter != null ? assignedEmployeeIdFilter() : this.assignedEmployeeIdFilter,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      dateFromFilter: dateFromFilter != null ? dateFromFilter() : this.dateFromFilter,
      dateToFilter: dateToFilter != null ? dateToFilter() : this.dateToFilter,
      searchText: searchText ?? this.searchText,
      // Pagination
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      // Sorting
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingListState &&
          runtimeType == other.runtimeType &&
          listEquals(bookings, other.bookings) &&
          customerUserIdFilter == other.customerUserIdFilter &&
          assignedEmployeeIdFilter == other.assignedEmployeeIdFilter &&
          listEquals(statusFilter, other.statusFilter) &&
          dateFromFilter == other.dateFromFilter &&
          dateToFilter == other.dateToFilter &&
          searchText == other.searchText &&
          currentPage == other.currentPage &&
          totalPages == other.totalPages &&
          itemsPerPage == other.itemsPerPage &&
          sortBy == other.sortBy &&
          ascending == other.ascending;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(bookings),
        customerUserIdFilter,
        assignedEmployeeIdFilter,
        Object.hashAll(statusFilter ?? []), // Handle null list
        dateFromFilter,
        dateToFilter,
        searchText,
        currentPage,
        totalPages,
        itemsPerPage,
        sortBy,
        ascending,
      );

   @override
   String toString() {
     return 'BookingListState(bookings: ${bookings.length}, filters: [customer:$customerUserIdFilter, emp:$assignedEmployeeIdFilter, status:$statusFilter, date:$dateFromFilter-$dateToFilter, search:$searchText], page: $currentPage/$totalPages, sort: $sortBy $ascending)';
   }
}