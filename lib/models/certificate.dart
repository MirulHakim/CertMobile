// Helper methods
bool get isExpired {
  if (expiryDate == null) return false;
  return DateTime.now().isAfter(expiryDate!);
}

bool get isActive {
  return status == 'active' && !isExpired;
}
