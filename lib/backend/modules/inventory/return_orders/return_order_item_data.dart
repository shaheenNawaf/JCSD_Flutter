import 'package:flutter/foundation.dart';

@immutable
class ReturnOrderItemData {
  final int returnOrderItemID; // PK, generated
  final int returnOrderID; // FK
  // final String serialNumber; // FK - This seems redundant if returnedSerialID is the one being returned.
  // If `serialNumber` was meant to be the new replacement's SN, then `replacementSerialID` is better.
  // If it was meant to be the original item's SN before it was linked to a specific PO item,
  // then `returnedSerialID` is more specific.
  // I'll assume 'returnedSerialID' is the one being sent back for now.
  final String prodDefID; // FK (UUID)
  final DateTime createdDate; // Defaults to now()
  final String
      returnedSerialID; // FK to item_serials - THE ITEM BEING SENT BACK
  final String? reasonForReturn; // Nullable
  final String?
      replacementSerialID; // FK to item_serials - THE NEW ITEM RECEIVED (Nullable initially)
  final String
      itemStatus; // Status OF THIS RETURN ITEM (e.g. 'AwaitingReplacement', 'ReplacementReceived')

  // Optional: For display, fetched via joins if needed
  final String? productName;
  final String?
      originalSerialNumberDisplay; // same as returnedSerialID for clarity
  final String?
      replacementSerialNumberDisplay; // same as replacementSerialID for clarity

  const ReturnOrderItemData({
    required this.returnOrderItemID,
    required this.returnOrderID,
    // required this.serialNumber, // See comment above
    required this.prodDefID,
    required this.createdDate,
    required this.returnedSerialID,
    this.reasonForReturn,
    this.replacementSerialID,
    required this.itemStatus, // This status is for the line item itself in the return process
    this.productName,
    this.originalSerialNumberDisplay,
    this.replacementSerialNumberDisplay,
  });

  static DateTime _parseRequiredDateTime(String? dateString) {
    if (dateString == null) {
      print(
          'Warning: Required DateTime field received null in ReturnOrderItemData, using fallback.');
      return DateTime.now().toLocal();
    }
    return DateTime.parse(dateString).toLocal();
  }

  factory ReturnOrderItemData.fromJson(Map<String, dynamic> json) {
    // Example: If you join product_definitions to get productName for this item
    final String? fetchedProductName =
        json['product_definitions']?['prodDefName'] as String?;

    return ReturnOrderItemData(
      returnOrderItemID: json['returnOrderItemID'] as int,
      returnOrderID: json['returnOrderID'] as int,
      // serialNumber: json['serialNumber'] as String, // See comment above
      prodDefID: json['prodDefID'] as String, // UUIDs are strings in Dart
      createdDate: _parseRequiredDateTime(json['createdDate'] as String?),
      returnedSerialID: json['returnedSerialID'] as String,
      reasonForReturn: json['reasonForReturn'] as String?,
      replacementSerialID: json['replacementSerialID'] as String?,
      itemStatus:
          json['itemStatus'] as String, // Status of this particular return line
      productName: fetchedProductName,
      originalSerialNumberDisplay: json['returnedSerialID'] as String?,
      replacementSerialNumberDisplay: json['replacementSerialID'] as String?,
    );
  }

  // For inserting a new Return Order Item
  Map<String, dynamic> toJsonForInsert() {
    return {
      'returnOrderID': returnOrderID,
      // 'serialNumber': serialNumber, // See comment above
      'prodDefID': prodDefID,
      'returnedSerialID': returnedSerialID,
      'reasonForReturn': reasonForReturn,
      'itemStatus':
          itemStatus, // Initial status, e.g., 'PendingShipment' or 'AwaitingReplacement'
      // replacementSerialID is usually null on insert
    };
  }

  // For updating (e.g., when replacement_serialID is added)
  Map<String, dynamic> toJsonForUpdate() {
    final map = <String, dynamic>{
      'itemStatus': itemStatus,
      // 'updatedAt': DateTime.now().toUtc().toIso8601String(), // DB can handle this
    };
    if (replacementSerialID != null) {
      map['replacementSerialID'] = replacementSerialID;
    }
    if (reasonForReturn != null) map['reasonForReturn'] = reasonForReturn;
    // Other fields like prodDefID or returnedSerialID are usually not updated.
    return map;
  }

  ReturnOrderItemData copyWith({
    int? returnOrderItemID,
    int? returnOrderID,
    String? prodDefID,
    DateTime? createdDate,
    String? returnedSerialID,
    String? reasonForReturn,
    String? replacementSerialID,
    String? itemStatus,
    String? productName,
    String? originalSerialNumberDisplay,
    String? replacementSerialNumberDisplay,
  }) {
    return ReturnOrderItemData(
      returnOrderItemID: returnOrderItemID ?? this.returnOrderItemID,
      returnOrderID: returnOrderID ?? this.returnOrderID,
      prodDefID: prodDefID ?? this.prodDefID,
      createdDate: createdDate ?? this.createdDate,
      returnedSerialID: returnedSerialID ?? this.returnedSerialID,
      reasonForReturn: reasonForReturn ?? this.reasonForReturn,
      replacementSerialID: replacementSerialID ?? this.replacementSerialID,
      itemStatus: itemStatus ?? this.itemStatus,
      productName: productName ?? this.productName,
      originalSerialNumberDisplay:
          originalSerialNumberDisplay ?? this.originalSerialNumberDisplay,
      replacementSerialNumberDisplay:
          replacementSerialNumberDisplay ?? this.replacementSerialNumberDisplay,
    );
  }
}
