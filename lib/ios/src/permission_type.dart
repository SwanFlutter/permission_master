/// iOS Permission Types
enum PermissionType {
  /// Camera permission
  camera('camera'),

  /// Photo library permission
  photos('photos'),

  /// Location permission
  location('location'),

  /// Contacts permission
  contacts('contacts'),

  /// Bluetooth permission
  bluetooth('bluetooth'),

  /// Microphone permission
  microphone('microphone'),

  /// Notification permission
  notification('notification'),

  /// Calendar permission
  calendar('calendar'),

  /// Motion & Fitness permission
  motion('motion'),

  /// Speech recognition permission
  speech('speech'),

  /// Reminders permission
  reminders('reminders'),

  /// Media library permission
  music('music'),

  /// Health data permission
  health('health');

  final String value;
  const PermissionType(this.value);
}
