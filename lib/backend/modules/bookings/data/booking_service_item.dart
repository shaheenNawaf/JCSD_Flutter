import 'package:flutter/foundation.dart';

@immutable
class BookingServiceItem {
  final int id; 
  final int bookingId; 
  final int serviceId; 
  final double estimatedPrice;
  final double? finalPrice; 
  final String? notes; 

  const BookingServiceItem({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    required this.estimatedPrice,
    this.finalPrice,
    this.notes,
  });

// Helper Methods under here, safe parsing of data - just best practices lang shahern

  static double _parseRequiredDouble(dynamic priceValue) {
    if (priceValue == null) throw const FormatException("Required price field received null.");
    if (priceValue is double) return priceValue;
    if (priceValue is int) return priceValue.toDouble();
    if (priceValue is String) return double.parse(priceValue); 
    throw FormatException("Invalid type for required price field: ${priceValue.runtimeType}");
 }

  static double? _parseOptionalDouble(dynamic priceValue) {
    if (priceValue == null) return null;
    if (priceValue is double) return priceValue;
    if (priceValue is int) return priceValue.toDouble();
    if (priceValue is String) return double.tryParse(priceValue);
    return null;
 }


  factory BookingServiceItem.fromJson(Map<String, dynamic> json) {
     if (json['id'] == null || json['booking_id'] == null || json['service_id'] == null || json['estimated_price'] == null) {
       print("Warning: Missing required field(s) in BookingServiceItem JSON: $json");
     }

    return BookingServiceItem(
      id: json['id'] as int,
      bookingId: json['booking_id'] as int,
      serviceId: json['service_id'] as int,
      estimatedPrice: _parseRequiredDouble(json['estimated_price']),
      finalPrice: _parseOptionalDouble(json['final_price']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    //Not all fields are required for input/update - ito lang
    return {
      'booking_id': bookingId,
      'service_id': serviceId,
      'estimated_price': estimatedPrice,
      'final_price': finalPrice,
      'notes': notes,
    };
  }

   BookingServiceItem copyWith({
    int? id,
    int? bookingId,
    int? serviceId,
    double? estimatedPrice,
    ValueGetter<double?>? finalPrice, 
    ValueGetter<String?>? notes,     
  }) {
    return BookingServiceItem(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice != null ? finalPrice() : this.finalPrice,
      notes: notes != null ? notes() : this.notes,
    );
  }
}