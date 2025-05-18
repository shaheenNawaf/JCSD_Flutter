// Base Imports
import 'package:intl/intl.dart';
import 'package:jcsd_flutter/api/global_variables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuditItemSerial {
  final String? auditId; // UUID
  final String serialNumber;
  final int employeeId; // BIGINT
  final String userAction;
  final DateTime? auditTimestamp; // DateTime
  final String? bookingId; // UUID, nullable
  final String? returnOrderId; // UUID, nullable
  final String? notes;
  final String oldStatus;
  final String newStatus;

  AuditItemSerial({
    this.auditId,
    required this.serialNumber,
    required this.employeeId,
    required this.userAction,
    this.auditTimestamp,
    this.bookingId,
    this.returnOrderId,
    this.notes,
    required this.oldStatus,
    required this.newStatus,
  });

  factory AuditItemSerial.fromJson(Map<String, dynamic> json) {
    return AuditItemSerial(
      auditId: json['audit_id'] as String?,
      serialNumber: json['serial_number'] as String,
      employeeId: json['employee_id'] as int,
      userAction: json['user_action'] as String,
      auditTimestamp: json['audit_timestamp'] != null
          ? DateTime.parse(json['audit_timestamp'] as String)
          : null,
      bookingId: json['booking_id'] as String?,
      returnOrderId: json['return_order_id'] as String?,
      notes: json['notes'] as String?,
      oldStatus: json['old_status'] as String,
      newStatus: json['new_status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial_number': serialNumber,
      'employee_id': employeeId,
      'user_action': userAction,
      'booking_id': bookingId,
      'return_order_id': returnOrderId,
      'notes': notes,
      'old_status': oldStatus,
      'new_status': newStatus,
    };
  }
}
