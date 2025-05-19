// NOTE: Business Logic layer is here, Booking_module_services is the basic toolkit lang

// Base Imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';

// Booking Imports
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_assignment.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_service_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/infrastructure/booking_repository.dart';

// Support Imports
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_service.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services.dart';
import 'package:jcsd_flutter/backend/modules/services/jcsd_services_state.dart';
import 'package:printing/printing.dart';

class BookingService {
  final BookingRepository _bookingRepository;
  final JcsdServices _servicesService;
  final SerialitemService _inventoryService;
  // Optional: Use Ref if accessing providers directly within service methods
  // final Ref _ref;

  // Constructor for dependency injection.
  BookingService(this._bookingRepository, this._servicesService,
      this._inventoryService /*, this._ref */);

  // Validation helpers - ensuring ra na tama ang data. Thanks Gemini for this!

  // Checks if a status transition is allowed based on current status and user role.
  Future<bool> _isTransitionAllowed(BookingStatus? currentStatus,
      BookingStatus newStatus, String? userRole) async {
    if (currentStatus == null) return false;
    final Map<BookingStatus, List<BookingStatus>> allowedTransitions = {
      BookingStatus.pendingConfirmation: [
        BookingStatus.confirmed,
        BookingStatus.cancelled
      ],
      BookingStatus.confirmed: [
        BookingStatus.inProgress,
        BookingStatus.cancelled,
        BookingStatus.noShow
      ],
      BookingStatus.inProgress: [
        BookingStatus.pendingAdminApproval,
        BookingStatus.pendingParts,
        BookingStatus.pendingCustomerResponse,
        BookingStatus.cancelled
      ],
      BookingStatus.pendingParts: [
        BookingStatus.inProgress,
        BookingStatus.cancelled
      ],
      BookingStatus.pendingCustomerResponse: [
        BookingStatus.inProgress,
        BookingStatus.cancelled
      ],
      BookingStatus.pendingAdminApproval: [
        BookingStatus.pendingPayment,
        BookingStatus.inProgress,
        BookingStatus.cancelled
      ],
      BookingStatus.pendingPayment: [
        BookingStatus.completed,
        BookingStatus.cancelled
      ],
      BookingStatus.completed: [],
      BookingStatus.cancelled: [],
      BookingStatus.noShow: [],
      BookingStatus.unknown: [],
    };
    bool isAllowed =
        allowedTransitions[currentStatus]?.contains(newStatus) ?? false;
    if (userRole != 'admin') {
      // Role-based restrictions
      if ([
            BookingStatus.confirmed,
            BookingStatus.completed,
            BookingStatus.pendingPayment
          ].contains(newStatus) &&
          currentStatus != BookingStatus.pendingAdminApproval) {
        isAllowed = false;
      }
      if (newStatus == BookingStatus.noShow) isAllowed = false;
    }
    return isAllowed;
  }

  // Checks if the booking status allows adding/removing items or changing prices.
  bool _canModifyBookingItemsOrPrice(BookingStatus? status) {
    if (status == null) return false;
    return [
      BookingStatus.confirmed,
      BookingStatus.inProgress,
      BookingStatus.pendingParts,
      BookingStatus.pendingCustomerResponse
    ].contains(status);
  }

  // Fetches a booking or throws a specific error if not found.
  Future<Booking> _getBookingOrThrow(int bookingId) async {
    final booking = await _bookingRepository.getBookingById(bookingId);
    if (booking == null) throw Exception("Booking not found (ID: $bookingId).");
    return booking;
  }

  // --- Core Booking Creation and Management ---

