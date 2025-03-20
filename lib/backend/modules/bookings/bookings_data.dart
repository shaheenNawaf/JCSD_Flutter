class BookingsData {
  final int bookingID;
  final int userID;
  final int empID;
  final bool isConfirmed;
  final int rigLevel;
  final bool isPaid;
  final DateTime createdDate;
  final DateTime updateDate;
  final List<String> availedServices;

  BookingsData(
      {required this.bookingID,
      required this.userID,
      required this.empID,
      required this.isConfirmed,
      required this.rigLevel,
      required this.isPaid,
      required this.createdDate,
      required this.updateDate,
      required this.availedServices});

  //Retrieving the information in the form of JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingID': bookingID,
      'userID': userID,
      'employeeID': empID,
      'isConfirmed': isConfirmed,
      'availedServices': availedServices,
      'rigLevel': rigLevel,
      'isPaid': isPaid,
      'bookingDate': createdDate,
      'updateDate': updateDate,
    };
  }

  //JSON to Booking Data classitem
  factory BookingsData.fromJson(Map<String, dynamic> json) {
    return BookingsData(
      bookingID: json["bookingID"],
      userID: json["userID"],
      empID: json["empID"],
      isConfirmed: json["isConfirmed"],
      rigLevel: json["rigLevel"],
      isPaid: json["isPaid"],
      createdDate: json["createdDate"],
      updateDate: json["updateDate"],
      availedServices: json["availedServices"],
    );
  }
}
