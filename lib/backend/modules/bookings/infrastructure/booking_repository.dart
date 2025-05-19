import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_assignment.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_item.dart';
import 'package:jcsd_flutter/backend/modules/bookings/data/booking_service_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assumed data models have fromJson and necessary toJson/toInitialJson methods.
// e.g., Booking class should have:
// Map<String, dynamic> toInitialJson() for inserts.
// Map<String, dynamic> toJsonForUpdate() for updates.

class BookingRepository {
  final SupabaseClient _supabaseClient;

  BookingRepository(this._supabaseClient);

  Future<Booking?> getBookingById(int bookingId) async {
    try {
      final response = await _supabaseClient
          .from('bookings')
          .select(
              '*, booking_services(*, service:jcsd_services(*)), booking_items(*, item_serial:item_serials(*, product_definition:product_definitions(*))), booking_assignments(*, employee:employee(*))')
          .eq('id', bookingId)
          .maybeSingle();
      if (response == null) return null;
      return Booking.fromJson(response);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getBookingById: $e\n$stackTrace');
      rethrow;
    }
  }

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
      var query = _supabaseClient.from('bookings').select(
          '*, booking_services(*, service:jcsd_services(*)), booking_assignments(*, employee:employee(*))'); // Select relations needed for list view

      if (customerUserId != null) {
        query = query.eq('customer_user_id', customerUserId);
      }
      if (statuses != null && statuses.isNotEmpty) {
        query = query.in('status', statuses.map((s) => s.name).toList());
      }
      if (dateFrom != null) {
        query = query.gte('scheduled_start_time', dateFrom.toIso8601String());
      }
      if (dateTo != null) {
        query = query.lte(
            'scheduled_start_time',
            dateTo
                .toIso8601String()); // Consider if dateTo should be exclusive or inclusive of the whole day
      }

      // TODO: Implement assignedEmployeeId filter. This might require a join or checking if booking_assignments contains the employeeId.
      // This is more complex if assignedEmployeeId is not a direct column on 'bookings'.
      // For now, this part is omitted. If 'bookings' has an 'assignee_id' type column, it's simpler:
      // if (assignedEmployeeId != null) {
      //   query = query.eq('some_direct_employee_column_on_bookings', assignedEmployeeId);
      // }

      query = query.order(sortBy, ascending: ascending);

      if (itemsPerPage > 0) {
        final offset = (page - 1) * itemsPerPage;
        query = query.range(offset, offset + itemsPerPage - 1);
      }