  /// Creates a new booking request, validates inputs, and calculates initial estimates.
  Future<Booking> createNewBookingRequest({
    required String? customerUserId,
    required String? walkInCustomerName,
    required String? walkInCustomerContact,
    required List<int> serviceIds,
    required DateTime scheduledStartTime,
    required BookingType bookingType,
    String? customerNotes,
    required WidgetRef ref, // Pass ref if fetching services via provider here
  }) async {
    // Input Validation
    if (customerUserId == null &&
        (walkInCustomerName == null || walkInCustomerName.trim().isEmpty)) {
      throw ArgumentError(
          "Customer details (User ID or Walk-in Name) are required.");
    }
    if (serviceIds.isEmpty) {
      throw ArgumentError("At least one service must be selected.");
    }
    if (scheduledStartTime
        .isBefore(DateTime.now().subtract(const Duration(minutes: 5)))) {
      throw ArgumentError("Scheduled start time cannot be in the past.");
    }

    // TODO: Add validation: Check against business hours, employee availability.

    // Data Preparation: Fetch service details for estimates
    double totalEstimatedPrice = 0.0;
    int maxDurationMinutes = 0;

    // In this code block, bale it fetches all the active serivces na naka-indicate or ginawang active ng admin
    try {
      final allActiveServices = await ref.read(fetchAvailableServices.future);

      //Mapping all services, storing their serviceIDs
      final serviceMap = {for (var s in allActiveServices) s.serviceID: s};

      for (int id in serviceIds) {
        final service = serviceMap[id];
        if (service != null) {
          totalEstimatedPrice +=
              service.minPrice ?? 0.0; // Use minPrice or default
          int duration =
              service.estimatedDuration ?? 60; // Use duration or default
          if (duration > maxDurationMinutes) maxDurationMinutes = duration;
        } else {
          print("Warning: Could not find active service details for ID $id.");
          totalEstimatedPrice += 500.0; // Fallback estimate
          if (60 > maxDurationMinutes) {
            maxDurationMinutes = 60; // Fallback duration
          }
        }
      }
      if (maxDurationMinutes == 0 && serviceIds.isNotEmpty) {
        maxDurationMinutes = 60; // Ensure minimum duration
      }
    } catch (e) {
      throw Exception("Failed to retrieve service details: $e");
    }

    final totalEstimatedDuration = Duration(minutes: maxDurationMinutes);
    final initialBookingData = Booking(
      id: 0, uuid: '', createdAt: DateTime.now(),
      updatedAt: DateTime.now(), // Placeholders
      customerUserId: customerUserId, walkInCustomerName: walkInCustomerName,
      walkInCustomerContact: walkInCustomerContact,
      status: BookingStatus.pendingConfirmation, bookingType: bookingType,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledStartTime.add(totalEstimatedDuration),
      customerNotes: customerNotes, finalTotalPrice: null,
      requiresAdminApproval: false, isPaid: false,
      paymentConfirmedByUserId: null, paymentTimestamp: null,
      actualStartTime: null, actualEndTime: null,
      employeeNotes: null, adminNotes: null,
    );

    // Repository Call: Create booking and link services (repo handles inserting estimates)
    try {
      final createdBooking = await _bookingRepository.createBooking(
          initialBookingData, serviceIds);
      print(
          "BookingService: Booking created successfully with ID ${createdBooking.id}");
      // TODO: Trigger notification to Admin
      return createdBooking;
    } catch (e) {
      print("BookingService Error creating booking: $e");
      rethrow;
    }
  }

  /// Confirms a booking request and assigns an employee (Admin action).
  Future<Booking> confirmBookingRequest(int bookingId, int employeeId,
      {String? adminNotes}) async {
    final currentBooking = await _getBookingOrThrow(bookingId);
    if (currentBooking.status != BookingStatus.pendingConfirmation) {
      throw Exception(
          "Booking cannot be confirmed. Current status: ${currentBooking.status.name}");
    }

    try {
      await _bookingRepository.assignEmployeeToBooking(bookingId, employeeId);
      final updatedBooking = await _bookingRepository.updateBookingStatus(
          bookingId, BookingStatus.confirmed,
          adminNotes: adminNotes);
      print(
          "BookingService: Booking $bookingId confirmed and assigned to employee $employeeId.");

      final items = await _bookingRepository.getBookingItems(bookingId);
      List<String> failedInventoryUpdates = [];
      if (items.isNotEmpty) {
        print(
            "BookingService: Attempting to update ${items.length} serial items to status 'Reserved' for confirmed booking $bookingId.");
        for (var item in items) {
          try {
            await _inventoryService.updateSerializedItemStatus(
                item.serialNumber, 'Reserved'); // Directly set to 'Reserved'
            print(
                "BookingService: Serial item ${item.serialNumber} status updated to Reserved.");
          } catch (invError) {
            print(
                "BookingService Warning: Failed inventory update for ${item.serialNumber} to Reserved: $invError");
            failedInventoryUpdates.add(item.serialNumber);
          }
        }
        if (failedInventoryUpdates.isNotEmpty) {
          print(
              "BookingService: Inventory status update to Reserved failed for items: ${failedInventoryUpdates.join(', ')}");
        }
      }
      // TODO: Trigger notification to Customer and assigned Employee
      return updatedBooking;
    } catch (e) {
      print("BookingService Error confirming booking $bookingId: $e");
      rethrow;
    }
  }

