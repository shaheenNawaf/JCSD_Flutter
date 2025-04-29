class ProductDefinitionData {
  final String? prodDefID;
  final String prodDefName;
  final String? prodDefDescription;
  final String manufacturerName;
  final DateTime? createDate;
  final DateTime? updateDate;
  final double? prodDefMSRP;
  final bool isVisible;
  final int itemTypeID;

    ProductDefinitionData({
      this.prodDefID,
      required this.prodDefName,
      this.prodDefDescription,
      required this.manufacturerName,
      this.createDate,
      this.updateDate,
      this.prodDefMSRP,
      required this.isVisible,
      required this.itemTypeID
    });

    factory ProductDefinitionData.fromJson(Map<String, dynamic> json) {
    DateTime? parseOptionalDateTime(String? dateString) {
      return dateString != null ? DateTime.tryParse(dateString) : null;
      } 

     // Helper for safe double parsing from numeric/decimal/float
    double? parseOptionalDouble(dynamic priceValue) {
       if (priceValue == null) return null;
       if (priceValue is double) return priceValue;
       if (priceValue is int) return priceValue.toDouble();
       if (priceValue is String) return double.tryParse(priceValue);
       return null; // Or throw error / default value
    }

    return ProductDefinitionData(
      prodDefID: json['prodDefID'] as String,
      prodDefName: json['prodDefName'] as String,
      prodDefDescription: json['prodDefDescription'] as String?,
      manufacturerName: json['manufacturerName'] as String, 
      createDate: DateTime.tryParse(json['createDate']),
      updateDate: DateTime.tryParse(json['updateDate']),
      prodDefMSRP: parseOptionalDouble(json['prodDefMSRP']),
      isVisible: json['isVisible'] as bool,
      itemTypeID: json['itemTypeID']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prodDefName': prodDefName,
      'prodDefDescription': prodDefDescription,
      'manufacturerName': manufacturerName,
      'prodDefMSRP': prodDefMSRP,
      'isVisible': isVisible,
      'itemTypeID': itemTypeID,
    };
  }

  //Specifically used for the state handling
  ProductDefinitionData copyWith({
    String? prodDefID,
    String? prodDefName,
    String? prodDefDescription,
    String? manufacturerName,
    DateTime? createDate,
    DateTime? updateDate,
    double? prodDefMSRP,
    bool? isVisible,
    int? itemTypeID,
  }) {
    return ProductDefinitionData(
      prodDefID: prodDefID ?? this.prodDefID,
      prodDefName: prodDefName ?? this.prodDefName,
      prodDefDescription: prodDefDescription ?? this.prodDefDescription,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      prodDefMSRP: prodDefMSRP ?? this.prodDefMSRP,
      isVisible: isVisible ?? this.isVisible,
      itemTypeID: itemTypeID ?? this.itemTypeID,
    );
  }

}