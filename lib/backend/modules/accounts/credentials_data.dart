import 'dart:ffi';

class CredentialsData {
  final String credsID;
  // final String userName;
  final String passWord;

  CredentialsData({
    required this.credsID,
    // required this.userName,
    required this.passWord,
  });

  //JSON to Accounts Credentials Information
  factory CredentialsData.fromJson(Map<String, dynamic> json) {
    return CredentialsData(
      credsID: json['credsID'] as String,
      // userName: json['userName'] as String,
      passWord: json['passWord'] as String,
    );
  }

  //Returning the data to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'credsID': credsID as Int8,
      // 'userName': userName,
      'passWord': passWord,
    };
  }
}