  /// Updates the status of a booking after validation.
  Future<Booking> updateBookingStatus(int bookingId, BookingStatus newStatus,
      {String? notes, String? userId, String? userRole}) async {
    final currentBooking = await _getBookingOrThrow(bookingId);
    if (!await _isTransitionAllowed(
        currentBooking.status, newStatus, userRole)) {
      throw Exception(
          "Transition from ${currentBooking.status.name} to ${newStatus.name} is not allowed for role '$userRole'.");
    }

    String? adminNote = (userRole == 'admin') ? notes : null;
    String? employeeNote = (userRole == 'employee') ? notes : null;

    try {
      final updatedBooking = await _bookingRepository.updateBookingStatus(
          bookingId, newStatus,
          adminNotes: adminNote, employeeNotes: employeeNote);
      print(
          "BookingService: Status updated for booking $bookingId to ${newStatus.name}.");
      final String? targetSerialItemStatus =
          _getSerialItemStatusForBookingStatus(newStatus);

      if (targetSerialItemStatus != null) {
        final items = await _bookingRepository.getBookingItems(bookingId);
        List<String> failedInventoryUpdates = [];
        print(
            "BookingService: Attempting to update ${items.length} serial items to status $targetSerialItemStatus for booking $bookingId.");
        for (var item in items) {
          try {
            await _inventoryService.updateSerializedItemStatus(
                item.serialNumber, targetSerialItemStatus);
            print(
                "BookingService: Serial item ${item.serialNumber} status updated to $targetSerialItemStatus.");
          } catch (invError) {
            print(
                "BookingService Warning: Failed inventory update for ${item.serialNumber} to $targetSerialItemStatus: $invError");
            failedInventoryUpdates.add(item.serialNumber);
          }
        }
        if (failedInventoryUpdates.isNotEmpty) {
          // Handle or log these failures more robustly if needed
          print(
              "BookingService: Inventory status update to $targetSerialItemStatus failed for items: ${failedInventoryUpdates.join(', ')}");
        }
      }
      return updatedBooking;
    } catch (e) {
      print("BookingService Error updating status for booking $bookingId: $e");
      rethrow;
    }
  }

  // --- Item and Service Management during Booking ---

  /// Adds an inventory item to a booking, updates inventory status, and flags for admin approval.
  Future<BookingItem> addItemToBooking(int bookingId, String serialNumber,
      double priceAtAddition, int employeeId) async {
    final currentBooking = await _getBookingOrThrow(bookingId);
    if (!_canModifyBookingItemsOrPrice(currentBooking.status)) {
      throw Exception(
          "Cannot add items to booking in status: ${currentBooking.status.name}");
    }

    try {
      final addedItem = await _bookingRepository.addBookingItem(
          bookingId, serialNumber, priceAtAddition, employeeId);
      if (!currentBooking.requiresAdminApproval) {
        final bookingUpdateData =
            currentBooking.copyWith(requiresAdminApproval: true);
        await _bookingRepository.updateBookingDetails(bookingUpdateData);
      }
      await _inventoryService.updateSerializedItemStatus(
          serialNumber, 'Reserved');
      print(
          "BookingService: Item $serialNumber added to Booking $bookingId and marked Allocated.");
      return addedItem;
    } catch (e) {
      print("BookingService Error adding item to booking $bookingId: $e");
      rethrow;
    }
  }

