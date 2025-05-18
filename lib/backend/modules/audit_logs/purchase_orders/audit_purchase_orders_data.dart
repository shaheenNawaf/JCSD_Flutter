class AuditPurchaseOrder {
  final String? auditId; // UUID
  final DateTime? auditTimestamp; // DateTime
  final String actionType;
  final int employeeId; // BIGINT
  final int? adminId; // BIGINT, nullable
  final String? notes;
  final int? poId; // BIGINT, nullable

  AuditPurchaseOrder({
    this.auditId,
    this.auditTimestamp,
    required this.actionType,
    required this.employeeId,
    this.adminId,
    this.notes,
    this.poId,
  });

  factory AuditPurchaseOrder.fromJson(Map<String, dynamic> json) {
    return AuditPurchaseOrder(
      auditId: json['audit_id'] as String?,
      auditTimestamp: json['audit_timestamp'] != null
          ? DateTime.parse(json['audit_timestamp'] as String)
          : null,
      actionType: json['action_type'] as String,
      employeeId: json['employee_id'] as int,
      adminId: json['admin_id'] as int?,
      notes: json['notes'] as String?,
      poId: json['po_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action_type': actionType,
      'employee_id': employeeId,
      'admin_id': adminId,
      'notes': notes,
      'po_id': poId,
    };
  }
}
