
import 'package:flutter/foundation.dart';

@immutable
class BookingItem {
  final int id; // PK - Booking_items
  final int bookingId; // FK - Bookings
  final String serialNumber; // FK - Item Serials
  final int addedByEmployeeId; // FK - Employee Table
  final double priceAtAddition; // Selling price declaration
  final DateTime addedAt;

  const BookingItem({
    required this.id,
    required this.bookingId,
    required this.serialNumber,
    required this.addedByEmployeeId,
    required this.priceAtAddition,
    required this.addedAt,
  });

   static DateTime _parseRequiredDateTime(String? dateString) {
     if (dateString == null) {
       throw const FormatException("Required DateTime field received null: added_at");
     }
     return DateTime.parse(dateString);
  }

  //Helper Methods for safe parsing - nilalagay ko na sa lahat ng code ko!
  static double _parseRequiredDouble(dynamic priceValue) {
    if (priceValue == null) throw const FormatException("Required price field received null: price_at_addition");
    if (priceValue is double) return priceValue;
    if (priceValue is int) return priceValue.toDouble();
    if (priceValue is String) return double.parse(priceValue);
    throw FormatException("Invalid type for required price field: ${priceValue.runtimeType}");
 }

  factory BookingItem.fromJson(Map<String, dynamic> json) {
     if (json['id'] == null || json['booking_id'] == null || json['serial_number'] == null || json['added_by_employee_id'] == null || json['price_at_addition'] == null || json['added_at'] == null) {
       print("Warning: Missing required field(s) in BookingItem JSON: $json");
     }

    return BookingItem(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      serialNumber: json['serial_number'] as String,
      addedByEmployeeId: json['added_by_employee_id'] as int,
      priceAtAddition: _parseRequiredDouble(json['price_at_addition']),
      addedAt: _parseRequiredDateTime(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    // Only these fields are required
    return {
      'booking_id': bookingId,
      'serial_number': serialNumber,
      'added_by_employee_id': addedByEmployeeId,
      'price_at_addition': priceAtAddition,
    };
  }

  BookingItem copyWith({
    int? id,
    int? bookingId,
    String? serialNumber,
    int? addedByEmployeeId,
    double? priceAtAddition,
    DateTime? addedAt,
  }) {
    return BookingItem(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serialNumber: serialNumber ?? this.serialNumber,
      addedByEmployeeId: addedByEmployeeId ?? this.addedByEmployeeId,
      priceAtAddition: priceAtAddition ?? this.priceAtAddition,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}