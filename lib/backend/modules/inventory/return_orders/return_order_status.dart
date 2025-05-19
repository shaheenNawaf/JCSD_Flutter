enum ReturnOrderStatus {
  pendingAdminConfirmation('Pending Admin Confirmation'),
  adminRejected('Admin Rejected'),
  approvedForReturn('Approved - Awaiting Shipment to Vendor'),
  shippedToVendor('Shipped to Vendor'),
  replacementReceived('Replacement Received'),
  closed('Closed'),
  cancelled('Cancelled');

  const ReturnOrderStatus(this.displayName);
  final String displayName;

  static ReturnOrderStatus fromString(String? statusString) {
    if (statusString == null) {
      return ReturnOrderStatus.pendingAdminConfirmation;
    }
    for (ReturnOrderStatus status in ReturnOrderStatus.values) {
      if (status.name == statusString || status.displayName == statusString) {
        return status;
      }
    }
    print('Warning: Unknown ReturnOrderStatus string: $statusString');
    return ReturnOrderStatus.pendingAdminConfirmation;
  }
}
