enum ReturnOrderStatus {
  PendingApproval,
  Approved, // Admin has approved the return
  ItemsSentToSupplier, // Items physically sent (optional intermediate step)
  AwaitingReplacement, // Supplier acknowledged receipt, waiting for replacement
  ReplacementReceived, // Replacement items physically received by JCSD
  Completed, // RO fully processed, replacement integrated
  Cancelled, // RO cancelled by admin or user
  Unknown,
  Rejected // Default/Error state
}

extension ReturnOrderStatusExtension on ReturnOrderStatus {
  String get dbValue {
    return toString().split('.').last; // e.g., "PendingApproval"
  }

  static ReturnOrderStatus fromDbValue(String? statusString) {
    if (statusString == null) return ReturnOrderStatus.Unknown;
    for (var status in ReturnOrderStatus.values) {
      if (status.dbValue == statusString) {
        return status;
      }
    }
    print("Warning: Unknown ReturnOrderStatus string received: $statusString");
    return ReturnOrderStatus.Unknown;
  }
}
