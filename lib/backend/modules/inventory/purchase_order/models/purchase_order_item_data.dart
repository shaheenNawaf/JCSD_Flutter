import 'package:flutter/foundation.dart';

@immutable
class PurchaseOrderItemData {
  final int? purchaseItemID; // Nullable for new items before insert
  final int purchaseOrderID;
  final String prodDefID; // UUID as String
  final int quantityOrdered;
  final int quantityReceived;
  final double unitCostPrice;
  final double lineTotalCost;
  final DateTime? createdAt; // From your SQL schema for purchase_order_items
  final DateTime? updatedAt; // From your SQL schema for purchase_order_items

  const PurchaseOrderItemData({
    this.purchaseItemID,
    required this.purchaseOrderID,
    required this.prodDefID,
    required this.quantityOrdered,
    this.quantityReceived = 0,
    required this.unitCostPrice,
    required this.lineTotalCost,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrderItemData.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptionalDateTime(String? dateString) {
      return dateString != null ? DateTime.tryParse(dateString) : null;
    }

    double? parseOptionalDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return PurchaseOrderItemData(
      purchaseItemID: json['purchaseItemID'] as int?,
      purchaseOrderID: json['purchaseOrderID'] as int,
      prodDefID: json['prodDefID'] as String,
      quantityOrdered: json['quantityOrdered'] as int,
      quantityReceived: json['quantityReceived'] as int? ?? 0,
      unitCostPrice: parseOptionalDouble(json['unitCostPrice']) ?? 0.0,
      lineTotalCost: parseOptionalDouble(json['lineTotalCost']) ?? 0.0,
      createdAt: parseOptionalDateTime(json['createdAt'] as String?),
      updatedAt: parseOptionalDateTime(json['updatedAt'] as String?),
    );
  }

  Map<String, dynamic> toJsonForInsert() {
    // For inserting new line items
    return {
      'purchaseOrderID': purchaseOrderID,
      'prodDefID': prodDefID,
      'quantityOrdered': quantityOrdered,
      'quantityReceived': quantityReceived, // Usually 0 on insert
      'unitCostPrice': unitCostPrice,
      'lineTotalCost': lineTotalCost,
    };
  }

  Map<String, dynamic> toJsonForUpdate() {
    return {
      'quantityOrdered': quantityOrdered,
      'quantityReceived': quantityReceived,
      'unitCostPrice': unitCostPrice,
      'lineTotalCost': lineTotalCost,
    };
  }

  PurchaseOrderItemData copyWith({
    int? purchaseItemID,
    int? purchaseOrderID,
    String? prodDefID,
    int? quantityOrdered,
    int? quantityReceived,
    double? unitCostPrice,
    double? lineTotalCost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderItemData(
      purchaseItemID: purchaseItemID ?? this.purchaseItemID,
      purchaseOrderID: purchaseOrderID ?? this.purchaseOrderID,
      prodDefID: prodDefID ?? this.prodDefID,
      quantityOrdered: quantityOrdered ?? this.quantityOrdered,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      unitCostPrice: unitCostPrice ?? this.unitCostPrice,
      lineTotalCost: lineTotalCost ?? this.lineTotalCost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
