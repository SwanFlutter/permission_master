// Android and iOS permissions
enum PermissionType {
  camera('android.permission.CAMERA'),
  fineLocation('android.permission.ACCESS_FINE_LOCATION'),
  backgroundLocation('android.permission.ACCESS_BACKGROUND_LOCATION'),
  readStorage('android.permission.READ_EXTERNAL_STORAGE'),
  writeStorage('android.permission.WRITE_EXTERNAL_STORAGE'),
  microphone('android.permission.RECORD_AUDIO'),
  contacts('android.permission.READ_CONTACTS'),
  bluetooth('android.permission.BLUETOOTH'),
  bluetoothAdmin('android.permission.BLUETOOTH_ADMIN'),
  bluetoothScan('android.permission.BLUETOOTH_SCAN'),
  bluetoothAdvertise('android.permission.BLUETOOTH_ADVERTISE'),
  bluetoothConnect('android.permission.BLUETOOTH_CONNECT'),
  bodySensors('android.permission.BODY_SENSORS'),
  accessWifi('android.permission.ACCESS_WIFI_STATE'),
  changeWifi('android.permission.CHANGE_WIFI_STATE'),
  sms('android.permission.SEND_SMS'),
  notifications('android.permission.POST_NOTIFICATIONS'),
  alarm('android.permission.SCHEDULE_EXACT_ALARM'),
  calendar('android.permission.READ_CALENDAR'),
  phone('android.permission.READ_PHONE_STATE'),
  activityRecognition('android.permission.ACTIVITY_RECOGNITION'),
  nearbyDevices('android.permission.NEARBY_WIFI_DEVICES'),
  health('android.permission.HEALTH_CONNECT');

  final String value;
  const PermissionType(this.value);
}

// Windows specific permissions
enum PermissionTypeWindows {
  camera('windows.permission.CAMERA'),
  microphone('windows.permission.MICROPHONE'),
  location('windows.permission.LOCATION'),
  storage('windows.permission.STORAGE'),
  contacts('windows.permission.CONTACTS'),
  calendar('windows.permission.CALENDAR'),
  notifications('windows.permission.NOTIFICATIONS'),
  radios('windows.permission.RADIOS'),
  voiceActivation('windows.permission.VOICE_ACTIVATION'),
  email('windows.permission.EMAIL'),
  speech('windows.permission.SPEECH'),
  bluetooth('windows.permission.BLUETOOTH');

  final String value;
  const PermissionTypeWindows(this.value);
}

// macOS specific permissions
enum PermissionTypeMacOS {
  camera('macos.permission.CAMERA'),
  microphone('macos.permission.MICROPHONE'),
  location('macos.permission.LOCATION'),
  photos('macos.permission.PHOTOS'),
  contacts('macos.permission.CONTACTS'),
  notification('macos.permission.NOTIFICATION'),
  bluetooth('macos.permission.BLUETOOTH'),
  calendar('macos.permission.CALENDAR'),
  reminders('macos.permission.REMINDERS'),
  speech('macos.permission.SPEECH');

  final String value;
  const PermissionTypeMacOS(this.value);
}

// Linux specific permissions
enum PermissionTypeLinux {
  camera('linux.permission.CAMERA'),
  microphone('linux.permission.MICROPHONE'),
  location('linux.permission.LOCATION'),
  storage('linux.permission.STORAGE'),
  contacts('linux.permission.CONTACTS'),
  calendar('linux.permission.CALENDAR'),
  notification('linux.permission.NOTIFICATION'),
  bluetooth('linux.permission.BLUETOOTH'),
  network('linux.permission.NETWORK'),
  usb('linux.permission.USB');

  final String value;
  const PermissionTypeLinux(this.value);
}

// Web specific permissions
enum PermissionTypeWeb {
  camera('web.permission.CAMERA'),
  microphone('web.permission.MICROPHONE'),
  location('web.permission.LOCATION'),
  notification('web.permission.NOTIFICATION'),
  bluetooth('web.permission.BLUETOOTH'),
  storage('web.permission.STORAGE');

  final String value;
  const PermissionTypeWeb(this.value);
}