  /// Removes an item from a booking, updates inventory status, and re-evaluates admin approval flag.
  Future<void> removeItemFromBooking(int bookingItemId, int bookingId) async {
    final currentBooking = await _getBookingOrThrow(bookingId);
    if (!_canModifyBookingItemsOrPrice(currentBooking.status)) {
      throw Exception(
          "Cannot remove items from booking in status: ${currentBooking.status.name}");
    }

    final bookingItem = await _bookingRepository
        .getBookingItemById(bookingItemId); // Uses the added repo method
    if (bookingItem == null) {
      throw Exception("Booking item $bookingItemId not found.");
    }
    final String serialNumberToUpdate = bookingItem.serialNumber;

    try {
      await _bookingRepository.removeBookingItem(bookingItemId);
      await _inventoryService.updateSerializedItemStatus(
          serialNumberToUpdate, 'Unused');

      // Re-check if admin approval is still needed
      if (currentBooking.requiresAdminApproval) {
        final services = await _bookingRepository.getBookingServices(bookingId);
        final remainingItems =
            await _bookingRepository.getBookingItems(bookingId);
        bool stillRequiresApproval =
            services.any((s) => s.finalPrice != null) ||
                remainingItems.isNotEmpty;
        if (!stillRequiresApproval) {
          final bookingUpdateData =
              currentBooking.copyWith(requiresAdminApproval: false);
          await _bookingRepository.updateBookingDetails(bookingUpdateData);
        }
      }
      print(
          "BookingService: Item $bookingItemId (SN: $serialNumberToUpdate) removed from Booking $bookingId. Inventory status updated.");
    } catch (e) {
      print(
          "BookingService Error removing item $bookingItemId from booking $bookingId: $e");
      rethrow;
    }
  }

  /// Updates the final price for a specific service within a booking and flags for admin approval.
  Future<BookingServiceItem> updateServiceItemPrice(
      int bookingServiceItemId, double finalPrice, int bookingId) async {
    final currentBooking = await _getBookingOrThrow(bookingId);
    if (!_canModifyBookingItemsOrPrice(currentBooking.status)) {
      throw Exception(
          "Cannot update service price in status: ${currentBooking.status.name}");
    }
    if (finalPrice < 0) throw ArgumentError("Final price cannot be negative.");
    // TODO: Add validation against service min/max price?

    try {
      final updatedItem = await _bookingRepository.updateBookingServiceItem(
          bookingServiceItemId,
          finalPrice: finalPrice);
      if (!currentBooking.requiresAdminApproval) {
        final bookingUpdateData =
            currentBooking.copyWith(requiresAdminApproval: true);
        await _bookingRepository.updateBookingDetails(bookingUpdateData);
      }
      print(
          "BookingService: Price updated for service item $bookingServiceItemId in Booking $bookingId.");
      return updatedItem;
    } catch (e) {
      print(
          "BookingService Error updating service item price for $bookingServiceItemId: $e");
      rethrow;
    }
  }

  // --- Admin Approval and Completion ---

  /// Calculates final price, confirms it, clears admin flag, and sets status (Admin action).
  Future<Booking> confirmFinalPrice(int bookingId, String adminUserId) async {
    final currentBooking = await _getBookingOrThrow(bookingId);
    if (currentBooking.status != BookingStatus.pendingAdminApproval) {
      print(
          "Warning: Confirming price for booking not in pendingAdminApproval status (current: ${currentBooking.status.name})");
    }
    // TODO: Validate all variable-priced services have final price set.

    // Calculate final total price
    final services = await _bookingRepository.getBookingServices(bookingId);
    final items = await _bookingRepository.getBookingItems(bookingId);
    double calculatedTotal = 0;
    for (var service in services) {
      calculatedTotal +=
          (service.finalPrice != null && service.finalPrice! >= 0)
              ? service.finalPrice!
              : (service.estimatedPrice ?? 0.0);
    }
    for (var item in items) {
      calculatedTotal += item.priceAtAddition;
    }

    try {
      final updatedBooking = await _bookingRepository.confirmBookingPrice(
          bookingId, calculatedTotal, adminUserId);
      print(
          "BookingService: Final price ($calculatedTotal) confirmed for booking $bookingId by $adminUserId.");
      // TODO: Trigger notification to customer?
      return updatedBooking;
    } catch (e) {
      print("BookingService Error confirming price for booking $bookingId: $e");
      rethrow;
    }
  }

