import 'dart:ffi';

class AccountsData {
  final String userID;
  final String firstName;
  final String middleName;
  final String lastname;
  final DateTime birthDate;
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
    required this.email
  });

  //JSON to Accounts Information
  factory AccountsData.fromJson(Map<String, dynamic> json) {
    return AccountsData(
      userID: json['userID'] as String, 
      firstName: json['firstName'] as String, 
      middleName: json['middleName'] as String, 
      lastname: json['lastName'] as String,
      birthDate: json['birthDate'] as DateTime, 
      address: json['address'] as String, 
      city: json['city'] as String,
      province: json['province'] as String, 
      country: json['country'] as String, 
      zipCode: json['zipCode'] as String,
      contactNumber: json['contactNumber'] as String,
      email: json['email'] as String,
    );
  }

  //Returning the data to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'userID': userID as Int8,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastname,
      'birthDate': birthDate,
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