class SuppliersData {
  final int supplierID;
  final String supplierEmail;
  final String supplierName;
  final String contactNumber;
  final bool isActive;

  SuppliersData({
    required this.supplierID,
    required this.supplierEmail,
    required this.supplierName,
    required this.contactNumber,
    required this.isActive,
  });

  //fromJSON Method - receive
  factory SuppliersData.fromJson(Map<String, dynamic> json) {
    return SuppliersData(
    supplierID: json['supplierID'], 
    supplierEmail: json['supplierEmail'], 
    supplierName: json['supplierName'], 
    contactNumber: json['contactNumber'], 
    isActive: json['isActive']
    );
  }

  //toJSON Method - send
  Map<String, dynamic> toJson() {
    return {
      'supplierID': supplierID,
      'supplierEmail': supplierEmail,
      'supplierName': supplierName,
      'contactNumber': contactNumber,
      'isActive': isActive,
    };
  }
}