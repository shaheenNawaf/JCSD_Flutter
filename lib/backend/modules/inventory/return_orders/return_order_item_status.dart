enum ReturnOrderItemStatus {
  pendingReturn(
      'Pending Return'), // Item selected, RO created but not yet approved
  returnApproved('Return Approved'), // Admin approved this item for return
  returnRejectedByAdmin('Return Rejected by Admin'), // Admin rejected this item
  shipped('Shipped to Vendor'),
  replacementReceived('Replacement Received'),
  vendorRejected('Vendor Rejected Return'), // Vendor will not replace
  completed('completed'); // Item process complete

  const ReturnOrderItemStatus(this.displayName);
  final String displayName;

  static ReturnOrderItemStatus fromString(String? statusString) {
    if (statusString == null) return ReturnOrderItemStatus.pendingReturn;
    for (ReturnOrderItemStatus status in ReturnOrderItemStatus.values) {
      if (status.name == statusString || status.displayName == statusString) {
        return status;
      }
    }
    print('Warning: Unknown ReturnOrderItemStatus string: $statusString');
    return ReturnOrderItemStatus.pendingReturn;
  }
}
