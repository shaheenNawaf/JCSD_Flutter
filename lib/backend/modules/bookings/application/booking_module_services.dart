//Base Imports

//Backend Imports

import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_assignment.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_service_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/infrastructure/booking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// API
import 'package:jcsd_flutter/api/global_variables.dart'; // Your global Supabase client

class BookingModuleServices implements BookingRepository {
  /// Base Select Query
  final String _baseQueryWithRelations = '''
   *,
    booking_services!inner ( 
      *, 
      jcsd_services!inner ( serviceID, serviceName, minPrice, maxPrice, estimatedDuration, isWalkInOnly, requiresAddress ) 
    ),
    booking_items ( 
      *, 
      item_serials!inner ( 
        serialNumber, 
        product_definitions!inner ( prodDefID, prodDefName, prodDefMSRP ) 
      ) 
    ),
    booking_assignments ( 
      *, 
      employee!inner ( 
        employeeID, 
        userID, 
        accounts!inner ( userID, firstName, lastName, email ) 
      ) 
    )
  ''';

  //Fetch Operations under here
  @override
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
    try {
      // Using _baseQueryWithRelations. Change to select('*') if list view doesn't need relations.
      var fetchBookingsQuery =
          supabaseDB.from('bookings').select(_baseQueryWithRelations);

      // Apply Filters
      if (customerUserId != null) {
        fetchBookingsQuery =
            fetchBookingsQuery.eq('customer_user_id', customerUserId);
      }
      if (statuses != null && statuses.isNotEmpty) {
        fetchBookingsQuery = fetchBookingsQuery.inFilter(
            'status', statuses.map((s) => s.name).toList());
      }
      if (assignedEmployeeId != null) {
        // TODO: Implement efficient filtering by assignedEmployeeId. RPC recommended.
        print(
            "Warning: Filtering by assignedEmployeeId might be inefficient. Consider RPC.");
        // Corrected direct filter attempt syntax (still subject to caveats):
        fetchBookingsQuery = fetchBookingsQuery.eq(
            'booking_assignments.employee_id', assignedEmployeeId);
      }
      if (dateFrom != null) {
        fetchBookingsQuery = fetchBookingsQuery.gte(
            'scheduled_start_time', dateFrom.toIso8601String());
      }
      if (dateTo != null) {
        final endOfDay =
            DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);
        fetchBookingsQuery = fetchBookingsQuery.lte(
            'scheduled_start_time', endOfDay.toIso8601String());
      }

      // Apply Sorting and Pagination
      final offset = (page - 1) * itemsPerPage;
      var filteredBookingsQuery = fetchBookingsQuery
          .order(sortBy, ascending: ascending)
          .range(offset, offset + itemsPerPage - 1);

      final finalBookingsData = await filteredBookingsQuery;

      // IMPORTANT TODO: Ensure Booking.fromJson can correctly parse nested JSON from joins.
      final completeFetchedData =
          finalBookingsData.map((item) => Booking.fromJson(item)).toList();

