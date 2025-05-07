//Default Imports
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/bookings/application/booking_services.dart';

//Backend Imports
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/providers/booking_providers.dart'; // Import providers

//Default Enums
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';

class BookingDetailNotifier
    extends AutoDisposeFamilyAsyncNotifier<Booking?, int> {
  // Provides access to the BookingService for data operations.
  BookingService get _service => ref.read(bookingServiceProvider);

  // Initializes the notifier by fetching the details for the given bookingId.
  @override
  Future<Booking?> build(int bookingId) async {
    return _service.getBookingDetails(bookingId);
  }

  // --- Action Methods for the Specific Booking ---

  /// Updates the status of the current booking and refreshes the state.
  Future<void> updateStatus(BookingStatus newStatus,
      {String? notes, String? userId, String? userRole}) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>()
        .copyWithPrevious(state); // Preserve previous data while loading
    state = await AsyncValue.guard(() async {
      await _service.updateBookingStatus(bookingId, newStatus,
          notes: notes, userId: userId, userRole: userRole);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Adds an item to the current booking and refreshes the state.
  Future<void> addItem(
      String serialNumber, double priceAtAddition, int employeeId) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _service.addItemToBooking(
          bookingId, serialNumber, priceAtAddition, employeeId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Removes an item from the current booking and refreshes the state.
  Future<void> removeItem(int bookingItemId) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _service.removeItemFromBooking(bookingItemId, bookingId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Updates the final price of a service item within the current booking and refreshes the state.
  Future<void> updateServicePrice(
      int bookingServiceItemId, double finalPrice) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _service.updateServiceItemPrice(
          bookingServiceItemId, finalPrice, bookingId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Assigns an employee to the current booking (likely also changes status) and refreshes the state.
  Future<void> assignEmployee(int employeeId) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      // Uses confirmBookingRequest which assigns and sets status to Confirmed
      await _service.confirmBookingRequest(bookingId, employeeId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Removes an employee assignment from the current booking and refreshes the state.
  Future<void> removeEmployee(int assignmentId) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _service.removeEmployeeFromBooking(assignmentId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Confirms the final calculated price for the current booking (Admin action) and refreshes the state.
  Future<void> confirmPrice(String adminUserId) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _service.confirmFinalPrice(bookingId, adminUserId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Confirms payment for the current booking (Admin action) and refreshes the state.
  Future<void> confirmPayment(String adminUserId) async {
    final bookingId = arg;
    state = const AsyncLoading<Booking?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await _service.confirmPayment(bookingId, adminUserId);
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }

  /// Manually refreshes the booking details state.
  Future<void> refresh() async {
    final bookingId = arg;
    state = const AsyncLoading(); // Show loading immediately
    state = await AsyncValue.guard(() async {
      return _service.getBookingDetails(bookingId); // Refetch
    });
  }
}
