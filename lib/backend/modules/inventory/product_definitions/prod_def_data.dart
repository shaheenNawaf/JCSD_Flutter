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
  final int? desiredStockLevel;
  final int? serialsCount;
  final int? preferredSupplierID;

  ProductDefinitionData({
    this.prodDefID,
    required this.prodDefName,
    this.prodDefDescription,
    required this.manufacturerName,
    this.createDate,
    this.updateDate,
    this.prodDefMSRP,
    required this.isVisible,
    required this.itemTypeID,
    this.desiredStockLevel,
    this.serialsCount,
    this.preferredSupplierID,
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

    int? parseSerialsCount(dynamic countData) {
      if (countData is List && countData.isNotEmpty) {
        final firstElement = countData.first;
        if (firstElement is Map<String, dynamic> &&
            firstElement.containsKey('count')) {
          return firstElement['count'] as int?;
        }
      }
      print(
          'Either failed to fetch data or no serials under it. Defaulting to 0');
      return 0;
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
      itemTypeID: json['itemTypeID'],
      desiredStockLevel: json['desiredStockLevel'] as int?,
      serialsCount: parseSerialsCount(json['item_serials']),
      preferredSupplierID: json['preferredSupplierID'] as int?,
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
      'desiredStockLevel': desiredStockLevel,
      'preferredSupplierID': preferredSupplierID,
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
    int? desiredStockLevel,
    int? serialsCount,
    int? preferredSupplierID,
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
      desiredStockLevel: desiredStockLevel ?? this.desiredStockLevel,
      serialsCount: serialsCount ?? this.serialsCount,
      preferredSupplierID: preferredSupplierID ?? this.preferredSupplierID,
    );
  }
}