      // TODO: Implement post-fetch filtering for assignedEmployeeId if direct DB filter fails.
      return completeFetchedData;
    } catch (err, sty) {
      print('Error fetching bookings: $err \n $sty');
      rethrow;
    }
  }

  //Standard Count of the Total Bookings based on the given filters - mainly for Pagination
  @override
  Future<int> getBookingsCount({
    String? customerUserId,
    int? assignedEmployeeId,
    List<BookingStatus>? statuses,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      //Same filters ra sa getbooking, but other
      var bookingsCountQuery =
          supabaseDB.from('bookings').select(_baseQueryWithRelations);
      if (customerUserId != null) {
        bookingsCountQuery =
            bookingsCountQuery.eq('customer_user_id', customerUserId);
      }

      if (statuses != null && statuses.isNotEmpty) {
        bookingsCountQuery = bookingsCountQuery.inFilter(
            'status', statuses.map((s) => s.name).toList());
      }

      if (assignedEmployeeId != null) {
        print(
            "Warning: Filtering count by assignedEmployeeId not implemented efficiently here.");
      }

      if (dateFrom != null) {
        bookingsCountQuery = bookingsCountQuery.gte(
            'scheduled_start_time', dateFrom.toIso8601String());
      }
      if (dateTo != null) {
        final endOfDay =
            DateTime(dateTo.year, dateTo.month, dateTo.day, 23, 59, 59);
        bookingsCountQuery = bookingsCountQuery.lte(
            'scheduled_start_time', endOfDay.toIso8601String());
      }

      final count = await bookingsCountQuery.count(CountOption.exact);
      return count.count;
    } catch (err, sty) {
      print('Error fetching bookings count: $err \n $sty');
      rethrow;
    }
  }

  //Fetching specific booking details by given ID
  @override
  Future<Booking?> getBookingById(int bookingId) async {
    try {
      final data = await supabaseDB
          .from('bookings')
          .select(_baseQueryWithRelations)
          .eq('id', bookingId)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      // IMPORTANT TODO: Ensure Booking.fromJson handles nested data from joins correctly.
      return Booking.fromJson(data);
    } catch (e, st) {
      print('Error fetching booking by ID $bookingId: $e \n$st');
      rethrow;
    }
  }

  // ACTION Functions (mga add, edit ganern)

  @override
  Future<Booking> createBooking(
      Booking bookingData, List<int> serviceIds) async {
    print(
        "Executing non-atomic createBooking. Consider using RPC for data integrity.");
    PostgrestMap? insertedBookingData; // To store response for ID retrieval

    try {
      final bookingJson = bookingData.toJson();
      //Sabi best practice daw to eh
      bookingJson.remove('id');
      bookingJson.remove('uuid');
      bookingJson.remove('created_at');
      bookingJson.remove('updated_at');
      bookingJson['status'] = bookingData.status.name;
      bookingJson['booking_type'] = bookingData.bookingType.name;

      insertedBookingData = await supabaseDB
          .from('bookings')
          .insert(bookingJson)
          .select('id')
          .single();

      final newBookingId = insertedBookingData['id'] as int;

      List<Map<String, dynamic>> bookingServicesToInsert = [];
      if (serviceIds.isNotEmpty) {
        final servicesDetails = await supabaseDB
            .from('jcsd_services')
            .select('serviceID, minPrice')
            .inFilter('serviceID', serviceIds);

        // Map that looks up for the given minPrice of a service - USED for estimation
        final servicePriceMap = {
          for (var service in servicesDetails)
            service['serviceID'] as int: (service['minPrice'] as num?)
                    ?.toDouble() ??
                0.0 // Fallback to def (0) if there is no minPrice; safe data passing tayo ser
        };

        // Prepare data for the booking_services junction table insert
        bookingServicesToInsert = serviceIds
            .map((serviceId) => {
                  'booking_id': newBookingId,
                  'service_id': serviceId,
                  'estimated_price': servicePriceMap[serviceId] ??
                      0.0, // Added a conditional dito, para just in case if the backend pulls wrong data for the minPrice, fallsback to def val of 0. Clearer makitan if naay mali ba
                })
            .toList();

        // 3. Insert the links into booking_services with correct estimated_price
        if (bookingServicesToInsert.isNotEmpty) {
          await supabaseDB
              .from('booking_services')
              .insert(bookingServicesToInsert);
        } else {
          print(
              "Warning: No valid service details found for provided service IDs during booking creation.");
        }
      }

      // 4. Refetch the complete booking data with all relations now that inserts are done
      final finalBookingData = await getBookingById(newBookingId);
      if (finalBookingData == null) {
        throw Exception(
            "Failed to fetch newly created booking with ID $newBookingId after insert.");
      }
      return finalBookingData; // Return the fully populated Booking object
    } catch (e, st) {
      print('Error during createBooking process: $e');
      // Log Supabase specific error if available from the insert step
      if (insertedBookingData != null && insertedBookingData['id'] == null) {
        print('Supabase Error during booking insert might have occurred.');
      }
      print('Stack trace: \n$st');
      rethrow; // Rethrow for the service layer
    }
  }

  @override
  Future<Booking> updateBookingDetails(Booking updatedBookingData) async {
    if (updatedBookingData.id == null) {
      throw ArgumentError("Booking ID is required for update.");
    }
    try {
      final updates = updatedBookingData.toJson();
      updates.remove('id');
      updates.remove('uuid');
      updates.remove('created_at');
      updates
          .remove('customer_user_id'); // Prevent changing the customer easily
      updates['status'] = updatedBookingData.status.name;
      updates['booking_type'] = updatedBookingData.bookingType.name;

      final data = await supabaseDB
          .from('bookings')
          .update(updates)
          .eq('id', updatedBookingData.id)
          .select(_baseQueryWithRelations)
          .single();
      return Booking.fromJson(data);
    } catch (err, sty) {
      print(
          'Error updating booking details for ${updatedBookingData.id}: $err \n $sty');
      rethrow;
    }
  }

  @override
  Future<Booking> updateBookingStatus(int bookingId, BookingStatus newStatus,
      {String? adminNotes, String? employeeNotes}) async {
    try {
      final updates = <String, dynamic>{'status': newStatus.name};
      if (adminNotes != null) updates['admin_notes'] = adminNotes;
      if (employeeNotes != null) updates['employee_notes'] = employeeNotes;

      final updatedData = await supabaseDB
          .from('bookings')
          .update(updates)
          .eq('id', bookingId)
          .select(_baseQueryWithRelations)
          .single();

      return Booking.fromJson(updatedData);
    } catch (err, sty) {
      print('Error updating booking status for $bookingId: $err \n$sty');
      rethrow;
    }
  }

  @override
  Future<Booking> confirmBookingPrice(
      int bookingId, double finalPrice, String adminUserId) async {
    try {
      final updatedData = await supabaseDB
          .from('bookings')
          .update({
            'final_total_price': finalPrice,
            'requires_admin_approval': false, // Price is now approved
            // 'price_approved_by_user_id': adminUserId, // Add this column if needed for logging
            'status':
                BookingStatus.pendingPayment.name // Move to next logical status
          })
          .eq('id', bookingId)
          .select(_baseQueryWithRelations)
          .single();

      // TODO: Add Audit Logs for tracking -- Booking Audit Logs
      // IMPORTANT TODO: Ensure Booking.fromJson handles nested data
      return Booking.fromJson(updatedData);
    } catch (e, st) {
      print('Error confirming booking price for $bookingId: $e \n$st');
      rethrow;
    }
  }

  @override
  Future<Booking> confirmBookingPayment(
      int bookingId, String adminUserId) async {
    try {
      final updatedData = await supabaseDB
          .from('bookings')
          .update({
            'is_paid': true,
            'payment_confirmed_by_user_id': adminUserId,
            'payment_timestamp': DateTime.now().toIso8601String(),
            'status': BookingStatus.completed.name // Mark as completed
          })
          .eq('id', bookingId)
          .select(_baseQueryWithRelations)
          .single();

      // TODO: Add Audit Logs for tracking -- Booking Audit Logs
      // IMPORTANT TODO: Ensure Booking.fromJson handles nested data
      return Booking.fromJson(updatedData);
    } catch (e, st) {
      print('Error confirming booking payment for $bookingId: $e \n$st');
      rethrow;
    }
  }

  // Item/Services

  @override
  Future<List<BookingServiceItem>> getBookingServices(int bookingId) async {
    try {
      // Join to get service details needed for display
      final data = await supabaseDB
          .from('booking_services')
          .select(
              '*, jcsd_services!inner(serviceID, serviceName, minPrice, maxPrice)')
          .eq('booking_id', bookingId);

      // IMPORTANT TODO: Ensure BookingServiceItem.fromJson handles nested jcsd_services data if selected
      return data.map((item) => BookingServiceItem.fromJson(item)).toList();
    } catch (e, st) {
      print('Error fetching booking services for $bookingId: $e \n$st');
      rethrow;
    }
  }

  @override
  Future<BookingServiceItem> updateBookingServiceItem(int bookingServiceItemId,
      {double? finalPrice, String? notes}) async {
    // Ensure at least one field is provided for update
    if (finalPrice == null && notes == null) {
      throw ArgumentError(
          "At least finalPrice or notes must be provided for update.");
    }
    try {
      final updates = <String, dynamic>{};
      if (finalPrice != null) updates['final_price'] = finalPrice;
      if (notes != null) updates['notes'] = notes;

      final data = await supabaseDB
          .from('booking_services')
          .update(updates)
          .eq('id', bookingServiceItemId)
          .select()
          .single();

      // Note: Triggering requiresAdminApproval flag is handled in BookingService layer
      return BookingServiceItem.fromJson(data);
    } catch (e, st) {
      print(
          'Error updating booking service item $bookingServiceItemId: $e \n$st');
      rethrow;
    }
  }

  // ITEM Serial Operations under Booking Services

  @override
  Future<List<BookingItem>> getBookingItems(int bookingId) async {
    try {
      // Join to get necessary related info (e.g., item name, serial)
      final data = await supabaseDB
          .from('booking_items')
          .select(
              '*, item_serials!inner(serialNumber, product_definitions!inner(prodDefName, prodDefMSRP))') // Example join
          .eq('booking_id', bookingId);

      return data.map((item) => BookingItem.fromJson(item)).toList();
    } catch (e, st) {
      print('Error fetching booking items for $bookingId: $e \n$st');
      rethrow;
    }
  }

  @override // Implementation for the previously missing method from interface
  Future<BookingItem?> getBookingItemById(int bookingItemId) async {
    try {
      final data = await supabaseDB
          .from('booking_items')
          .select()
          .eq('id', bookingItemId)
          .maybeSingle();

      if (data == null) {
        return null; // Not found
      }
      // Assumes BookingItem.fromJson only needs columns from booking_items table
      return BookingItem.fromJson(data);
    } catch (e, st) {
      print('Error fetching booking item by ID $bookingItemId: $e \n$st');
      rethrow;
    }
  }

  @override
  Future<BookingItem> addBookingItem(int bookingId, String serialNumber,
      double priceAtAddition, int addedByEmployeeId) async {
    try {
      final newItem = {
        'booking_id': bookingId,
        'serial_number': serialNumber,
        'price_at_addition': priceAtAddition,
        'added_by_employee_id': addedByEmployeeId,
      };

      final insertedItem = await supabaseDB
          .from('booking_items')
          .insert(newItem)
          .select()
          .single();

      // Note: Updating inventory status & requiresAdminApproval flag is handled in BookingService layer
      return BookingItem.fromJson(insertedItem);
    } catch (e, st) {
      print(
          'Error adding booking item ($serialNumber) to booking $bookingId: $e \n$st');
      rethrow;
    }
  }

  @override
  Future<void> removeBookingItem(int bookingItemId) async {
    try {
      // Note: Fetching details & updating inventory status is handled in BookingService layer
      await supabaseDB.from('booking_items').delete().eq('id', bookingItemId);
    } catch (e, st) {
      print('Error removing booking item ID $bookingItemId: $e \n$st');
      rethrow;
    }
  }

  //Booking Assignments

  @override
  Future<List<BookingAssignment>> getBookingAssignments(int bookingId) async {
    try {
      // Join to get employee name details
      final data = await supabaseDB
          .from('booking_assignments')
          .select(
              '*, employee!inner(employeeID, accounts!inner(firstName, lastName) )') // Example join
          .eq('booking_id', bookingId);

      // IMPORTANT TODO: Ensure BookingAssignment.fromJson handles nested data
      return data.map((item) => BookingAssignment.fromJson(item)).toList();
    } catch (e, st) {
      print('Error fetching booking assignments for $bookingId: $e \n$st');
      rethrow;
    }
  }

  //Assigning an employee
  @override
  Future<BookingAssignment> assignEmployeeToBooking(
      int bookingId, int employeeId) async {
    try {
      final newAssignment = {
        'booking_id': bookingId,
        'employee_id': employeeId,
      };

      final insertedAssignment = await supabaseDB
          .from('booking_assignments')
          .insert(newAssignment)
          .select()
          .single();

      // Booking Status under booking_services.dart
      return BookingAssignment.fromJson(insertedAssignment);
    } catch (e, st) {
      print(
          'Error assigning employee $employeeId to booking $bookingId: $e \n$st');
      rethrow;
    }
  }

  //Removes an employee
  @override
  Future<void> removeEmployeeFromBooking(int bookingAssignmentId) async {
    try {
      await supabaseDB
          .from('booking_assignments')
          .delete()
          .eq('id', bookingAssignmentId); // Target by primary key
    } catch (e, st) {
      print(
          'Error removing booking assignment ID $bookingAssignmentId: $e \n$st');
      rethrow;
    }
  }
}
