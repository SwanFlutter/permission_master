/// Enum to represent the status of a permission request.
enum PermissionStatus {
  /// Permission is granted
  granted,

  /// Permission is denied
  denied,

  /// Permission is restricted (parental controls, etc.)
  restricted,

  /// Permission is limited (iOS 14+ Photos limited access)
  limited,

  /// Permission status is not determined yet
  notDetermined,

  /// Need to open settings to change permission
  openSettings,

  /// Permission is not supported on this platform
  unsupported,

  /// An error occurred while checking permission
  error,
}
