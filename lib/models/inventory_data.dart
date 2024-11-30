class InventoryData {
  final int itemID;
  final int supplierID;
  final String itemName;
  final int itemTypeID;
  final String itemDescription;
  final int itemQuantity;
  final double itemPrice;
  final bool isVisible;

  //Ensuring that every time this is referenced, there is complete data
  InventoryData({
    required this.itemID,
    required this.supplierID, 
    required this.itemName,
    required this.itemTypeID,
    required this.itemDescription,
    required this.itemQuantity,
    required this.itemPrice,
    required this.isVisible,
  });

  //JSON to Inventory classitem
  factory InventoryData.fromJson(Map<String, dynamic> json) {
    return InventoryData(
      itemID: json['itemID'], 
      supplierID: json['supplierID'], 
      itemName: json['itemName'] as String, 
      itemTypeID: json['itemTypeID'], 
      itemDescription: json['itemDescription'] as String, 
      itemQuantity: json['itemQuantity'], 
      itemPrice: json['itemPrice'], 
      isVisible: json['isVisible'],
    );
  }

  //Data as JSON, for pushing to DB
  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'supplierID': supplierID,
      'itemName': itemName,
      'itemTypeID': itemTypeID,
      'itemDescription': itemDescription,
      'itemQuantity': itemQuantity,
      'itemPrice': itemPrice,
      'isVisible': isVisible,
    };
  }
}