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
  nearbyDevices('android.permission.NEARBY_WIFI_DEVICES');

  final String value;
  const PermissionType(this.value);
}
