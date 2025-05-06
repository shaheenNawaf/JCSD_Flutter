import 'package:flutter/foundation.dart';
import 'package:jcsd_flutter/backend/modules/bookings/booking_enums.dart';

@immutable
class Booking {
  final int id;
  final String uuid; 
  final String? customerUserId; // Nullable for walk-ins
  final String? walkInCustomerName;
  final String? walkInCustomerContact;
  final BookingStatus status; 
  final BookingType bookingType; 
  final DateTime scheduledStartTime;
  final DateTime? scheduledEndTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final String? customerNotes;
  final String? employeeNotes;
  final String? adminNotes;
  final double? finalTotalPrice; 
  final bool requiresAdminApproval;
  final bool isPaid;
  final String? paymentConfirmedByUserId;
  final DateTime? paymentTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.uuid,
    this.customerUserId,
    this.walkInCustomerName,
    this.walkInCustomerContact,
    required this.status, 
    required this.bookingType, 
    required this.scheduledStartTime,
    this.scheduledEndTime,
    this.actualStartTime,
    this.actualEndTime,
    this.customerNotes,
    this.employeeNotes,
    this.adminNotes,
    this.finalTotalPrice,
    required this.requiresAdminApproval,
    required this.isPaid,
    this.paymentConfirmedByUserId,
    this.paymentTimestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  //Helper Functions to handle possible null data from optional parameters
  static DateTime? parseStringDateTime(String? dateString){
    if(dateString == null){
      return null;
    }
    return DateTime.tryParse(dateString);
  }

  static DateTime parseRequiredStringDateTime(String? dateString){
    if(dateString == null){
      throw const FormatException("DateTime field received null");
    }
    return DateTime.parse(dateString);
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    if(json['id'] == null || json['uuid'] == null || json['status'] == null || json['booking_type'] == null || json['scheduled_start_time'] == null || json['requires_admin_approval'] == null || json['is_paid'] == null || json['created_at'] == null || json['updated_at'] == null){
      print("Warning: Missing required field(s) in Booking JSON: $json");
    }

    return Booking(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      customerUserId: json['customer_user_id'] as String?,
      walkInCustomerName: json['walk_in_customer_name'] as String?,
      walkInCustomerContact: json['walk_in_customer_contact'] as String?,
      status: BookingStatusExtension.fromString(json['status'] as String?), 
      bookingType: BookingTypeExtension.fromString(json['booking_type'] as String?),
      scheduledStartTime: parseRequiredStringDateTime(json['scheduled_start_time']),
      scheduledEndTime: parseStringDateTime(json['scheduled_end_time']),
      actualStartTime: parseStringDateTime(json['actual_start_time']),
      actualEndTime: parseStringDateTime(json['actual_end_time']),
      customerNotes: json['customer_notes'] as String?,
      employeeNotes: json['employee_notes'] as String?,
      adminNotes: json['admin_notes'] as String?,
      finalTotalPrice: (json['final_total_price'] as num?)?.toDouble(),
      requiresAdminApproval: json['requires_admin_approval'] as bool? ?? false,
      isPaid: json['is_paid'] as bool? ?? false,
      paymentConfirmedByUserId: json['payment_confirmed_by_user_id'] as String?,
      paymentTimestamp: parseStringDateTime(json['payment_timestamp']),
      createdAt: parseRequiredStringDateTime(json['created_at']),
      updatedAt: parseRequiredStringDateTime(json['updated_at']),
    );
  }

  Booking copyWith({
    int? id,
    String? uuid,
    ValueGetter<String?>? customerUserId,
    ValueGetter<String?>? walkInCustomerName,
    ValueGetter<String?>? walkInCustomerContact,
    BookingStatus? status, // <-- Use Enum
    BookingType? bookingType, // <-- Use Enum
    DateTime? scheduledStartTime,
    ValueGetter<DateTime?>? scheduledEndTime,
    ValueGetter<DateTime?>? actualStartTime,
    ValueGetter<DateTime?>? actualEndTime,
    ValueGetter<String?>? customerNotes,
    ValueGetter<String?>? employeeNotes,
    ValueGetter<String?>? adminNotes,
    ValueGetter<double?>? finalTotalPrice,
    bool? requiresAdminApproval,
    bool? isPaid,
    ValueGetter<String?>? paymentConfirmedByUserId,
    ValueGetter<DateTime?>? paymentTimestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      customerUserId: customerUserId != null ? customerUserId() : this.customerUserId,
      walkInCustomerName: walkInCustomerName != null ? walkInCustomerName() : this.walkInCustomerName,
      walkInCustomerContact: walkInCustomerContact != null ? walkInCustomerContact() : this.walkInCustomerContact,
      status: status ?? this.status, // <-- Use Enum
      bookingType: bookingType ?? this.bookingType, // <-- Use Enum
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime != null ? scheduledEndTime() : this.scheduledEndTime,
      actualStartTime: actualStartTime != null ? actualStartTime() : this.actualStartTime,
      actualEndTime: actualEndTime != null ? actualEndTime() : this.actualEndTime,
      customerNotes: customerNotes != null ? customerNotes() : this.customerNotes,
      employeeNotes: employeeNotes != null ? employeeNotes() : this.employeeNotes,
      adminNotes: adminNotes != null ? adminNotes() : this.adminNotes,
      finalTotalPrice: finalTotalPrice != null ? finalTotalPrice() : this.finalTotalPrice,
      requiresAdminApproval: requiresAdminApproval ?? this.requiresAdminApproval,
      isPaid: isPaid ?? this.isPaid,
      paymentConfirmedByUserId: paymentConfirmedByUserId != null ? paymentConfirmedByUserId() : this.paymentConfirmedByUserId,
      paymentTimestamp: paymentTimestamp != null ? paymentTimestamp() : this.paymentTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_user_id': customerUserId,
      'walk_in_customer_name': walkInCustomerName,
      'walk_in_customer_contact': walkInCustomerContact,
      'status': status.name, 
      'booking_type': bookingType.name, 
      'scheduled_start_time': scheduledStartTime.toIso8601String(),
      'scheduled_end_time': scheduledEndTime?.toIso8601String(),
      'actual_start_time': actualStartTime?.toIso8601String(),
      'actual_end_time': actualEndTime?.toIso8601String(),
      'customer_notes': customerNotes,
      'employee_notes': employeeNotes,
      'admin_notes': adminNotes,
      'final_total_price': finalTotalPrice,
      'requires_admin_approval': requiresAdminApproval,
      'is_paid': isPaid,
      'payment_confirmed_by_user_id': paymentConfirmedByUserId,
      'payment_timestamp': paymentTimestamp?.toIso8601String(),
    };
  }
}