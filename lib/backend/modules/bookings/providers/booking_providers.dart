//Base Imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/bookings/application/booking_module_services.dart';

//Booking Imports
import 'package:jcsd_flutter/backend/modules/bookings/application/booking_services.dart';
import 'package:jcsd_flutter/backend/modules/bookings/infrastructure/booking_repository.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_notifier.dart';
import 'package:jcsd_flutter/backend/modules/bookings/state/list_view/booking_list_state.dart';

//Support Imports
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_providers.dart';

/// Provider for the Booking Repository implementation.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingModuleServices();
});

/// Provider for the Booking Service.
/// It depends on the booking repository and other necessary services.
final bookingServiceProvider = Provider<BookingService>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  // Watch other services required by BookingService constructor
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