      final response = await query;
      return (response as List)
          .map((data) => Booking.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getBookings: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<int> getBookingsCount({
    String? customerUserId,
    int? assignedEmployeeId,
    List<BookingStatus>? statuses,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      var query = _supabaseClient.from('bookings').count(CountOption.exact);

      if (customerUserId != null) {
        query = query.eq('customer_user_id', customerUserId);
      }
      // TODO: Implement assignedEmployeeId filter similar to getBookings
      if (statuses != null && statuses.isNotEmpty) {
        query = query.in('status', statuses.map((s) => s.name).toList());
      }
      if (dateFrom != null) {
        query = query.gte('scheduled_start_time', dateFrom.toIso8601String());
      }
      if (dateTo != null) {
        query = query.lte('scheduled_start_time', dateTo.toIso8601String());
      }
      final count = await query;
      return count;
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getBookingsCount: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Booking> createBooking(
      Booking bookingData, List<int> serviceIds) async {
    try {
      // TODO: Ensure bookingData.toInitialJson() exists and provides the correct map for insert.
      final bookingJson = bookingData.toInitialJson();
      final bookingRecord = await _supabaseClient
          .from('bookings')
          .insert(bookingJson)
          .select()
          .single();

      final createdBookingId = bookingRecord['id'] as int;

      if (serviceIds.isNotEmpty) {
        final serviceEntries = serviceIds.map((serviceId) {
          // Attempt to get estimated_price from the input bookingData if available
          // This assumes bookingData might have preliminary service details.
          final serviceDetail = bookingData.bookingServices?.firstWhere(
              (bs) => bs.serviceId == serviceId,
              orElse: () => BookingServiceItem(
                  id: 0,
                  bookingId: 0,
                  serviceId: serviceId,
                  estimatedPrice: 0) // Default if not found
              );
          return {
            'booking_id': createdBookingId,
            'service_id': serviceId,
            'estimated_price':
                serviceDetail?.estimatedPrice ?? 0.0, // Use a default if null
          };
        }).toList();
        await _supabaseClient.from('booking_services').insert(serviceEntries);
      }

      final fullBooking = await getBookingById(createdBookingId);
      if (fullBooking == null) {
        print("Error: Newly created booking ID $createdBookingId not found.");
        return Booking.fromJson(bookingRecord); // Fallback, may lack relations
      }
      return fullBooking;
    } catch (e, stackTrace) {
      print('Error creating booking in BookingRepository: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Booking> updateBookingStatus(int bookingId, BookingStatus newStatus,
      {String? adminNotes, String? employeeNotes}) async {
    try {
      final Map<String, dynamic> updates = {'status': newStatus.name};
      if (adminNotes != null) updates['admin_notes'] = adminNotes;
      if (employeeNotes != null) updates['employee_notes'] = employeeNotes;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from('bookings')
          .update(updates)
          .eq('id', bookingId)
          .select()
          .single();
      return Booking.fromJson(response);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.updateBookingStatus: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> assignEmployeeToBooking(int bookingId, int employeeId) async {
    try {
      await _supabaseClient.from('booking_assignments').insert({
        'booking_id': bookingId,
        'employee_id': employeeId,
        // 'assigned_at' should have a default value in the DB (e.g., now())
      });
    } catch (e, stackTrace) {
      print(
          'Error in BookingRepository.assignEmployeeToBooking: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<BookingItem> addBookingItem(int bookingId, String serialNumber,
      double priceAtAddition, int employeeId) async {
    try {
      final response = await _supabaseClient
          .from('booking_items')
          .insert({
            'booking_id': bookingId,
            'serial_number': serialNumber,
            'price_at_addition': priceAtAddition,
            'added_by_employee_id': employeeId,
            // 'added_at' should have a default value in the DB
          })
          .select()
          .single();
      return BookingItem.fromJson(response);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.addBookingItem: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> removeBookingItem(int bookingItemId) async {
    try {
      await _supabaseClient
          .from('booking_items')
          .delete()
          .eq('id', bookingItemId);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.removeBookingItem: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<BookingItem?> getBookingItemById(int bookingItemId) async {
    try {
      final response = await _supabaseClient
          .from('booking_items')
          .select()
          .eq('id', bookingItemId)
          .maybeSingle();
      return response == null ? null : BookingItem.fromJson(response);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getBookingItemById: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Booking> updateBookingDetails(Booking booking) async {
    try {
      // TODO: Ensure booking.toJsonForUpdate() exists and provides the correct map.
      // Exclude primary key and fields that shouldn't be updated directly (like created_at).
      final updateData = booking.toJsonForUpdate();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from('bookings')
          .update(updateData)
          .eq('id', booking.id) // Assuming booking.id is not null
          .select()
          .single();
      return Booking.fromJson(response);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.updateBookingDetails: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<BookingServiceItem>> getBookingServices(int bookingId) async {
    try {
      final response = await _supabaseClient
          .from('booking_services')
          .select(
              '*, service:jcsd_services(*)') // Ensure alias for service matches model
          .eq('booking_id', bookingId);
      return (response as List)
          .map((data) =>
              BookingServiceItem.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getBookingServices: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<BookingItem>> getBookingItems(int bookingId) async {
    try {
      final response = await _supabaseClient
          .from('booking_items')
          .select(
              '*, item_serial:item_serials(*, product_definition:product_definitions(*))') // Ensure aliases match model
          .eq('booking_id', bookingId);
      return (response as List)
          .map((data) => BookingItem.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getBookingItems: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<BookingServiceItem> updateBookingServiceItem(int bookingServiceItemId,
      {double? finalPrice, String? notes}) async {
    try {
      final Map<String, dynamic> updates = {};
      if (finalPrice != null) updates['final_price'] = finalPrice;
      if (notes != null) {
        updates['employee_notes'] = notes; // Or other notes field
      }

      final response = await _supabaseClient
          .from('booking_services')
          .update(updates)
          .eq('id', bookingServiceItemId)
          .select()
          .single();
      return BookingServiceItem.fromJson(response);
    } catch (e, stackTrace) {
      print(
          'Error in BookingRepository.updateBookingServiceItem: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Booking> confirmBookingPrice(
      int bookingId, double finalTotalPrice, String adminUserId) async {
    try {
      final updates = {
        'final_total_price': finalTotalPrice,
        'requires_admin_approval': false,
        'status': BookingStatus
            .pendingPayment.name, // Assuming this is the next status
        'updated_at': DateTime.now().toIso8601String(),
      };
      final response = await _supabaseClient
          .from('bookings')
          .update(updates)
          .eq('id', bookingId)
          .select()
          .single();
      return Booking.fromJson(response);
    } catch (e, stackTrace) {
      print('Error in BookingRepository.confirmBookingPrice: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<Booking> confirmBookingPayment(
      int bookingId, String adminUserId) async {
    try {
      final updates = {
        'is_paid': true,
        'payment_confirmed_by_user_id': adminUserId,
        'payment_timestamp': DateTime.now().toIso8601String(),
        'status': BookingStatus.completed.name,
        'updated_at': DateTime.now().toIso8601String(),
      };
      final response = await _supabaseClient
          .from('bookings')
          .update(updates)
          .eq('id', bookingId)
          .select()
          .single();
      return Booking.fromJson(response);
    } catch (e, stackTrace) {
      print(
          'Error in BookingRepository.confirmBookingPayment: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> removeEmployeeFromBooking(int assignmentId) async {
    try {
      await _supabaseClient
          .from('booking_assignments')
          .delete()
          .eq('id', assignmentId);
    } catch (e, stackTrace) {
      print(
          'Error in BookingRepository.removeEmployeeFromBooking: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<BookingAssignment>> getBookingAssignments(int bookingId) async {
    try {
      final response = await _supabaseClient
          .from('booking_assignments')
          .select('*, employee:employee(*)') // Ensure alias matches model
          .eq('booking_id', bookingId);
      return (response as List)
          .map((data) =>
              BookingAssignment.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print(
          'Error in BookingRepository.getBookingAssignments: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<Booking>> getPotentiallyOverlappingBookings(
    String customerUserId,
    DateTime proposedStartTime, // Renamed for clarity within this method
    DateTime proposedEndTime, // Renamed for clarity
    List<BookingStatus> statuses,
  ) async {
    try {
      final statusStrings = statuses.map((s) => s.name).toList();
      // The overlap condition:
      // existing.start_time < proposed.end_time AND existing.end_time > proposed.start_time
      final response = await _supabaseClient
          .from('bookings')
          .select()
          .eq('customer_user_id', customerUserId)
          .in_('status', statusStrings)
          .lt('scheduled_start_time', proposedEndTime.toIso8601String())
          .gt('scheduled_end_time', proposedStartTime.toIso8601String());

      final List<Map<String, dynamic>> responseData =
          List<Map<String, dynamic>>.from(response);
      return responseData.map((data) => Booking.fromJson(data)).toList();
    } catch (e, stackTrace) {
      print(
          'Error in BookingRepository.getPotentiallyOverlappingBookings: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<List<Booking>> getAllBookings() async {
    try {
      // TODO: Consider if this needs pagination or filtering, or if it's truly "all".
      // Adding default ordering for consistency.
      final response =
          await _supabaseClient.from('bookings').select().order('created_at');
      return (response as List)
          .map((data) => Booking.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('Error in BookingRepository.getAllBookings: $e\n$stackTrace');
      rethrow;
    }
  }
}
