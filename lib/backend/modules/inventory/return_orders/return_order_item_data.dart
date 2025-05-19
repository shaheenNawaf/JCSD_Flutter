import 'package:jcsd_flutter/backend/modules/inventory/product_definitions/prod_def_data.dart';
import 'package:jcsd_flutter/backend/modules/inventory/return_orders/return_order_item_status.dart';
import 'package:jcsd_flutter/backend/modules/inventory/serialized_items/serialized_item.dart';

class ReturnOrderItemData {
  final int? id;
  final DateTime? createdAt;
  final int returnOrderId;
  final int productDefinitionId;
  final String returnedSerialId;
  final String? reasonForReturn;
  final int? replacementSerialId;
  ReturnOrderItemStatus itemStatus;

  final SerializedItem? returnedSerialItem;
  final SerializedItem? replacementSerialItem;
  final ProductDefinitionData? productDefinition;

  ReturnOrderItemData({
    this.id,
    this.createdAt,
    required this.returnOrderId,
    required this.productDefinitionId,
    required this.returnedSerialId,
    this.reasonForReturn,
    this.replacementSerialId,
    required this.itemStatus,
    this.returnedSerialItem,
    this.replacementSerialItem,
    this.productDefinition,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      // 'created_at' usually handled by Supabase
      'return_order_id': returnOrderId,
      'product_definition_id': productDefinitionId,
      'returned_serial_id': returnedSerialId,
      if (reasonForReturn != null && reasonForReturn!.isNotEmpty)
        'reason_for_return': reasonForReturn,
      if (replacementSerialId != null)
        'replacement_serial_id': replacementSerialId,
      'item_status': itemStatus.name,
    };
  }

  factory ReturnOrderItemData.fromJson(Map<String, dynamic> map) {
    return ReturnOrderItemData(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      returnOrderId: map['return_order_id'] as int,
      productDefinitionId: map['product_definition_id'] as int,
      returnedSerialId: map['returned_serial_id'],
      reasonForReturn: map['reason_for_return'] as String?,
      replacementSerialId: map['replacement_serial_id'] as int?,
      itemStatus:
          ReturnOrderItemStatus.fromString(map['item_status'] as String?),
      returnedSerialItem: map['returned_serialized_items'] !=
              null // Name of relation in Supabase if you select it
          ? SerializedItem.fromJson(
              map['returned_serialized_items'] as Map<String, dynamic>)
          : null,
      replacementSerialItem:
          map['replacement_serialized_items'] != null // Name of relation
              ? SerializedItem.fromJson(
                  map['replacement_serialized_items'] as Map<String, dynamic>)
              : null,
      productDefinition: map['product_definitions'] != null // Name of relation
          ? ProductDefinitionData.fromJson(
              map['product_definitions'] as Map<String, dynamic>)
          : null,
    );
  }

  ReturnOrderItemData copyWith({
    int? id,
    DateTime? createdAt,
    int? returnOrderId,
    int? productDefinitionId,
    String? returnedSerialId,
    String? reasonForReturn,
    int? replacementSerialId,
    ReturnOrderItemStatus? itemStatus,
    SerializedItem? returnedSerialItem,
    SerializedItem? replacementSerialItem,
    ProductDefinitionData? productDefinition,
  }) {
    return ReturnOrderItemData(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      returnOrderId: returnOrderId ?? this.returnOrderId,
      productDefinitionId: productDefinitionId ?? this.productDefinitionId,
      returnedSerialId: returnedSerialId ?? this.returnedSerialId,
      reasonForReturn: reasonForReturn ?? this.reasonForReturn,
      replacementSerialId: replacementSerialId ?? this.replacementSerialId,
      itemStatus: itemStatus ?? this.itemStatus,
      returnedSerialItem: returnedSerialItem ?? this.returnedSerialItem,
      replacementSerialItem:
          replacementSerialItem ?? this.replacementSerialItem,
      productDefinition: productDefinition ?? this.productDefinition,
    );
  }
}
