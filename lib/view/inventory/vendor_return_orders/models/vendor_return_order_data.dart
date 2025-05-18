import 'package:flutter/foundation.dart';
import 'package:jcsd_flutter/view/inventory/vendor_return_orders/models/vendor_return_order_item_data.dart'; // For listEquals

class VendorReturnOrder {
  final int vroID;
  final String vroNumber;
  final int supplierID;
  final int originalPoID;
  final String status;
  final bool isReplacementExpected;
  final DateTime returnInitiationDate;
  final DateTime? defectiveItemsShippedDate;
  final String? trackingNumberToVendor;
  final DateTime? replacementExpectedDate;
  final String? notes;
  final int createdByEmployeeID;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VendorReturnOrderItem>? items; // For nested fetching of items

  VendorReturnOrder({
    required this.vroID,
    required this.vroNumber,
    required this.supplierID,
    required this.originalPoID,
    required this.status,
    required this.isReplacementExpected,
    required this.returnInitiationDate,
    this.defectiveItemsShippedDate,
    this.trackingNumberToVendor,
    this.replacementExpectedDate,
    this.notes,
    required this.createdByEmployeeID,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'vroID': vroID,
      'vroNumber': vroNumber,
      'supplierID': supplierID,
      'originalPoID': originalPoID,
      'status': status,
      'isReplacementExpected': isReplacementExpected,
      'returnInitiationDate': returnInitiationDate.toIso8601String(),
      'defectiveItemsShippedDate': defectiveItemsShippedDate?.toIso8601String(),
      'trackingNumberToVendor': trackingNumberToVendor,
      'replacementExpectedDate': replacementExpectedDate?.toIso8601String(),
      'notes': notes,
      'createdByEmployeeID': createdByEmployeeID,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // items are typically not sent back in a simple VRO update,
      // they are managed via their own endpoint or as part of a complex transaction.
      // So, not including 'items' in toJson by default.
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'vroNumber': vroNumber,
      'supplierID': supplierID,
      'originalPoID': originalPoID,
      'status': status,
      'isReplacementExpected': isReplacementExpected,
      'returnInitiationDate': returnInitiationDate.toIso8601String(),
      'defectiveItemsShippedDate': defectiveItemsShippedDate?.toIso8601String(),
      'trackingNumberToVendor': trackingNumberToVendor,
      'replacementExpectedDate': replacementExpectedDate?.toIso8601String(),
      'notes': notes,
      'createdByEmployeeID': createdByEmployeeID,
    };
  }

  factory VendorReturnOrder.fromJson(Map<String, dynamic> json) {
    return VendorReturnOrder(
      vroID: json['vroID'] as int,
      vroNumber: json['vroNumber'] as String,
      supplierID: json['supplierID'] as int,
      originalPoID: json['originalPoID'] as int,
      status: json['status'] as String,
      isReplacementExpected: json['isReplacementExpected'] as bool,
      returnInitiationDate:
          DateTime.parse(json['returnInitiationDate'] as String),
      defectiveItemsShippedDate: json['defectiveItemsShippedDate'] == null
          ? null
          : DateTime.parse(json['defectiveItemsShippedDate'] as String),
      trackingNumberToVendor: json['trackingNumberToVendor'] as String?,
      replacementExpectedDate: json['replacementExpectedDate'] == null
          ? null
          : DateTime.parse(json['replacementExpectedDate'] as String),
      notes: json['notes'] as String?,
      createdByEmployeeID: json['createdByEmployeeID'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: json['vendor_return_order_items'] != null &&
              json['vendor_return_order_items'] is List
          ? List<VendorReturnOrderItem>.from(
              (json['vendor_return_order_items'] as List<dynamic>).map(
                (itemJson) => VendorReturnOrderItem.fromJson(
                    itemJson as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }

  VendorReturnOrder copyWith({
    int? vroID,
    String? vroNumber,
    int? supplierID,
    int? originalPoID,
    String? status,
    bool? isReplacementExpected,
    DateTime? returnInitiationDate,
    DateTime? defectiveItemsShippedDate,
    String? trackingNumberToVendor,
    DateTime? replacementExpectedDate,
    String? notes,
    int? createdByEmployeeID,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<VendorReturnOrderItem>? items,
  }) {
    return VendorReturnOrder(
      vroID: vroID ?? this.vroID,
      vroNumber: vroNumber ?? this.vroNumber,
      supplierID: supplierID ?? this.supplierID,
      originalPoID: originalPoID ?? this.originalPoID,
      status: status ?? this.status,
      isReplacementExpected:
          isReplacementExpected ?? this.isReplacementExpected,
      returnInitiationDate: returnInitiationDate ?? this.returnInitiationDate,
      defectiveItemsShippedDate:
          defectiveItemsShippedDate ?? this.defectiveItemsShippedDate,
      trackingNumberToVendor:
          trackingNumberToVendor ?? this.trackingNumberToVendor,
      replacementExpectedDate:
          replacementExpectedDate ?? this.replacementExpectedDate,
      notes: notes ?? this.notes,
      createdByEmployeeID: createdByEmployeeID ?? this.createdByEmployeeID,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorReturnOrder &&
        other.vroID == vroID &&
        other.vroNumber == vroNumber &&
        other.supplierID == supplierID &&
        other.originalPoID == originalPoID &&
        other.status == status &&
        other.isReplacementExpected == isReplacementExpected &&
        other.returnInitiationDate == returnInitiationDate &&
        other.defectiveItemsShippedDate == defectiveItemsShippedDate &&
        other.trackingNumberToVendor == trackingNumberToVendor &&
        other.replacementExpectedDate == replacementExpectedDate &&
        other.notes == notes &&
        other.createdByEmployeeID == createdByEmployeeID &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode {
    return Object.hash(
      vroID,
      vroNumber,
      supplierID,
      originalPoID,
      status,
      isReplacementExpected,
      returnInitiationDate,
      defectiveItemsShippedDate,
      trackingNumberToVendor,
      replacementExpectedDate,
      notes,
      createdByEmployeeID,
      createdAt,
      updatedAt,
      Object.hashAll(items ?? []),
    );
  }
}
