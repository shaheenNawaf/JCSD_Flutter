class AccountsData {
  final String userID;
  final String firstName;
  final String middleName;
  final String lastname;
  final DateTime? birthDate;
  final String address;
  final String city;
  final String province;
  final String country;
  final String zipCode;
  final String contactNumber;
  final String email;

  AccountsData({
    required this.userID,
    required this.firstName,
    required this.middleName,
    required this.lastname,
    required this.birthDate,
    required this.address,
    required this.city,
    required this.province,
    required this.country,
    required this.zipCode,
    required this.contactNumber,
    required this.email,
  });

  // Helper to convert null or empty string to 'N/A'
  static String _stringOrNA(dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return 'N/A';
    }
    return value.toString();
  }

  factory AccountsData.fromJson(Map<String, dynamic> json) {
    return AccountsData(
      userID: _stringOrNA(json['userID']),
      firstName: _stringOrNA(json['firstName']),
      middleName: _stringOrNA(json['middleName']),
      lastname: _stringOrNA(json['lastName']),
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'])
          : null,
      address: _stringOrNA(json['address']),
      city: _stringOrNA(json['city']),
      province: _stringOrNA(json['province']),
      country: _stringOrNA(json['country']),
      zipCode: _stringOrNA(json['zipCode']),
      contactNumber: _stringOrNA(json['contactNumber']),
      email: _stringOrNA(json['email']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastname,
      'birthDate': birthDate?.toIso8601String(),
      'address': address,
      'city': city,
      'province': province,
      'country': country,
      'zipCode': zipCode,
      'contactNumber': contactNumber,
      'email': email,
    };
  }
}
