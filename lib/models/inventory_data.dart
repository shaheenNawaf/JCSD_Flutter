import 'dart:ffi';

class InventoryData {
  final String itemID;
  final String supplierID;
  final String itemName;
  final String itemType;
  final String itemDescription;
  final String itemQuantity;
  final String itemPrice;
  final bool isHidden;

  //Ensuring that every time this is referenced, there is complete data
  InventoryData({
    required this.itemID,
    required this.supplierID,
    required this.itemName,
    required this.itemType,
    required this.itemDescription,
    required this.itemQuantity,
    required this.itemPrice,
    required this.isHidden,
  });

  //JSON to Inventory classitem
  factory InventoryData.fromJson(Map<String, dynamic> json) {
    return InventoryData(
      itemID: json['itemID'] as String, 
      supplierID: json['supplierID'] as String, 
      itemName: json['itemName'] as String, 
      itemType: json['itemType'] as String, 
      itemDescription: json['itemDescription'] as String, 
      itemQuantity: json['itemQuantity'] as String, 
      itemPrice: json['itemPrice'] as String, 
      isHidden: json['isHidden'],
    );
  }

  //Returning the data to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID as Int,
      'supplierID': supplierID as Int,
      'itemName': itemName,
      'itemType': itemType,
      'itemDescription': itemDescription,
      'itemQuantity': itemQuantity as Int,
      'itemPrice': itemPrice as Float,
      'isHidden': isHidden,
    };
  }
}