/// Enum to represent the status of a permission request.
enum PermissionStatus {
  granted,
  denied,
  openSettings,
  unsupported,
  error,
  restricted, // iOS specific: Permission restricted by parental controls
  limited, // iOS specific: Limited access granted (e.g., limited photos)
  notDetermined, // iOS specific: User hasn't been asked yet
}
