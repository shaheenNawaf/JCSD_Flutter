class AuditBooking {
  final String? auditId; // UUID, nullable for inserts if DB generates it
  final DateTime? auditTimestamp; // DateTime, nullable for inserts
  final String bookingId; // UUID
  final String actionType;
  final int employeeId; // Corresponds to BIGINT in SQL
  final int adminId; // Corresponds to BIGINT in SQL
  final String? notes;

  AuditBooking({
    this.auditId,
    this.auditTimestamp,
    required this.bookingId,
    required this.actionType,
    required this.employeeId,
    required this.adminId,
    this.notes,
  });

  // Factory constructor for creating a new AuditBooking instance from a map
  factory AuditBooking.fromJson(Map<String, dynamic> json) {
    return AuditBooking(
      auditId: json['audit_id'] as String?,
      auditTimestamp: json['audit_timestamp'] != null
          ? DateTime.parse(json['audit_timestamp'] as String)
          : null,
      bookingId: json['booking_id'] as String,
      actionType: json['action_type'] as String,
      employeeId: json['employee_id'] as int,
      adminId: json['admin_id'] as int,
      notes: json['notes'] as String?,
    );
  }

  // Method for converting an AuditBooking instance to a map
  Map<String, dynamic> toJson() {
    return {
      // 'audit_id': auditId, // Typically not sent for inserts if DB generates it
      // 'audit_timestamp': auditTimestamp?.toIso8601String(), // Same as audit_id
      'booking_id': bookingId,
      'action_type': actionType,
      'employee_id': employeeId,
      'admin_id': adminId,
      'notes': notes,
    };
  }
}
