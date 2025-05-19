class ServicesData {
  final int serviceID;
  final String serviceName;
  final bool isActive;
  final double? maxPrice;
  final String? description;
  final int? estimatedDuration;
  final bool isWalkInOnly;
  final bool requiresAddress;
  final DateTime? createDate;
  final DateTime? updateDate;

  ServicesData({
    required this.serviceID,
    required this.serviceName,
    required this.isActive,
    this.maxPrice,
    this.description,
    this.estimatedDuration,
    required this.isWalkInOnly,
    required this.requiresAddress,
    this.createDate,
    this.updateDate,
  });

  static double? _parseOptionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    print(
        "Warning: Could not parse double from value: $value (Type: ${value.runtimeType})");
    return null;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    print(
        "Warning: Could not parse int from value: $value (Type: ${value.runtimeType})");
    return null;
  }

  static DateTime? _parseOptionalDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    return DateTime.tryParse(dateString);
  }

  factory ServicesData.fromJson(Map<String, dynamic> json) {
    if (json['serviceID'] == null ||
        json['serviceName'] == null ||
        json['isActive'] == null) {
      print(
          "Warning: Missing required field(s) in ServicesData JSON: $json. Service will not be created.");
      throw FormatException(
          "Missing required fields (serviceID, serviceName, or isActive) in service JSON: $json");
    }

    return ServicesData(
      serviceID: json['serviceID'] as int,
      serviceName: json['serviceName'] as String,
      isActive: json['isActive'] as bool,
      maxPrice: _parseOptionalDouble(json['maxPrice']),
      description: json['description'] as String?,
      estimatedDuration: _parseOptionalInt(json['estimatedDuration']),
      isWalkInOnly: json['isWalkInOnly'] as bool? ?? false,
      requiresAddress: json['requiresAddress'] as bool? ?? false,
      createDate: _parseOptionalDateTime(json['createDate'] as String?),
      updateDate: _parseOptionalDateTime(json['updateDate'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'isActive': isActive,
      'maxPrice': maxPrice,
      'description': description,
      'estimatedDuration': estimatedDuration,
      'isWalkInOnly': isWalkInOnly,
      'requiresAddress': requiresAddress,
    };
  }
}
