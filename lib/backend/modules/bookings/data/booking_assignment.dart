import 'package:flutter/foundation.dart';

@immutable
class BookingAssignment {
  final int id; // Primary key of the booking_assignments table
  final int bookingId; // Foreign key to bookings table
  final int employeeId; // Foreign key to employee table (referencing employeeID bigint)
  final DateTime assignedAt;
  //TODO -- Add role_on_booking if you included it in the schema
  // final String? roleOnBooking;

  const BookingAssignment({
    required this.id,
    required this.bookingId,
    required this.employeeId,
    required this.assignedAt,
    // this.roleOnBooking,
  });

  static DateTime _parseRequiredDateTime(String? dateString) {
     if (dateString == null) {
       throw const FormatException("Required DateTime field received null: assigned_at");
     }
     return DateTime.parse(dateString);
  }

  factory BookingAssignment.fromJson(Map<String, dynamic> json) {
     if (json['id'] == null || json['booking_id'] == null || json['employee_id'] == null || json['assigned_at'] == null) {
       print("Warning: Missing required field(s) in BookingAssignment JSON: $json");
     }

    return BookingAssignment(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      employeeId: json['employee_id'] as int,
      assignedAt: _parseRequiredDateTime(json['assigned_at']),
      // roleOnBooking: json['role_on_booking'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Only these fields are required
    return {
      'booking_id': bookingId,
      'employee_id': employeeId,
      // 'role_on_booking': roleOnBooking,
    };
  }

  BookingAssignment copyWith({
    int? id,
    int? bookingId,
    int? employeeId,
    DateTime? assignedAt,
    // String? roleOnBooking,
  }) {
    return BookingAssignment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      employeeId: employeeId ?? this.employeeId,
      assignedAt: assignedAt ?? this.assignedAt,
      // roleOnBooking: roleOnBooking ?? this.roleOnBooking,
    );
  }
}