  /// Confirms payment, updates inventory status to 'Sold', and sets booking status to 'Completed' (Admin action).
  Future<Booking> confirmPayment(int bookingId, String adminUserId) async {
    final currentBooking = await _getBookingOrThrow(bookingId);

    if (currentBooking.status != BookingStatus.pendingPayment) {
      print(
          "Warning: Confirming payment for booking not in pendingPayment status (current: ${currentBooking.status.name})");
    }
    if (currentBooking.finalTotalPrice == null ||
        currentBooking.finalTotalPrice! < 0) {
      throw Exception(
          "Cannot confirm payment: Final total price is not set or is invalid.");
    }

    try {
      final booking = await _bookingRepository.confirmBookingPayment(
          bookingId, adminUserId); // Update booking first

      // Update inventory status for used items
      final items = await _bookingRepository.getBookingItems(bookingId);
      List<String> failedInventoryUpdates = [];
      for (var item in items) {
        try {
          await _inventoryService.updateSerializedItemStatus(
              item.serialNumber, 'Sold');
        } catch (invError) {
          print(
              "BookingService Warning: Failed inventory update for ${item.serialNumber} to Sold: $invError");
          failedInventoryUpdates.add(item.serialNumber);
        }
      }
      if (failedInventoryUpdates.isNotEmpty) {
        print(
            "Inventory status update failed for items: ${failedInventoryUpdates.join(', ')}");
      }

      print(
          "BookingService: Payment confirmed for booking $bookingId. Inventory updated (with ${failedInventoryUpdates.length} failures).");
      // TODO: Trigger final receipt notification to customer
      return booking;
    } catch (e) {
      print(
          "BookingService Error confirming payment for booking $bookingId: $e");
      rethrow;
    }
  }

  // Data Fetching Methods thru Repository (CRUD Methods)

  /// Fetches a list of bookings based on specified criteria.
  Future<List<Booking>> getBookings({
    String? customerUserId,
    int? assignedEmployeeId,
    List<BookingStatus>? statuses,
    DateTime? dateFrom,
    DateTime? dateTo,
    String sortBy = 'created_at',
    bool ascending = false,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    return _bookingRepository.getBookings(
      customerUserId: customerUserId,
      assignedEmployeeId: assignedEmployeeId,
      statuses: statuses,
      dateFrom: dateFrom,
      dateTo: dateTo,
      sortBy: sortBy,
      ascending: ascending,
      page: page,
      itemsPerPage: itemsPerPage,
    );
  }

  /// Fetches the total count of bookings matching specified criteria.
  Future<int> getBookingsCount({
    String? customerUserId,
    int? assignedEmployeeId,
    List<BookingStatus>? statuses,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return _bookingRepository.getBookingsCount(
      customerUserId: customerUserId,
      assignedEmployeeId: assignedEmployeeId,
      statuses: statuses,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  /// Fetches full details (including relations) for a single booking.
  Future<Booking?> getBookingDetails(int bookingId) async {
    return _bookingRepository.getBookingById(bookingId);
  }

  /// Fetches the service items associated with a booking.
  Future<List<BookingServiceItem>> getBookingServices(int bookingId) async {
    return _bookingRepository.getBookingServices(bookingId);
  }

  /// Fetches the inventory items associated with a booking.
  Future<List<BookingItem>> getBookingItems(int bookingId) async {
    return _bookingRepository.getBookingItems(bookingId);
  }

  /// Fetches the employee assignments for a booking.
  Future<List<BookingAssignment>> getBookingAssignments(int bookingId) async {
    return _bookingRepository.getBookingAssignments(bookingId);
  }

  /// Removes an employee assignment from a booking.
  Future<void> removeEmployeeFromBooking(int assignmentId) async {
    // Add validation? e.g., prevent removing last employee if status is 'Confirmed'/'In Progress'?
    try {
      await _bookingRepository.removeEmployeeFromBooking(assignmentId);
      print("BookingService: Removed assignment $assignmentId.");
      // Optionally update booking status if needed (e.g., back to Pending Confirmation?)
    } catch (e) {
      print("BookingService Error removing assignment $assignmentId: $e");
      rethrow;
    }
  }

  // Additional Helper Service
  String? _getSerialItemStatusForBookingStatus(BookingStatus bookingStatus) {
    switch (bookingStatus) {
      case BookingStatus.confirmed:
        return 'Reserved';
      case BookingStatus.pendingAdminApproval:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Unused';
      default:
        return null;
    }
  }
}
