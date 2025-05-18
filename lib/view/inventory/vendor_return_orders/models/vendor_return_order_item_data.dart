class VendorReturnOrderItem {
  final int vroItemID;
  final int vroID;
  final String returnedSerialNumber;
  final String prodDefID;
  final String? rejectionReason;
  final double costAtTimeOfPurchase;
  final DateTime? replacementReceivedDate;
  final String? receivedReplacementSerialNumber;
  final String? notes;
  final DateTime createdAt;

  VendorReturnOrderItem({
    required this.vroItemID,
    required this.vroID,
    required this.returnedSerialNumber,
    required this.prodDefID,
    this.rejectionReason,
    required this.costAtTimeOfPurchase,
    this.replacementReceivedDate,
    this.receivedReplacementSerialNumber,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'vroItemID': vroItemID,
      'vroID': vroID,
      'returnedSerialNumber': returnedSerialNumber,
      'prodDefID': prodDefID,
      'rejectionReason': rejectionReason,
      'costAtTimeOfPurchase': costAtTimeOfPurchase,
      'replacementReceivedDate': replacementReceivedDate?.toIso8601String(),
      'receivedReplacementSerialNumber': receivedReplacementSerialNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJsonForInsert() {
    return {
      'vroID': vroID,
      'returnedSerialNumber': returnedSerialNumber,
      'prodDefID': prodDefID,
      'rejectionReason': rejectionReason,
      'costAtTimeOfPurchase': costAtTimeOfPurchase,
      'replacementReceivedDate': replacementReceivedDate?.toIso8601String(),
      'receivedReplacementSerialNumber': receivedReplacementSerialNumber,
      'notes': notes,
    };
  }

  factory VendorReturnOrderItem.fromJson(Map<String, dynamic> json) {
    return VendorReturnOrderItem(
      vroItemID: json['vroItemID'] as int,
      vroID: json['vroID'] as int,
      returnedSerialNumber: json['returnedSerialNumber'] as String,
      prodDefID: json['prodDefID'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      costAtTimeOfPurchase: (json['costAtTimeOfPurchase'] as num).toDouble(),
      replacementReceivedDate: json['replacementReceivedDate'] == null
          ? null
          : DateTime.parse(json['replacementReceivedDate'] as String),
      receivedReplacementSerialNumber:
          json['receivedReplacementSerialNumber'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  VendorReturnOrderItem copyWith({
    int? vroItemID,
    int? vroID,
    String? returnedSerialNumber,
    String? prodDefID,
    String? rejectionReason,
    double? costAtTimeOfPurchase,
    DateTime? replacementReceivedDate,
    String? receivedReplacementSerialNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return VendorReturnOrderItem(
      vroItemID: vroItemID ?? this.vroItemID,
      vroID: vroID ?? this.vroID,
      returnedSerialNumber: returnedSerialNumber ?? this.returnedSerialNumber,
      prodDefID: prodDefID ?? this.prodDefID,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      costAtTimeOfPurchase: costAtTimeOfPurchase ?? this.costAtTimeOfPurchase,
      replacementReceivedDate:
          replacementReceivedDate ?? this.replacementReceivedDate,
      receivedReplacementSerialNumber: receivedReplacementSerialNumber ??
          this.receivedReplacementSerialNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VendorReturnOrderItem &&
        other.vroItemID == vroItemID &&
        other.vroID == vroID &&
        other.returnedSerialNumber == returnedSerialNumber &&
        other.prodDefID == prodDefID &&
        other.rejectionReason == rejectionReason &&
        other.costAtTimeOfPurchase == costAtTimeOfPurchase &&
        other.replacementReceivedDate == replacementReceivedDate &&
        other.receivedReplacementSerialNumber ==
            receivedReplacementSerialNumber &&
        other.notes == notes &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      vroItemID,
      vroID,
      returnedSerialNumber,
      prodDefID,
      rejectionReason,
      costAtTimeOfPurchase,
      replacementReceivedDate,
      receivedReplacementSerialNumber,
      notes,
      createdAt,
    );
  }
}
