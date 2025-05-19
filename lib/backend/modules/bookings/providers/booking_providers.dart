//Base Imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/bookings/application/booking_module_services.dart';

//Booking Imports
import 'package:jcsd_flutter/backend/modules/bookings/application/booking_services.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/infrastructure/booking_repository.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/detail_view/booking_detail_notifier.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_notifier.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_state.dart';

//Support Imports
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';

/// Provider for the Booking Repository implementation.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingModuleServices();
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  final servicesService = ref.watch(serviceStateProvider);
  final inventoryService =
      ref.watch(serialitemServiceProvider); // Make sure this provider exists

  // Pass the dependencies to the BookingService constructor
  return BookingService(repository, servicesService, inventoryService);
});

final bookingListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<BookingListNotifier, BookingListState>(
  () => BookingListNotifier(),
);

final bookingDetailNotifierProvider = AutoDisposeAsyncNotifierProviderFamily<
    BookingDetailNotifier, Booking?, int>(
  () => BookingDetailNotifier(),
);

final pendingBookingsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  return bookingService.getBookingsCount(
    statuses: [BookingStatus.pendingConfirmation],
  );
});

// Provider for Confirmed Bookings Today Count
final confirmedBookingsTodayCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return bookingService.getBookingsCount(
    statuses: [BookingStatus.confirmed],
    dateFrom: todayStart,
    dateTo: todayEnd,
  );
});

// Provider for Home Services Today Count
final homeServicesTodayCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final bookings = await bookingService.getBookings(
    dateFrom: todayStart,
    dateTo: todayEnd,
    bookingTypes: BookingType.homeService,
    itemsPerPage: 1000,
  );
  return bookings.length;
});

// Provider for Walk-Ins Today Count
final walkInsTodayCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final bookingService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  final bookings = await bookingService.getBookings(
    dateFrom: todayStart,
    dateTo: todayEnd,
    bookingTypes: BookingType.walkIn,
    itemsPerPage: 1000,
  );
  return bookings.length;
  // Ideal (if service supports it):
  // return bookingService.getBookingsCount(
  //   bookingTypes: [BookingType.walkIn],
  //   dateFrom: todayStart,
  //   dateTo: todayEnd,
  // );
});
