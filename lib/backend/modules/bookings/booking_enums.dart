enum BookingStatus {
  pendingConfirmation,
  confirmed, // Renamed from confirmed/scheduled for simplicity, adjust if needed
  inProgress,
  pendingParts,
  pendingCustomerResponse,
  readyForPickup,
  pendingAdminApproval,
  pendingPayment,
  completed,
  cancelled,
  noShow,
  unknown,
}

enum BookingType {
  appointment,
  walkIn,
  homeService,
  unknown,
}

// Helper Functions to handle Mapping String back to Enum, vice-versa
extension BookingStatusExtension on BookingStatus {
  String get name => toString().split('.').last; // Getting the base String name

  static BookingStatus fromString(String? statusString) {
    if (statusString == null) return BookingStatus.unknown;
    for (var status in BookingStatus.values) {
      if (status.name == statusString) {
        // Use .name comparison
        return status;
      }
    }
    print("Warning: Unknown BookingStatus string received: $statusString");
    return BookingStatus.unknown; // Fallback for unknown strings
  }
}

//Fetching the Booking Type -- Same code ra sa taas but for diff enum
extension BookingTypeExtension on BookingType {
  String get name => toString().split('.').last;

  static BookingType fromString(String? typeString) {
    if (typeString == null) return BookingType.unknown;
    for (var type in BookingType.values) {
      if (type.name == typeString) {
        return type;
      }
    }
    print("Warning: Unknown BookingType string received: $typeString");
    return BookingType.unknown;
  }
}
