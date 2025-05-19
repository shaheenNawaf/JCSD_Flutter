import 'package:flutter/foundation.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_item_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_status.dart'; // Your new enum

@immutable
class ReturnOrderData {
  final int returnOrderID; // PK, generated
  final int purchaseOrderID; // FK
  final int employeeID; // FK (who created RO)
  final DateTime returnDate; // Defaults to now()
  final ReturnOrderStatus status;
  final DateTime? adminActionDate; // Nullable
  final String? notes; // Nullable
  final DateTime createdDate; // Defaults to now()
  final int? adminID; // FK (who approved/rejected, nullable)
  final int supplierID; // FK (from original PO)
  // Optional: For display, fetched via joins if needed
  final String? supplierName;
  final String? employeeName;
  final String? adminName;
  final List<ReturnOrderItemData>? items; // For details view

  const ReturnOrderData({
    required this.returnOrderID,
    required this.purchaseOrderID,
    required this.employeeID,
    required this.returnDate,
    required this.status,
    this.adminActionDate,
    this.notes,
    required this.createdDate,
    this.adminID,
    required this.supplierID,
    this.supplierName,
    this.employeeName,
    this.adminName,
    this.items,
  });

  static DateTime? _parseOptionalDateTime(String? dateString) {
    return dateString != null ? DateTime.tryParse(dateString)?.toLocal() : null;
  }

  static DateTime _parseRequiredDateTime(String? dateString) {
    if (dateString == null) {
      print(
          'Warning: Required DateTime field received null in ReturnOrderData, using fallback.');
      return DateTime.now().toLocal(); // Fallback
    }
    return DateTime.parse(dateString).toLocal();
  }

  factory ReturnOrderData.fromJson(Map<String, dynamic> json) {
    // Nested data handling (example if you join these in your SELECT)
    final List<ReturnOrderItemData>? parsedItems;
    if (json['return_order_items'] != null &&
        json['return_order_items'] is List) {
      parsedItems = (json['return_order_items'] as List)
          .map((itemJson) =>
              ReturnOrderItemData.fromJson(itemJson as Map<String, dynamic>))
          .toList();
    } else {
      parsedItems = null;
    }

    // Example of fetching related names if you join them
    final String? fetchedSupplierName =
        json['suppliers']?['supplierName'] as String?;
    final String? fetchedEmployeeName = (json['employee_creator']
                    ?['accounts'] !=
                null &&
            json['employee_creator']['accounts'] is Map)
        ? "${json['employee_creator']['accounts']['firstName']} ${json['employee_creator']['accounts']['lastName']}"
        : null;
    final String? fetchedAdminName = (json['employee_admin']?['accounts'] !=
                null &&
            json['employee_admin']['accounts'] is Map)
        ? "${json['employee_admin']['accounts']['firstName']} ${json['employee_admin']['accounts']['lastName']}"
        : null;

    return ReturnOrderData(
      returnOrderID: json['returnOrderID'] as int,
      purchaseOrderID: json['purchaseOrderID'] as int,
      employeeID: json['employeeID'] as int,
      returnDate: _parseRequiredDateTime(json['returnDate'] as String?),
      status: ReturnOrderStatusExtension.fromDbValue(json['status'] as String?),
      adminActionDate:
          _parseOptionalDateTime(json['adminActionDate'] as String?),
      notes: json['notes'] as String?,
      createdDate: _parseRequiredDateTime(json['createdDate'] as String?),
      adminID: json['adminID'] as int?,
      supplierID: json['supplierID'] as int,
      supplierName: fetchedSupplierName,
      employeeName: fetchedEmployeeName,
      adminName: fetchedAdminName,
      items: parsedItems,
    );
  }

  // For inserting a new Return Order
  Map<String, dynamic> toJsonForInsert() {
    return {
      'purchaseOrderID': purchaseOrderID,
      'employeeID': employeeID,
      // 'returnDate' often defaults in DB or can be set here
      'status': status.dbValue, // Initial status
      'notes': notes,
      'supplierID': supplierID,
      // adminID and adminActionDate are usually null on insert
    };
  }

  // For updating an existing Return Order (e.g., status, notes)
  Map<String, dynamic> toJsonForUpdate() {
    final map = <String, dynamic>{
      'status': status.dbValue,
      // 'updatedDate': DateTime.now().toUtc().toIso8601String(), // DB can handle this with trigger
    };
    if (adminID != null) map['adminID'] = adminID;
    if (adminActionDate != null) {
      map['adminActionDate'] = adminActionDate!.toUtc().toIso8601String();
    }
    if (notes != null) map['notes'] = notes;
    // Other fields typically not updated this way (e.g., PO ID, creator)
    return map;
  }

  ReturnOrderData copyWith({
    int? returnOrderID,
    int? purchaseOrderID,
    int? employeeID,
    DateTime? returnDate,
    ReturnOrderStatus? status,
    DateTime? adminActionDate,
    String? notes,
    DateTime? createdDate,
    int? adminID,
    int? supplierID,
    String? supplierName,
    String? employeeName,
    String? adminName,
    List<ReturnOrderItemData>? items,
  }) {
    return ReturnOrderData(
      returnOrderID: returnOrderID ?? this.returnOrderID,
      purchaseOrderID: purchaseOrderID ?? this.purchaseOrderID,
      employeeID: employeeID ?? this.employeeID,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      adminActionDate: adminActionDate ?? this.adminActionDate,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      adminID: adminID ?? this.adminID,
      supplierID: supplierID ?? this.supplierID,
      supplierName: supplierName ?? this.supplierName,
      employeeName: employeeName ?? this.employeeName,
      adminName: adminName ?? this.adminName,
      items: items ?? this.items,
    );
  }
}
