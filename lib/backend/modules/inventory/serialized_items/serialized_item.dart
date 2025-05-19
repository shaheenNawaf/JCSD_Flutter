class SerializedItem {
  final String serialNumber;
  final String prodDefID;
  final DateTime? purchaseDate;
  final int? employeeID;
  final int supplierID;
  final DateTime? createdDate;
  final DateTime? updateDate;
  final double? costPrice;
  final String? notes;
  final String status;
  final int? bookingID;
  final int? purchaseOrderID;

  SerializedItem({
    required this.serialNumber,
    required this.prodDefID,
    this.purchaseDate,
    this.employeeID,
    required this.supplierID,
    this.createdDate,
    this.updateDate,
    this.costPrice,
    this.notes,
    required this.status,
    this.bookingID,
    this.purchaseOrderID,
  });

  // Factory constructor for parsing JSON from Supabase
  factory SerializedItem.fromJson(Map<String, dynamic> json) {
    // Helper for safe date parsing
    DateTime? parseOptionalDateTime(String? dateString) {
      return dateString != null ? DateTime.tryParse(dateString) : null;
    }

    // Helper for safe double parsing from numeric/decimal/float
    double? parseOptionalDouble(dynamic priceValue) {
      if (priceValue == null) return null;
      if (priceValue is double) return priceValue;
      if (priceValue is int) return priceValue.toDouble();
      if (priceValue is String) return double.tryParse(priceValue);
      return null;
    }

    return SerializedItem(
        serialNumber:
            json['serialNumber'] as String, // Ensure this matches DB type
        prodDefID: json['prodDefID'],
        purchaseDate: parseOptionalDateTime(json['purchaseDate']),
        employeeID: json['employeeID'] as int?,
        supplierID: json['supplierID'] as int,
        createdDate: json['createdDate'],
        updateDate: parseOptionalDateTime(json['updateDate']),
        costPrice: parseOptionalDouble(json['costPrice']),
        notes: json['notes'] as String?,
        status: json['status'] as String? ??
            'Available', // Provide default if status could be null
        bookingID: json['bookingID'] as int?,
        purchaseOrderID: json['purchaseOrderID']);
  }

  // toJson (only include fields you'd typically insert/update)
  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber, // Usually needed for inserts/updates
      'prodDefID': prodDefID,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'employeeID': employeeID,
      'supplierID': supplierID,
      'costPrice': costPrice,
      'notes': notes,
      'status': status,
      'bookingID': bookingID,
      'purchaseOrderID': purchaseOrderID,
    };
  }

  // copyWith method for immutable updates
  SerializedItem copyWith({
    String? serialNumber,
    String? prodDefID,
    DateTime? purchaseDate,
    int? employeeID,
    int? supplierID,
    DateTime? createdDate,
    DateTime? updateDate,
    double? costPrice,
    String? notes,
    String? status,
    int? bookingID,
    int? purchaseOrderID,
    bool? isVisible,
  }) {
    return SerializedItem(
      serialNumber: serialNumber ?? this.serialNumber,
      prodDefID: prodDefID ?? this.prodDefID,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      employeeID: employeeID ?? this.employeeID,
      supplierID: supplierID ?? this.supplierID,
      createdDate: createdDate ?? this.createdDate,
      updateDate: updateDate ?? this.updateDate,
      costPrice: costPrice ?? this.costPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      bookingID: bookingID ?? this.bookingID,
    );
  }
}
