class ServicesData {
  final int serviceID;
  final String serviceName;
  final bool isActive;
  final double minPrice;
  final double maxPrice;

  ServicesData({
    required this.serviceID, 
    required this.serviceName, 
    required this.isActive, 
    required this.minPrice, 
    required this.maxPrice
  });

  //fromJSON Method - Receive
  factory ServicesData.fromJson(Map<String, dynamic> json){
    return ServicesData(
      serviceID: json['serviceID'], 
      serviceName: json['serviceName'],
       isActive: json['isActive'], 
       minPrice: json['minPrice'], 
       maxPrice: json['maxPrice']
    );
  }

  //toJSON - Return/Send to DB
  Map<String, dynamic> toJson(){
    return {
      'serviceID': serviceID,
      'serviceName': serviceName,
      'isActive': isActive,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
    };
  }

}