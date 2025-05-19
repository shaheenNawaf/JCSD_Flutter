
// Base Imports
import '../data/booking.dart'; // Assuming Booking is here
import '../data/booking_service_item.dart';
import '../data/booking_item.dart';
import '../data/booking_assignment.dart';

// Enums for the specified types/status
import '../booking_enums.dart';

// TY For the additional learning - but Interface essentially has all the specified methods already. 
//Easier for code maintenance and testing if needed
abstract class BookingRepository {

  //Methods start here

  // Fetches bookings based on multiple filters
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
  });

  // Selects a booking based on the specific id, mainly used for 
  Future<Booking?> getBookingById(int bookingId);

  // ADD/UPDATE/ARCHIVE

  // ServiceID -> Booking_SErivces
  Future<Booking> createBooking(Booking bookingData, List<int> serviceIds); 

  // Updates an existing booking (e.g., status, notes, prices).
  Future<Booking> updateBookingStatus(int bookingId, BookingStatus newStatus, {String? adminNotes, String? employeeNotes});
  Future<Booking> updateBookingDetails(Booking updatedBookingData); // Generic update
  Future<Booking> confirmBookingPrice(int bookingId, double finalPrice, String adminUserId); // Admin confirms final price
  Future<Booking> confirmBookingPayment(int bookingId, String adminUserId); // Admin confirms payment

  // FETCHING SERVICES -- since ADMIN has control over adding/archiving/editing services na makikita ng user

  // Fetches services associated with a specific booking.
  Future<List<BookingServiceItem>> getBookingServices(int bookingId);

  // Updates the final price or notes for a service within a booking.
  Future<BookingServiceItem> updateBookingServiceItem(int bookingServiceItemId, {double? finalPrice, String? notes});

  // Fetches a single bookingItem by Id
  Future<BookingItem?> getBookingItemById(int bookingItemId);

  // ITEM SERIALS -- ATTACHING ITEMS TO BOOKINGS

  // Fetches items associated with a specific booking.
  Future<List<BookingItem>> getBookingItems(int bookingId);

  // Adds a serialized item to a booking.
  Future<BookingItem> addBookingItem(int bookingId, String serialNumber, double priceAtAddition, int addedByEmployeeId);

  // Removes a serialized item from a booking (by its booking_items ID).
  Future<void> removeBookingItem(int bookingItemId);

  // ASSIGNMENT OPS (attaching employee and all)

  /// Fetches employee assignments for a specific booking.
  Future<List<BookingAssignment>> getBookingAssignments(int bookingId);

  /// Assigns an employee to a booking.
  Future<BookingAssignment> assignEmployeeToBooking(int bookingId, int employeeId);

  /// Removes an employee assignment from a booking by using the assignmentID
  Future<void> removeEmployeeFromBooking(int bookingAssignmentId); 

  // TODO: Fetch Status History if implemented
  // Future<List<BookingStatusHistory>> getBookingStatusHistory(int bookingId);
}