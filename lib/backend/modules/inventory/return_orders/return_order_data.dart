class ReturnOrderData {
  final int? id;
  final DateTime? createdAt;
  final int purchaseOrderId;
  final String employeeId; // Assuming UUID as String
  final String? employeeName; // For display, fetch separately if needed
  final DateTime returnDate;
  ReturnOrderStatus status;
  final String? adminId; // Assuming UUID as String
  final String? adminName; // For display
  final DateTime? adminActionDate;
  final String? notes;
  final int? supplierId;
  final String? supplierName; // For display

  // Optional: To hold the items when fetching a full RO
  final List<ReturnOrderItemData>? items;

  ReturnOrderData({
    this.id,
    this.createdAt,
    required this.purchaseOrderId,
    required this.employeeId,
    this.employeeName,
    required this.returnDate,
    required this.status,
    this.adminId,
    this.adminName,
    this.adminActionDate,
    this.notes,
    this.supplierId,
    this.supplierName,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      // 'created_at' is usually handled by Supabase, not sent on insert
      'purchase_order_id': purchaseOrderId,
      'employee_id': employeeId,
      'return_date': returnDate
          .toIso8601String()
          .substring(0, 10), // Format as YYYY-MM-DD for 'date' type
      'status': status
          .name, // Store the enum's name (e.g., 'pendingAdminConfirmation')
      if (adminId != null) 'admin_id': adminId,
      if (adminActionDate != null)
        'admin_action_date': adminActionDate?.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (supplierId != null) 'supplier_id': supplierId,
    };
  }

  factory ReturnOrderData.fromJson(Map<String, dynamic> map) {
    return ReturnOrderData(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      purchaseOrderId: map['purchase_order_id'] as int,
      employeeId: map['employee_id'] as String,
      employeeName: map['employees'] != null
          ? map['employees']['full_name'] as String?
          : null, // Example if joining
      returnDate: DateTime.parse(map['return_date'] as String),
      status: ReturnOrderStatus.fromString(map['status'] as String?),
      adminId: map['admin_id'] as String?,
      adminName: map['admin_profiles'] != null
          ? map['admin_profiles']['full_name'] as String?
          : null, // Example for joined admin name
      adminActionDate: map['admin_action_date'] != null
          ? DateTime.parse(map['admin_action_date'] as String)
          : null,
      notes: map['notes'] as String?,
      supplierId: map['supplier_id'] as int?,
      supplierName: map['suppliers'] != null
          ? map['suppliers']['name'] as String?
          : null, // Example for joined supplier name
      items: map['return_order_items'] != null
          ? List<ReturnOrderItemData>.from(
              (map['return_order_items'] as List<dynamic>)
                  .map<ReturnOrderItemData?>(
                (x) => ReturnOrderItemData.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  ReturnOrderData copyWith({
    int? id,
    DateTime? createdAt,
    int? purchaseOrderId,
    String? employeeId,
    String? employeeName,
    DateTime? returnDate,
    ReturnOrderStatus? status,
    String? adminId,
    String? adminName,
    DateTime? adminActionDate,
    String? notes,
    int? supplierId,
    String? supplierName,
    List<ReturnOrderItemData>? items,
  }) {
    return ReturnOrderData(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      adminActionDate: adminActionDate ?? this.adminActionDate,
      notes: notes ?? this.notes,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
    );
  }
}
