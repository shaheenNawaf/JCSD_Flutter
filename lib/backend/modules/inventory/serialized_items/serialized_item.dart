class SerializedItem {
  final String serialNumber;
  final int itemID;
  final DateTime? purchaseDate;
  final int? employeeID;
  final int supplierID;
  final DateTime createdDate;
  final DateTime? updateDate;
  final double? costPrice;
  final String? notes;
  final String status;
  final int? currentBookingID;
  final bool isVisible;

  SerializedItem({
    required this.serialNumber,
    required this.itemID,
    this.purchaseDate,
    this.employeeID,
    required this.supplierID,
    required this.createdDate,
    this.updateDate,
    this.costPrice,
    this.notes,
    required this.status,
    this.currentBookingID,
    required this.isVisible
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
      serialNumber: json['serialNumber'] as String, // Ensure this matches DB type
      itemID: json['itemID'],
      purchaseDate: parseOptionalDateTime(json['purchaseDate']),
      employeeID: json['employeeID'] as int?,
      supplierID: json['supplierID'] as int,
      createdDate: json['createdDate'],
      updateDate: parseOptionalDateTime(json['updateDate']),
      costPrice: parseOptionalDouble(json['costPrice']),
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'Available', // Provide default if status could be null
      currentBookingID: json['current_booking_id'] as int?,
      isVisible: json['isVisible'] as bool? ?? true,
    );
  }

   // toJson (only include fields you'd typically insert/update)
   Map<String, dynamic> toJson() {
     return {
       'serialNumber': serialNumber, // Usually needed for inserts/updates
       'itemID': itemID,
       'purchaseDate': purchaseDate?.toIso8601String(),
       'employeeID': employeeID,
       'supplierID': supplierID,
       'costPrice': costPrice,
       'notes': notes,
       'status': status,
       'current_booking_id': currentBookingID,
       'isVisible': isVisible,
     };
   }

   // copyWith method for immutable updates
  SerializedItem copyWith({
    String? serialNumber,
    int? itemID,
    DateTime? purchaseDate,
    int? userID,
    int? supplierID,
    DateTime? createdDate,
    DateTime? updateDate,
    double? itemPrice,
    String? notes,
    String? status,
    int? currentBookingID,
    bool? isVisible,
  }) {
    return SerializedItem(
      serialNumber: serialNumber ?? this.serialNumber,
      itemID: itemID ?? this.itemID,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      employeeID: userID ?? this.employeeID,
      supplierID: supplierID ?? this.supplierID,
      createdDate: createdDate ?? this.createdDate,
      updateDate: updateDate ?? this.updateDate,
      itemPrice: itemPrice ?? this.itemPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      currentBookingID: currentBookingID ?? this.currentBookingID,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}