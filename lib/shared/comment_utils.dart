const _editWindowMinutes = 15;

bool canModifyComment(DateTime timestamp) {
  return DateTime.now().difference(timestamp) < const Duration(minutes: _editWindowMinutes);
}

bool isEditWindowExpired(DateTime timestamp) {
  return DateTime.now().difference(timestamp) >= const Duration(minutes: _editWindowMinutes);
}
