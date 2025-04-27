class ProductDefinitionData {
  final int profDefID;
  final String profDefName;
  final String? profDefDescription;
  final int? manufacturerID;
  final DateTime createDate;
  final DateTime? updateDate;
  final double? profDefMSRP;
  final bool isVisible;
  final int itemTypeID;

    ProductDefinitionData({
      required this.profDefID,
      required this.profDefName,
      this.profDefDescription,
      this.manufacturerID,
      required this.createDate,
      this.updateDate,
      this.profDefMSRP,
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
      profDefID: json['profDefID'],
      profDefName: json['profDefName'] as String,
      profDefDescription: json['profDefDescription'] as String?,
      manufacturerID: json['manufacturerID'] as int?, 
      createDate: json['createDate'],
      updateDate: parseOptionalDateTime(json['updateDate']),
      profDefMSRP: parseOptionalDouble(json['profDefMSRP']),
      isVisible: json['isVisible'] as bool,
      itemTypeID: json['itemTypeID']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profDefName': profDefName,
      'profDefDescription': profDefDescription,
      'manufacturerID': manufacturerID,
      'profDefMSRP': profDefMSRP,
      'isVisible': isVisible,
      'itemTypeID': itemTypeID,
    };
  }

  //Specifically used for the state handling
  ProductDefinitionData copyWith({
    int? profDefID,
    String? profDefName,
    String? profDefDescription,
    int? manufacturerID,
    DateTime? createDate,
    DateTime? updateDate,
    double? profDefMSRP,
    bool? isVisible,
    int? itemTypeID,
  }) {
    return ProductDefinitionData(
      profDefID: profDefID ?? this.profDefID,
      profDefName: profDefName ?? this.profDefName,
      profDefDescription: profDefDescription ?? this.profDefDescription,
      manufacturerID: manufacturerID ?? this.manufacturerID,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      profDefMSRP: profDefMSRP ?? this.profDefMSRP,
      isVisible: isVisible ?? this.isVisible,
      itemTypeID: itemTypeID ?? this.itemTypeID,
    );
  }

}