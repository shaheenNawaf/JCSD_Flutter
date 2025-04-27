import 'package:flutter/foundation.dart';

class ManufacturersData {
  final int manufacturerID;
  final String manufacturerName; 
  final String manufacturerEmail;
  final String contactNumber;
  final DateTime createdDate;
  final DateTime? updateDate;
  final bool isActive;
  final String address;

  ManufacturersData({
    required this.manufacturerID,
    required this.manufacturerName,
    required this.manufacturerEmail,
    required this.contactNumber,
    required this.createdDate,
    this.updateDate,
    required this.isActive,
    required this.address,
  });

  //Factory for handling the JSON data
  factory ManufacturersData.fromJson(Map<String, dynamic> json){

    DateTime? parseOptionalDateTime(String? dateString) {
      return dateString != null ? DateTime.tryParse(dateString) : null;
    }

    DateTime parseRequiredDateTime(String? dateString) {
      if(dateString == null) {
        print('Warning: Receinvbed null for non-nullable data column, using fallback.');
        return DateTime.now();
      }
      return DateTime.parse(dateString);
    }

    return ManufacturersData(
      manufacturerID: json['manufacturerID'] as int, 
      manufacturerName: json['manufacturerName'] as String,
      manufacturerEmail: json['manufacturerEmail'] as String, 
      contactNumber: json['contactNumber'] as String, 
      createdDate: parseRequiredDateTime(json['createdDate']),
      updateDate: parseOptionalDateTime(json['updateDate']), 
      isActive: json['isActive'] as bool, 
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson(){
    return {
     'manufacturerID' : manufacturerID,
     'manufacturerName' : manufacturerName,
     'manufacturerEmail' : manufacturerEmail,
     'contactNumber' : contactNumber,
     'isActive' : isActive,
     'address' : address,
    };
  }

  //For State Management
  ManufacturersData copyWith({
    int? manufacturerID,
    String? manufacturerName, 
    String? manufacturerEmail,
    DateTime? createdDate,
    ValueGetter<DateTime?>? updateDate,
    String? contactNumber,
    bool? isActive,
    String? address,
  }) {
    return ManufacturersData(
      manufacturerID: manufacturerID ?? this.manufacturerID, 
      manufacturerName: manufacturerName ?? this.manufacturerName, 
      manufacturerEmail: manufacturerEmail ?? this.manufacturerEmail, 
      createdDate: createdDate ?? this.createdDate,
      updateDate: updateDate != null ? updateDate() : this.updateDate,
      contactNumber: contactNumber ?? this.contactNumber, 
      isActive: isActive ?? this.isActive, 
      address: address ?? this.address
    );
  }
}