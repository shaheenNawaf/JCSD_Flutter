// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:jcsd_flutter/backend/modules/inventory/purchase_order/models/purchase_order_item_data.dart';

enum PurchaseOrderStatus {
  Draft,
  PendingApproval,
  Approved,
  Revised,
  Cancelled,
  PartiallyReceived,
  Received,
  Unknown
}

extension PurchaseOrderStatusExtension on PurchaseOrderStatus {
  String get dbValue {
    return this.toString().split('.').last;
  }

  static PurchaseOrderStatus fromDbValue(String? statusString) {
    if (statusString == null) return PurchaseOrderStatus.Unknown;
    for (var status in PurchaseOrderStatus.values) {
      if (status.dbValue == statusString) {
        return status;
      }
    }
    print(
        "Warning: Unknown PurchaseOrderStatus string received: $statusString");
    return PurchaseOrderStatus.Unknown;
  }
}

@immutable
class PurchaseOrderData {
  final int poId;
  final int supplierID;
  final String? supplierName;
  final int createdByEmployee;
  final int? approvedByAdmin;
  final PurchaseOrderStatus status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final double? totalEstimatedCost;
  final String? note;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int? defaultSupplierID;
  final int? defaultReorderQuantity;
  final List<PurchaseOrderItemData>? items;

  const PurchaseOrderData({
    required this.poId,
    required this.supplierID,
    this.supplierName,
    required this.createdByEmployee,
    this.approvedByAdmin,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.totalEstimatedCost,
    this.note,
    required this.createdDate,
    required this.updatedDate,
    this.defaultSupplierID,
    this.defaultReorderQuantity,
    this.items,
  });

  factory PurchaseOrderData.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptionalDateTime(String? dateString) {
      return dateString != null ? DateTime.tryParse(dateString) : null;
    }

    DateTime parseRequiredDateTime(String? dateString) {
      if (dateString == null) {
        print(
            'Warning: Received null for non-nullable date column, using fallback.');
        return DateTime.now();
      }
      return DateTime.parse(dateString);
    }

    double? parseOptionalDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseOptionalInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    List<PurchaseOrderItemData>? parsedItems;
    if (json['purchase_order_items'] != null &&
        json['purchase_order_items'] is List) {
      parsedItems = (json['purchase_order_items'] as List)
          .map((itemJson) =>
              PurchaseOrderItemData.fromJson(itemJson as Map<String, dynamic>))
          .toList();
    }

    String? fetchedSupplierName;
    if (json['suppliers'] != null && json['suppliers'] is Map) {
      fetchedSupplierName = json['suppliers']['supplierName'] as String?;
    }

    return PurchaseOrderData(
      poId: json['po_id'] as int,
      supplierID: json['supplierID'] as int,
      supplierName: fetchedSupplierName,
      createdByEmployee: json['createdByEmployee'] as int,
      approvedByAdmin: json['approvedByAdmin'] as int?,
      status:
          PurchaseOrderStatusExtension.fromDbValue(json['status'] as String?),
      orderDate: parseRequiredDateTime(json['orderDate'] as String?),
      expectedDeliveryDate:
          parseOptionalDateTime(json['expectedDeliveryDate'] as String?),
      totalEstimatedCost: parseOptionalDouble(json['totalEstimatedCost']),
      note: json['note'] as String?,
      createdDate: parseRequiredDateTime(json['createdDate'] as String?),
      updatedDate: parseRequiredDateTime(json['updatedDate'] as String?),
      defaultSupplierID: parseOptionalInt(json['defaultSupplierID']),
      defaultReorderQuantity: parseOptionalInt(json['defaultReorderQuantity']),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'supplierID': supplierID,
      'createdByEmployee': createdByEmployee,
      'status': status.dbValue,
      'orderDate': orderDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'totalEstimatedCost': totalEstimatedCost,
      'note': note,
      'defaultSupplierID': defaultSupplierID,
      'defaultReorderQuantity': defaultReorderQuantity,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    final map = <String, dynamic>{
      'status': status.dbValue,
    };
    if (supplierID != 0) {
      map['supplierID'] = supplierID;
    }
    if (approvedByAdmin != null) map['approvedByAdmin'] = approvedByAdmin;
    if (orderDate != DateTime(0)) {
      map['orderDate'] = orderDate.toUtc().toIso8601String();
    }
    if (expectedDeliveryDate != null) {
      map['expectedDeliveryDate'] =
          expectedDeliveryDate!.toUtc().toIso8601String();
    }
    if (totalEstimatedCost != null) {
      map['totalEstimatedCost'] = totalEstimatedCost;
    }
    if (note != null) map['note'] = note;
    if (defaultSupplierID != null) map['defaultSupplierID'] = defaultSupplierID;
    if (defaultReorderQuantity != null) {
      map['defaultReorderQuantity'] = defaultReorderQuantity;
    }
    return map;
  }

  PurchaseOrderData copyWith({
    int? poId,
    int? supplierID,
    String? supplierName,
    int? createdByEmployee,
    int? approvedByAdmin,
    PurchaseOrderStatus? status,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    double? totalEstimatedCost,
    String? note,
    DateTime? createdDate,
    DateTime? updatedDate,
    int? defaultSupplierID,
    int? defaultReorderQuantity,
    List<PurchaseOrderItemData>? items,
  }) {
    return PurchaseOrderData(
      poId: poId ?? this.poId,
      supplierID: supplierID ?? this.supplierID,
      supplierName: supplierName ?? this.supplierName,
      createdByEmployee: createdByEmployee ?? this.createdByEmployee,
      approvedByAdmin: approvedByAdmin ?? this.approvedByAdmin,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      note: note ?? this.note,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      defaultSupplierID: defaultSupplierID ?? this.defaultSupplierID,
      defaultReorderQuantity:
          defaultReorderQuantity ?? this.defaultReorderQuantity,
      items: items ?? this.items,
    );
  }
}
