// lib/backend/modules/bookings/application/booking_list_notifier.dart
//Default Imports
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/bookings/application/booking_services.dart';

//Required Enums
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';

//Booking Back-end Imports
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_state.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart';

// Hardcoded
const int _bookingItemsPerPage = 15;

/// Manages the state for lists of bookings, handling fetching, filtering, sorting, and pagination.
class BookingListNotifier extends AutoDisposeAsyncNotifier<BookingListState> {
  //Auto-handling of the search text bar, if certain time passed - it auto-searches based on the input left on the bar ;)
  Timer? _debounce;

  // Provides access to the BookingService for data operations.
  BookingService get _service => ref.read(bookingServiceProvider);

  // Initializes the notifier by fetching the first page of data.
  @override
  Future<BookingListState> build() async {
    ref.onDispose(() => _debounce?.cancel());
    final initialState =
        const BookingListState(itemsPerPage: _bookingItemsPerPage);
    final totalItems = await _fetchTotalCount(state: initialState);
    final totalPages = (totalItems / initialState.itemsPerPage).ceil();
    final items = await _fetchPageData(
        state: initialState, page: initialState.currentPage);
    return initialState.copyWith(
      bookings: items,
      totalPages: totalPages > 0 ? totalPages : 1,
    );
  }

  // Fetch Methods under here

  // Fetches the total count of bookings based on the provided state's filters.
  Future<int> _fetchTotalCount({required BookingListState state}) async {
    return _service.getBookingsCount(
      customerUserId: state.customerUserIdFilter,
      assignedEmployeeId: state.assignedEmployeeIdFilter,
      statuses: state.statusFilter,
      dateFrom: state.dateFromFilter,
      dateTo: state.dateToFilter,
      // Note: Search text filtering for count might need specific repo/service implementation
    );
  }

  // Fetches a specific page of booking data based on the provided state.
  Future<List<Booking>> _fetchPageData(
      {required BookingListState state, required int page}) async {
    // Optional lang, but good for best practice: Add search text handling if needed in the service/repository getBookings
    return _service.getBookings(
      customerUserId: state.customerUserIdFilter,
      assignedEmployeeId: state.assignedEmployeeIdFilter,
      statuses: state.statusFilter,
      dateFrom: state.dateFromFilter,
      dateTo: state.dateToFilter,
      sortBy: state.sortBy,
      ascending: state.ascending,
      page: page,
      itemsPerPage: state.itemsPerPage,
    );
  }

  // UI Shit for Pagination, Sort filters and then including the page refresh

  /// Navigates to the specified page number in the booking list.
  Future<void> goToPage(int page) async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        page < 1 ||
        page > currentState.totalPages ||
        page == currentState.currentPage) {
      return;
    }

    state = const AsyncLoading<BookingListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(state: currentState, page: page);
      // Assumes copyWith handles nullable fields correctly
      return currentState.copyWith(bookings: items, currentPage: page);
    });
  }

  /// Sorts the booking list by the specified column, toggling direction.
  Future<void> sort(String newSortBy) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final newAscending =
        currentState.sortBy == newSortBy ? !currentState.ascending : true;
    const newPage = 1;

    state = const AsyncLoading<BookingListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final items = await _fetchPageData(
        state:
            currentState.copyWith(sortBy: newSortBy, ascending: newAscending),
        page: newPage,
      );
      // Assumes copyWith handles nullable fields correctly
      return currentState.copyWith(
          bookings: items,
          currentPage: newPage,
          sortBy: newSortBy,
          ascending: newAscending);
    });
  }

  /// Applies the specified filters to the booking list and fetches the first page.
  Future<void> applyFilters({
    String? customerUserId,
    bool clearCustomerUserId = false,
    int? assignedEmployeeId,
    bool clearAssignedEmployeeId = false,
    List<BookingStatus>? statuses,
    bool clearStatuses = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    String? searchText,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Determine new filter values using if-else
    String? newCustomerUserId;
    if (clearCustomerUserId) {
      newCustomerUserId = null;
    } else if (customerUserId != null) {
      newCustomerUserId = customerUserId;
    } else {
      newCustomerUserId = currentState.customerUserIdFilter;
    }

    int? newAssignedEmployeeId;
    if (clearAssignedEmployeeId) {
      newAssignedEmployeeId = null;
    } else if (assignedEmployeeId != null) {
      newAssignedEmployeeId = assignedEmployeeId;
    } else {
      newAssignedEmployeeId = currentState.assignedEmployeeIdFilter;
    }

    List<BookingStatus>? newStatusFilter;
    if (clearStatuses) {
      newStatusFilter = null;
    } else if (statuses != null) {
      newStatusFilter = statuses;
    } else {
      newStatusFilter = currentState.statusFilter;
    }

    DateTime? newDateFrom;
    if (clearDateFrom) {
      newDateFrom = null;
    } else if (dateFrom != null) {
      newDateFrom = dateFrom;
    } else {
      newDateFrom = currentState.dateFromFilter;
    }

    DateTime? newDateTo;
    if (clearDateTo) {
      newDateTo = null;
    } else if (dateTo != null) {
      newDateTo = dateTo;
    } else {
      newDateTo = currentState.dateToFilter;
    }

    String newSearchText;
    if (searchText != null) {
      newSearchText = searchText;
    } else {
      newSearchText = currentState.searchText;
    }

    // Create the potential new state
    // Assumes copyWith in BookingListState uses ValueGetter or similar for nullables
    final newState = currentState.copyWith(
      customerUserIdFilter: () => newCustomerUserId,
      assignedEmployeeIdFilter: () => newAssignedEmployeeId,
      statusFilter: () => newStatusFilter,
      dateFromFilter: () => newDateFrom,
      dateToFilter: () => newDateTo,
      searchText: newSearchText,
      currentPage: 1, // Reset page
    );

    // Avoid reload if state hasn't actually changed
    if (newState == currentState) {
      print("Filters did not change.");
      return;
    }

    state = const AsyncLoading<BookingListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final totalItems = await _fetchTotalCount(state: newState);
      final totalPages = (totalItems / newState.itemsPerPage).ceil();
      final items =
          await _fetchPageData(state: newState, page: newState.currentPage);
      // Assumes copyWith handles nullable fields correctly
      return newState.copyWith(
        bookings: items,
        totalPages: totalPages > 0 ? totalPages : 1,
      );
    });
  }

  /// Refreshes the current view of the booking list.
  Future<void> refresh() async {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }

    state = const AsyncLoading<BookingListState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final totalItems = await _fetchTotalCount(state: currentState);
      final totalPages = (totalItems / currentState.itemsPerPage).ceil();
      final calculatedTotalPages = totalPages > 0 ? totalPages : 1;
      final currentPage =
          currentState.currentPage.clamp(1, calculatedTotalPages);
      final items =
          await _fetchPageData(state: currentState, page: currentPage);
      // Assumes copyWith handles nullable fields correctly
      return currentState.copyWith(
        bookings: items,
        totalPages: calculatedTotalPages,
        currentPage: currentPage,
      );
    });
  }
}
