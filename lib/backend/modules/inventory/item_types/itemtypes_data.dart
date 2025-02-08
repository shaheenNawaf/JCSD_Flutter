class ItemTypesData {
  final int itemTypeID;
  final String itemType;
  final String itemDescription;
  final bool isVisible;

  //Ensuring that every time this is referenced, there is complete data
  ItemTypesData({
    required this.itemTypeID,
    required this.itemType, 
    required this.itemDescription,
    required this.isVisible,
  });

  //JSON to Inventory classitem
  factory ItemTypesData.fromJson(Map<String, dynamic> json) {
    return ItemTypesData(
      itemTypeID: json['itemTypeID'], 
      itemType: json['itemType'], 
      itemDescription: json['description'], 
      isVisible: json['isVisible'],
    );
  }

  //Data as JSON, for pushing to DB
  Map<String, dynamic> toJson() {
    return {
      'itemTypeID': itemTypeID,
      'itemType': itemType,
      'description': itemDescription,
      'isVisible': isVisible,
    };
  }
}