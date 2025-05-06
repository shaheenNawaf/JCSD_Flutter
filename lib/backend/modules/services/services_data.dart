class ServicesData {
  final int serviceID;
  final String serviceName;
  final bool isActive;
  final double? minPrice;
  final double? maxPrice;
  final String? description;
  final int? estimatedDuration;
  final bool isWalkInOnly;
  final bool requiresAddress;

  ServicesData({
    required this.serviceID,
    required this.serviceName,
    required this.isActive,
    this.minPrice,
    this.maxPrice,
    this.description,
    this.estimatedDuration,
    required this.isWalkInOnly,
    required this.requiresAddress,
  });

  static double _parseDefaultPrices(dynamic servicePrice) {
    if (servicePrice == null) {
      throw const FormatException(
          "Required price field received null: price_at_addition");
    }

    if (servicePrice is int) return servicePrice.toDouble();
    if (servicePrice is String) return double.parse(servicePrice);
    if (servicePrice is double) return servicePrice;
    throw FormatException(
        "Invalid Type received for ${servicePrice.runtimeType}");
  }

  static int _parseEstimatedDuration(dynamic serviceDuration) {
    if (serviceDuration == null) {
      throw const FormatException(
          "Required price field received null: price_at_addition");
    }

    if (serviceDuration is int) return serviceDuration;
    if (serviceDuration is String) return int.parse(serviceDuration);
    if (serviceDuration is double) return serviceDuration.toInt();

    throw FormatException(
        "Invalid Type received for ${serviceDuration.runtimeType}");
  }

  //fromJSON Method - Receive
  factory ServicesData.fromJson(Map<String, dynamic> json) {
    //Addign validation parses

    return ServicesData(
      serviceID: json['serviceID'],
      serviceName: json['serviceName'],
      isActive: json['isActive'],
      minPrice: _parseDefaultPrices(json['minPrice']),
      maxPrice: _parseDefaultPrices(json['maxPrice']),
      description: (json['description'].toString().isEmpty)
          ? json['description']
          : 'Empty description',
      estimatedDuration: _parseEstimatedDuration(json['estimatedDuration']),
      isWalkInOnly: json['isWalkInOnly'],
      requiresAddress: json['requiresAddress'],
    );
  }

  //toJSON - Return/Send to DB
  Map<String, dynamic> toJson() {
    return {
      'serviceID': serviceID,
      'serviceName': serviceName,
      'isActive': isActive,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'description': description,
      'estimatedDuration': estimatedDuration,
      'isWalkInOnly': isWalkInOnly,
      'requiresAddress': requiresAddress,
    };
  }

  // //For Handling State - only if needed
  // ServicesData copyWith({

  // })
}
