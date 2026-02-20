import Flutter
import UIKit
import AVFoundation
import Photos
import CoreLocation
import Contacts
import CoreBluetooth
import UserNotifications
import EventKit
import CoreMotion
import Speech
import MediaPlayer
import HealthKit

public class PermissionMasterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, CBCentralManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationResult: FlutterResult?
  private var bluetoothManager: CBCentralManager?
  private var bluetoothResult: FlutterResult?
  private var motionManager: CMMotionActivityManager?
  private var motionResult: FlutterResult?
  private let healthStore = HKHealthStore()
  private let storage = GetStorage()
  private let permissionHelper = PermissionHelper.shared

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "permission_master_ios", binaryMessenger: registrar.messenger())
    let instance = PermissionMasterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "requestCameraPermission":
      requestCameraPermission(result: result)
    case "requestPhotosPermission":
      requestPhotosPermission(result: result)
    case "requestLocationPermission":
      requestLocationPermission(result: result)
    case "requestContactsPermission":
      requestContactsPermission(result: result)
    case "requestBluetoothPermission":
      requestBluetoothPermission(result: result)
    case "requestMicrophonePermission":
      requestMicrophonePermission(result: result)
    case "requestNotificationPermission":
      requestNotificationPermission(result: result)
    case "requestCalendarPermission":
      requestCalendarPermission(result: result)
    case "requestMotionPermission":
      requestMotionPermission(result: result)
    case "requestSpeechPermission":
      requestSpeechPermission(result: result)
    case "requestRemindersPermission":
      requestRemindersPermission(result: result)
    case "requestMusicPermission":
      requestMusicPermission(result: result)
    case "requestHealthPermission":
      requestHealthPermission(result: result)
    case "checkPermissionStatus":
      checkPermissionStatus(call: call, result: result)
    case "storage_write":
      handleStorageWrite(call: call, result: result)
    case "storage_read":
      handleStorageRead(call: call, result: result)
    case "storage_contains":
      handleStorageContains(call: call, result: result)
    case "storage_remove":
      handleStorageRemove(call: call, result: result)
    case "storage_clear":
      handleStorageClear(result: result)
    case "openAppSettings":
      openAppSettings(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - Open Settings
  private func openAppSettings(result: @escaping FlutterResult) {
    print("🔧 [Swift] openAppSettings called")
    
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      print("❌ [Swift] Failed to create settings URL")
      result(false)
      return
    }
    
    print("🔧 [Swift] Settings URL: \(settingsUrl)")
    
    if UIApplication.shared.canOpenURL(settingsUrl) {
      print("✅ [Swift] Can open settings URL, attempting to open...")
      UIApplication.shared.open(settingsUrl, options: [:]) { success in
        print("🔧 [Swift] Open result: \(success)")
        result(success)
      }
    } else {
      print("❌ [Swift] Cannot open settings URL")
      result(false)
    }
  }
  
  // MARK: - Storage Methods
  private func handleStorageWrite(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let key = args["key"] as? String,
          let value = args["value"] else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }
    
    do {
      try storage.write(key, value: value)
      result(nil)
    } catch {
      result(FlutterError(code: "WRITE_ERROR", message: error.localizedDescription, details: nil))
    }
  }
  
  private func handleStorageRead(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let key = args["key"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }
    
    let value = storage.read(key)
    result(value ?? args["defaultValue"])
  }
  
  private func handleStorageContains(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let key = args["key"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }
    
    result(storage.contains(key))
  }
  
  private func handleStorageRemove(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let key = args["key"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }
    
    storage.remove(key)
    result(nil)
  }
  
  private func handleStorageClear(result: @escaping FlutterResult) {
    storage.clear()
    result(nil)
  }
  
  private func checkPermissionStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let permissionType = args["permission"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
      return
    }
    
    switch permissionType {
    case "camera":
      result(mapCameraStatus(AVCaptureDevice.authorizationStatus(for: .video)))
    case "photos":
      result(mapPhotosStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite)))
    case "microphone":
      result(mapMicrophoneStatus(AVAudioSession.sharedInstance().recordPermission))
    case "health":
      if !HKHealthStore.isHealthDataAvailable() {
        result("unsupported")
      } else {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let status = healthStore.authorizationStatus(for: stepCountType)
        result(mapHealthStatus(status))
      }
    default:
      result("notDetermined")
    }
  }

  private func requestCameraPermission(result: @escaping FlutterResult) {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    if status == .notDetermined {
      if permissionHelper.canRequestPermission(for: "camera") {
        permissionHelper.incrementRequestCount(for: "camera")
        AVCaptureDevice.requestAccess(for: .video) { granted in
          DispatchQueue.main.async {
            let statusString = granted ? "granted" : "denied"
            try? self.storage.write("permission_camera_status", value: statusString)
            result(statusString)
          }
        }
        return
      }
    }
    
    let statusString = mapCameraStatus(status)
    try? storage.write("permission_camera_status", value: statusString)
    result(statusString)
  }

  private func requestPhotosPermission(result: @escaping FlutterResult) {
    let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    if status == .notDetermined {
      if permissionHelper.canRequestPermission(for: "photos") {
        permissionHelper.incrementRequestCount(for: "photos")
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
          DispatchQueue.main.async {
            let statusString = self.mapPhotosStatus(newStatus)
            try? self.storage.write("permission_photos_status", value: statusString)
            result(statusString)
          }
        }
        return
      }
    }
    
    let statusString = mapPhotosStatus(status)
    try? storage.write("permission_photos_status", value: statusString)
    result(statusString)
  }

  private func requestLocationPermission(result: @escaping FlutterResult) {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationResult = result
    locationManager?.requestWhenInUseAuthorization()
  }

  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard let locationResult = locationResult else { return }
    locationResult(mapLocationStatus(status))
    self.locationResult = nil
    self.locationManager = nil
  }

  public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if #available(iOS 14.0, *) {
      let status = manager.authorizationStatus
      guard let locationResult = locationResult else { return }
      locationResult(mapLocationStatus(status))
      self.locationResult = nil
      self.locationManager = nil
    }
  }

  private func requestContactsPermission(result: @escaping FlutterResult) {
    let store = CNContactStore()
    let status = CNContactStore.authorizationStatus(for: .contacts)
    if status == .notDetermined {
      store.requestAccess(for: .contacts) { granted, _ in
        DispatchQueue.main.async {
          result(granted ? "granted" : "denied")
        }
      }
      return
    }
    result(mapContactsStatus(status))
  }

  private func requestBluetoothPermission(result: @escaping FlutterResult) {
    bluetoothResult = result
    bluetoothManager = CBCentralManager(delegate: self, queue: nil)
  }

  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    guard let bluetoothResult = bluetoothResult else { return }
    if #available(iOS 13.0, *) {
      bluetoothResult(mapBluetoothStatus(CBManager.authorization))
    } else {
      switch central.state {
      case .poweredOn:
        bluetoothResult("granted")
      case .unauthorized:
        bluetoothResult("denied")
      case .unsupported, .poweredOff, .resetting, .unknown:
        bluetoothResult("restricted")
      @unknown default:
        bluetoothResult("notDetermined")
      }
    }
    self.bluetoothResult = nil
    self.bluetoothManager = nil
  }

  private func requestMicrophonePermission(result: @escaping FlutterResult) {
    let status = AVAudioSession.sharedInstance().recordPermission
    
    if status == .undetermined {
      if permissionHelper.canRequestPermission(for: "microphone") {
        permissionHelper.incrementRequestCount(for: "microphone")
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          DispatchQueue.main.async {
            let statusString = granted ? "granted" : "denied"
            try? self.storage.write("permission_microphone_status", value: statusString)
            result(statusString)
          }
        }
        return
      }
    }
    
    let statusString = mapMicrophoneStatus(status)
    try? storage.write("permission_microphone_status", value: statusString)
    result(statusString)
  }

  private func requestNotificationPermission(result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      if settings.authorizationStatus == .notDetermined {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
          DispatchQueue.main.async {
            result(granted ? "granted" : "denied")
          }
        }
        return
      }
      DispatchQueue.main.async {
        result(self.mapNotificationStatus(settings.authorizationStatus))
      }
    }
  }

  private func requestCalendarPermission(result: @escaping FlutterResult) {
    let store = EKEventStore()
    let status = EKEventStore.authorizationStatus(for: .event)
    if status == .notDetermined {
      store.requestAccess(to: .event) { granted, _ in
        DispatchQueue.main.async {
          result(granted ? "granted" : "denied")
        }
      }
      return
    }
    result(mapCalendarStatus(status))
  }

  private func requestMotionPermission(result: @escaping FlutterResult) {
    let status = CMMotionActivityManager.authorizationStatus()
    if status == .notDetermined {
      motionResult = result
      motionManager = CMMotionActivityManager()
      motionManager?.startActivityUpdates(to: .main) { _ in
        self.motionManager?.stopActivityUpdates()
        let updatedStatus = CMMotionActivityManager.authorizationStatus()
        self.motionResult?(self.mapMotionStatus(updatedStatus))
        self.motionResult = nil
        self.motionManager = nil
      }
      return
    }
    result(mapMotionStatus(status))
  }

  private func requestSpeechPermission(result: @escaping FlutterResult) {
    let status = SFSpeechRecognizer.authorizationStatus()
    if status == .notDetermined {
      SFSpeechRecognizer.requestAuthorization { newStatus in
        DispatchQueue.main.async {
          result(self.mapSpeechStatus(newStatus))
        }
      }
      return
    }
    result(mapSpeechStatus(status))
  }

  private func requestRemindersPermission(result: @escaping FlutterResult) {
    let store = EKEventStore()
    let status = EKEventStore.authorizationStatus(for: .reminder)
    if status == .notDetermined {
      store.requestAccess(to: .reminder) { granted, _ in
        DispatchQueue.main.async {
          result(granted ? "granted" : "denied")
        }
      }
      return
    }
    result(mapCalendarStatus(status))
  }

  private func requestMusicPermission(result: @escaping FlutterResult) {
    let status = MPMediaLibrary.authorizationStatus()
    if status == .notDetermined {
      MPMediaLibrary.requestAuthorization { newStatus in
        DispatchQueue.main.async {
          result(self.mapMusicStatus(newStatus))
        }
      }
      return
    }
    result(mapMusicStatus(status))
  }

  private func requestHealthPermission(result: @escaping FlutterResult) {
    print("🔧 [Swift] requestHealthPermission called")
    
    if !HKHealthStore.isHealthDataAvailable() {
      print("❌ [Swift] Health data not available on this device")
      result("unsupported")
      return
    }
    
    // Define health data types to read
    let readTypes: Set<HKObjectType> = [
      HKObjectType.workoutType(),
      HKObjectType.quantityType(forIdentifier: .stepCount)!,
      HKObjectType.quantityType(forIdentifier: .heartRate)!,
      HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
      HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
    ]
    
    // Define health data types to write (optional)
    let writeTypes: Set<HKSampleType> = [
      HKObjectType.workoutType(),
      HKObjectType.quantityType(forIdentifier: .stepCount)!,
    ]
    
    print("🔧 [Swift] Requesting Health authorization...")
    
    healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
      DispatchQueue.main.async {
        if let error = error {
          print("❌ [Swift] Health authorization error: \(error.localizedDescription)")
          result("denied")
          return
        }
        
        print("✅ [Swift] Health authorization success: \(success)")
        
        // Check the actual status for one of the types
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let status = self.healthStore.authorizationStatus(for: stepCountType)
        
        print("🔧 [Swift] Health status: \(status.rawValue)")
        
        switch status {
        case .notDetermined:
          result("notDetermined")
        case .sharingAuthorized:
          result("granted")
        case .sharingDenied:
          result("denied")
        @unknown default:
          result("notDetermined")
        }
      }
    }
  }

  private func mapCameraStatus(_ status: AVAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapPhotosStatus(_ status: PHAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .limited:
      return "limited"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapLocationStatus(_ status: CLAuthorizationStatus) -> String {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapContactsStatus(_ status: CNAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapBluetoothStatus(_ status: CBManagerAuthorization) -> String {
    switch status {
    case .allowedAlways:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapMicrophoneStatus(_ status: AVAudioSession.RecordPermission) -> String {
    switch status {
    case .granted:
      return "granted"
    case .denied:
      return "denied"
    case .undetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapNotificationStatus(_ status: UNAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .provisional:
      return "limited"
    case .ephemeral:
      return "limited"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapCalendarStatus(_ status: EKAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapMotionStatus(_ status: CMAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapSpeechStatus(_ status: SFSpeechRecognizerAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapMusicStatus(_ status: MPMediaLibraryAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }

  private func mapHealthStatus(_ status: HKAuthorizationStatus) -> String {
    switch status {
    case .sharingAuthorized:
      return "granted"
    case .sharingDenied:
      return "denied"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "notDetermined"
    }
  }
}
