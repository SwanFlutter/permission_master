import Flutter
import UIKit

#if PERMISSION_CAMERA
import AVFoundation
#endif

#if PERMISSION_PHOTOS
import Photos
#endif

#if PERMISSION_LOCATION
import CoreLocation
#endif

#if PERMISSION_CONTACTS
import Contacts
#endif

#if PERMISSION_BLUETOOTH
import CoreBluetooth
#endif

#if PERMISSION_MOTION
import CoreMotion
#endif

#if PERMISSION_NOTIFICATIONS
import UserNotifications
#endif

#if PERMISSION_MICROPHONE
import AVFoundation
#endif

#if PERMISSION_CALENDAR
import EventKit
#endif

#if PERMISSION_REMINDERS
import EventKit
#endif

#if PERMISSION_SPEECH_RECOGNITION
import Speech
#endif

#if PERMISSION_MUSIC_LIBRARY
import MediaPlayer
#endif

#if PERMISSION_HEALTH
import HealthKit
#endif

@objc(PermissionMasterPlugin)
public class SwiftPermissionMasterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    #if PERMISSION_LOCATION
    private let locationManager = CLLocationManager()
    #endif
    
    #if PERMISSION_CONTACTS
    private let contactStore = CNContactStore()
    #endif
    
    #if PERMISSION_BLUETOOTH
    private var centralManager: CBCentralManager?
    #endif
    
    #if PERMISSION_CALENDAR || PERMISSION_REMINDERS
    private var eventStore: EKEventStore?
    #endif
    
    #if PERMISSION_HEALTH
    private var healthStore: HKHealthStore?
    #endif
    
    private let permissionHelper = PermissionHelper.shared
    private var storage: GetStorage
    
    // Dictionary to store pending results
    private var pendingResults = [String: FlutterResult]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "permission_master", binaryMessenger: registrar.messenger())
        let instance = SwiftPermissionMasterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    override init() {
        self.storage = GetStorage()
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let permissionHelper = PermissionHelper.shared
        
        NSLog("PermissionMaster: Method called: \(call.method)")
        
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "requestCameraPermission":
            #if PERMISSION_CAMERA
            requestCameraPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Camera permission not enabled in Podfile", details: nil))
            #endif
        case "requestLocationPermission":
            #if PERMISSION_LOCATION
            requestLocationPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Location permission not enabled in Podfile", details: nil))
            #endif
        case "requestStoragePermission", "requestPhotoLibraryPermission":
            #if PERMISSION_PHOTOS
            requestPhotoLibraryPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Photos permission not enabled in Podfile", details: nil))
            #endif
        case "requestBluetoothPermission":
            #if PERMISSION_BLUETOOTH
            requestBluetoothPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Bluetooth permission not enabled in Podfile", details: nil))
            #endif
        case "requestContactsPermission":
            #if PERMISSION_CONTACTS
            requestContactsPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Contacts permission not enabled in Podfile", details: nil))
            #endif
        case "requestNotificationPermission":
            #if PERMISSION_NOTIFICATIONS
            requestNotificationPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Notifications permission not enabled in Podfile", details: nil))
            #endif
        case "requestMicrophonePermission":
            #if PERMISSION_MICROPHONE
            requestMicrophonePermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Microphone permission not enabled in Podfile", details: nil))
            #endif
        case "requestCalendarPermission":
            #if PERMISSION_CALENDAR
            requestCalendarPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Calendar permission not enabled in Podfile", details: nil))
            #endif
        case "requestRemindersPermission":
            #if PERMISSION_REMINDERS
            requestRemindersPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Reminders permission not enabled in Podfile", details: nil))
            #endif
        case "requestSpeechRecognitionPermission":
            #if PERMISSION_SPEECH_RECOGNITION
            requestSpeechRecognitionPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Speech Recognition permission not enabled in Podfile", details: nil))
            #endif
        case "requestMotionPermission", "requestSensorsPermission":
            #if PERMISSION_MOTION
            requestMotionPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Motion permission not enabled in Podfile", details: nil))
            #endif
        case "requestHealthPermission":
            #if PERMISSION_HEALTH
            requestHealthPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Health permission not enabled in Podfile", details: nil))
            #endif
        case "requestMusicLibraryPermission":
            #if PERMISSION_MUSIC_LIBRARY
            requestMusicLibraryPermission(result: result)
            #else
            result(FlutterError(code: "PERMISSION_NOT_ENABLED", message: "Music Library permission not enabled in Podfile", details: nil))
            #endif
        case "checkPermissionStatus":
            checkPermissionStatus(call, result: result)
        case "checkMultiplePermissions":
            checkMultiplePermissions(call, result: result)
        case "requestDynamicPermissions":
            requestDynamicPermissions(call, result: result)
        case "openAppSettings":
            openAppSettings(result: result)
        case "storage_write":
            storageWrite(call, result: result)
        case "storage_read":
            storageRead(call, result: result)
        case "storage_contains":
            storageContains(call, result: result)
        case "storage_remove":
            storageRemove(call, result: result)
        case "storage_clear":
            storageClear(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - New Methods for Feature Parity with Android
    
    private func checkPermissionStatus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let permission = args["permission"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Permission string cannot be null", details: nil))
            return
        }
        
        let status = getPermissionStatus(for: permission)
        result(status.rawValue)
    }
    
    private func checkMultiplePermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let permissions = args["permissions"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Permissions list cannot be null", details: nil))
            return
        }
        
        var statusMap = [String: String]()
        for permission in permissions {
            let status = getPermissionStatus(for: permission)
            statusMap[permission] = status.rawValue
        }
        
        result(statusMap)
    }
    
    private func requestDynamicPermissions(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let permissions = args["permissions"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Permissions list cannot be null", details: nil))
            return
        }
        
        // Only supporting the first permission for simplicity, but could be extended
        if permissions.isEmpty {
            result(["result": "No permissions requested"])
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var results = [String: String]()
        
        for permission in permissions {
            dispatchGroup.enter()
            
            switch permission {
            case "camera":
                #if PERMISSION_CAMERA
                requestCameraPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            case "location", "fine_location", "coarse_location":
                #if PERMISSION_LOCATION
                requestLocationPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            case "storage", "photos", "photo_library":
                #if PERMISSION_PHOTOS
                requestPhotoLibraryPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            case "bluetooth":
                #if PERMISSION_BLUETOOTH
                requestBluetoothPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            case "contacts":
                #if PERMISSION_CONTACTS
                requestContactsPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            case "notification", "notifications":
                #if PERMISSION_NOTIFICATIONS
                requestNotificationPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            case "microphone":
                #if PERMISSION_MICROPHONE
                requestMicrophonePermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
                #else
                results[permission] = "ERROR_NOT_ENABLED"
                dispatchGroup.leave()
                #endif
            default:
                results[permission] = "NOT_IMPLEMENTED"
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            result(results)
        }
    }
    
    private func openAppSettings(result: @escaping FlutterResult) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    result(success)
                }
            } else {
                result(false)
            }
        } else {
            result(false)
        }
    }
    
    // MARK: - CLLocationManagerDelegate methods
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if let pendingResult = pendingResults["location"] {
                pendingResult(true)
                pendingResults.removeValue(forKey: "location")
            }
        case .denied, .restricted:
            if let pendingResult = pendingResults["location"] {
                pendingResult(false)
                pendingResults.removeValue(forKey: "location")
            }
        default:
            break
        }
    }
    
    // MARK: - Storage Methods
    
    private func storageWrite(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String else {
            result(FlutterError(code: "INVALID_KEY", message: "Key cannot be null", details: nil))
            return
        }
        
        guard let value = args["value"] else {
            result(FlutterError(code: "INVALID_VALUE", message: "Value cannot be null", details: nil))
            return
        }
        
        do {
            try storage.write(key, value: value)
            result(true)
        } catch {
            result(FlutterError(code: "WRITE_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func storageRead(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String else {
            result(FlutterError(code: "INVALID_KEY", message: "Key cannot be null", details: nil))
            return
        }
        
        guard let defaultValue = args["defaultValue"] else {
            result(FlutterError(code: "INVALID_DEFAULT", message: "Default value cannot be null", details: nil))
            return
        }
        
        let value = storage.read(key) ?? defaultValue
        result(value)
    }
    
    private func storageContains(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String else {
            result(FlutterError(code: "INVALID_KEY", message: "Key cannot be null", details: nil))
            return
        }
        
        result(storage.contains(key))
    }
    
    private func storageRemove(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let key = args["key"] as? String else {
            result(FlutterError(code: "INVALID_KEY", message: "Key cannot be null", details: nil))
            return
        }
        
        storage.remove(key)
        result(true)
    }
    
    private func storageClear(result: @escaping FlutterResult) {
        storage.clear()
        result(true)
    }
    
    // MARK: - Permission Status Helper
    
    private func getPermissionStatus(for permission: String) -> PermissionStatus {
        switch permission {
        case "camera":
            #if PERMISSION_CAMERA
            return getCameraPermissionStatus()
            #else
            return .denied
            #endif
        case "location", "fine_location", "coarse_location":
            #if PERMISSION_LOCATION
            return getLocationPermissionStatus()
            #else
            return .denied
            #endif
        case "storage", "photos", "photo_library":
            #if PERMISSION_PHOTOS
            return getPhotoLibraryPermissionStatus()
            #else
            return .denied
            #endif
        case "bluetooth":
            #if PERMISSION_BLUETOOTH
            return getBluetoothPermissionStatus()
            #else
            return .denied
            #endif
        case "contacts":
            #if PERMISSION_CONTACTS
            return getContactsPermissionStatus()
            #else
            return .denied
            #endif
        case "notification", "notifications":
            #if PERMISSION_NOTIFICATIONS
            return getNotificationPermissionStatus()
            #else
            return .denied
            #endif
        case "microphone":
            #if PERMISSION_MICROPHONE
            return getMicrophonePermissionStatus()
            #else
            return .denied
            #endif
        case "calendar":
            #if PERMISSION_CALENDAR
            return getCalendarPermissionStatus()
            #else
            return .denied
            #endif
        case "reminders":
            #if PERMISSION_REMINDERS
            return getRemindersPermissionStatus()
            #else
            return .denied
            #endif
        case "speech_recognition":
            #if PERMISSION_SPEECH_RECOGNITION
            return getSpeechRecognitionPermissionStatus()
            #else
            return .denied
            #endif
        case "motion", "sensors", "activity_recognition":
            #if PERMISSION_MOTION
            return getMotionPermissionStatus()
            #else
            return .denied
            #endif
        case "health":
            #if PERMISSION_HEALTH
            return getHealthPermissionStatus()
            #else
            return .denied
            #endif
        case "music_library":
            #if PERMISSION_MUSIC_LIBRARY
            return getMusicLibraryPermissionStatus()
            #else
            return .denied
            #endif
        default:
            return .notDetermined
        }
    }
    
    #if PERMISSION_CAMERA
    private func getCameraPermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "camera") ? .denied : .permanentlyDenied
        case .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_LOCATION
    private func getLocationPermissionStatus() -> PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "location") ? .denied : .permanentlyDenied
        case .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_PHOTOS
      private func getPhotoLibraryPermissionStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "photo_library") ? .denied : .permanentlyDenied
        case .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_BLUETOOTH
    private func getBluetoothPermissionStatus() -> PermissionStatus {
        if #available(iOS 13.0, *) {
            if centralManager == nil {
                centralManager = CBCentralManager(delegate: nil, queue: nil)
            }
            
            switch centralManager?.state {
            case .poweredOn:
                return .granted
            case .unauthorized:
                return permissionHelper.canRequestPermission(for: "bluetooth") ? .denied : .permanentlyDenied
            case .unsupported, .poweredOff, .resetting:
                return .denied
            case .none, .unknown:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        } else {
            return .granted
        }
    }
    #endif
    
    #if PERMISSION_CONTACTS
    private func getContactsPermissionStatus() -> PermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "contacts") ? .denied : .permanentlyDenied
        case .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_NOTIFICATIONS
    private func getNotificationPermissionStatus() -> PermissionStatus {
        var status: PermissionStatus = .notDetermined
        
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                status = .granted
            case .denied:
                status = self.permissionHelper.canRequestPermission(for: "notifications") ? .denied : .permanentlyDenied
            case .notDetermined:
                status = .notDetermined
            @unknown default:
                status = .notDetermined
            }
            semaphore.signal()
        }
        
        // Only wait a short time to prevent blocking UI
        _ = semaphore.wait(timeout: .now() + 0.5)
        return status
    }
    #endif
    
    #if PERMISSION_MICROPHONE
    private func getMicrophonePermissionStatus() -> PermissionStatus {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .granted:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "microphone") ? .denied : .permanentlyDenied
        case .undetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_CALENDAR
    private func getCalendarPermissionStatus() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess, .authorized:
                return .granted
            case .writeOnly:
                return .granted
            case .denied:
                return permissionHelper.canRequestPermission(for: "calendar") ? .denied : .permanentlyDenied
            case .restricted:
                return .permanentlyDenied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        } else {
            switch status {
            case .authorized:
                return .granted
            case .denied:
                return permissionHelper.canRequestPermission(for: "calendar") ? .denied : .permanentlyDenied
            case .restricted:
                return .permanentlyDenied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        }
    }
    #endif
    
    #if PERMISSION_REMINDERS
    private func getRemindersPermissionStatus() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess, .authorized:
                return .granted
            case .writeOnly:
                return .granted
            case .denied:
                return permissionHelper.canRequestPermission(for: "reminders") ? .denied : .permanentlyDenied
            case .restricted:
                return .permanentlyDenied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        } else {
            switch status {
            case .authorized:
                return .granted
            case .denied:
                return permissionHelper.canRequestPermission(for: "reminders") ? .denied : .permanentlyDenied
            case .restricted:
                return .permanentlyDenied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        }
    }
    #endif
    
    #if PERMISSION_SPEECH_RECOGNITION
    private func getSpeechRecognitionPermissionStatus() -> PermissionStatus {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "speech_recognition") ? .denied : .permanentlyDenied
        case .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_MOTION
    private func getMotionPermissionStatus() -> PermissionStatus {
        if !CMMotionActivityManager.isActivityAvailable() {
            return .permanentlyDenied
        }
        
        let status = CMMotionActivityManager.authorizationStatus()
        switch status {
        case .authorized:
            return .granted
        case .denied:
            return permissionHelper.canRequestPermission(for: "motion") ? .denied : .permanentlyDenied
        case .restricted:
            return .permanentlyDenied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    #endif
    
    #if PERMISSION_HEALTH
    private func getHealthPermissionStatus() -> PermissionStatus {
        if !HKHealthStore.isHealthDataAvailable() {
            return .permanentlyDenied
        }
        
        // Health permission status is complex as it depends on the specific data types
        // This is a simplification
        return permissionHelper.canRequestPermission(for: "health") ? .notDetermined : .permanentlyDenied
    }
    #endif
    
    #if PERMISSION_MUSIC_LIBRARY
    private func getMusicLibraryPermissionStatus() -> PermissionStatus {
        if #available(iOS 9.3, *) {
            let status = MPMediaLibrary.authorizationStatus()
            switch status {
            case .authorized:
                return .granted
            case .denied:
                return permissionHelper.canRequestPermission(for: "music_library") ? .denied : .permanentlyDenied
            case .restricted:
                return .permanentlyDenied
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .notDetermined
            }
        } else {
            return .granted
        }
    }
    #endif
    
    // MARK: - Permission Request Methods
    
    private func handlePermissionRequest(
        permission: String,
        status: Any,
        request: @escaping (@escaping (Bool) -> Void) -> Void,
        result: @escaping FlutterResult
    ) {
        if !permissionHelper.canRequestPermission(for: permission) {
            // Open settings if max attempts reached
            openAppSettings(result: result)
            return
        }
        
        permissionHelper.incrementRequestCount(for: permission)
        request { granted in
            DispatchQueue.main.async {
                result(granted)
            }
        }
    }
    
    #if PERMISSION_CAMERA
    private func requestCameraPermission(result: @escaping FlutterResult) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            handlePermissionRequest(
                permission: "camera",
                status: status,
                request: { completion in
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        completion(granted)
                    }
                },
                result: result
            )
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif

    #if PERMISSION_LOCATION
    private func requestLocationPermission(result: @escaping FlutterResult) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            result(true)
        case .notDetermined:
            pendingResults["location"] = result
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            permissionHelper.incrementRequestCount(for: "location")
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif
    
    #if PERMISSION_PHOTOS
    private func requestPhotoLibraryPermission(result: @escaping FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            result(true)
        case .limited:
            if #available(iOS 14, *) {
                result(true)
            } else {
                result(false)
            }
        case .notDetermined:
            handlePermissionRequest(
                permission: "photo_library",
                status: status,
                request: { completion in
                    PHPhotoLibrary.requestAuthorization { status in
                        if #available(iOS 14, *) {
                            completion(status == .authorized || status == .limited)
                        } else {
                            completion(status == .authorized)
                        }
                    }
                },
                result: result
            )
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif
    
    #if PERMISSION_BLUETOOTH
    private func requestBluetoothPermission(result: @escaping FlutterResult) {
        if #available(iOS 13.0, *) {
            centralManager = CBCentralManager(delegate: nil, queue: nil)
            // iOS doesn't have a specific system permission dialog for Bluetooth
            // It's managed through the app's Info.plist
            result(centralManager?.state == .poweredOn)
        } else {
            result(true)
        }
    }
    #endif
    
    #if PERMISSION_CONTACTS
    private func requestContactsPermission(result: @escaping FlutterResult) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            handlePermissionRequest(
                permission: "contacts",
                status: status,
                request: { completion in
                    self.contactStore.requestAccess(for: .contacts) { granted, _ in
                        completion(granted)
                    }
                },
                result: result
            )
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif
    
    #if PERMISSION_NOTIFICATIONS
    private func requestNotificationPermission(result: @escaping FlutterResult) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                result(true)
            case .notDetermined:
                self.handlePermissionRequest(
                    permission: "notifications",
                    status: settings.authorizationStatus,
                    request: { completion in
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            completion(granted)
                        }
                    },
                    result: result
                )
            case .denied, .ephemeral:
                result(false)
            @unknown default:
                result(false)
            }
        }
    }
    #endif
    
    #if PERMISSION_MICROPHONE
    private func requestMicrophonePermission(result: @escaping FlutterResult) {
        let status = AVAudioSession.sharedInstance().recordPermission
        switch status {
        case .granted:
            result(true)
        case .undetermined:
            handlePermissionRequest(
                permission: "microphone",
                status: status,
                request: { completion in
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        completion(granted)
                    }
                },
                result: result
            )
        case .denied:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif
    
    #if PERMISSION_CALENDAR
    private func requestCalendarPermission(result: @escaping FlutterResult) {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess:
                result(true)
            case .writeOnly:
                result(true)
            case .authorized:
                result(true)
            case .notDetermined:
                handlePermissionRequest(
                    permission: "calendar",
                    status: status,
                    request: { completion in
                        let eventStore = EKEventStore()
                        eventStore.requestFullAccessToEvents { granted, _ in
                            completion(granted)
                        }
                    },
                    result: result
                )
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        } else {
            switch status {
            case .authorized:
                result(true)
            case .notDetermined:
                handlePermissionRequest(
                    permission: "calendar",
                    status: status,
                    request: { completion in
                        let eventStore = EKEventStore()
                        eventStore.requestAccess(to: .event) { granted, _ in
                            completion(granted)
                        }
                    },
                    result: result
                )
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        }
    }
    #endif
    
    #if PERMISSION_REMINDERS
    private func requestRemindersPermission(result: @escaping FlutterResult) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess:
                result(true)
            case .writeOnly:
                result(true)
            case .authorized:
                result(true)
            case .notDetermined:
                handlePermissionRequest(
                    permission: "reminders",
                    status: status,
                    request: { completion in
                        let eventStore = EKEventStore()
                        eventStore.requestFullAccessToReminders { granted, _ in
                            completion(granted)
                        }
                    },
                    result: result
                )
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        } else {
            switch status {
            case .authorized:
                result(true)
            case .notDetermined:
                handlePermissionRequest(
                    permission: "reminders",
                    status: status,
                    request: { completion in
                        let eventStore = EKEventStore()
                        eventStore.requestAccess(to: .reminder) { granted, _ in
                            completion(granted)
                        }
                    },
                    result: result
                )
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        }
    }
    #endif
    
    #if PERMISSION_SPEECH_RECOGNITION
    private func requestSpeechRecognitionPermission(result: @escaping FlutterResult) {
        let status = SFSpeechRecognizer.authorizationStatus()
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            handlePermissionRequest(
                permission: "speech_recognition",
                status: status,
                request: { completion in
                    SFSpeechRecognizer.requestAuthorization { status in
                        completion(status == .authorized)
                    }
                },
                result: result
            )
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif
    
    #if PERMISSION_MOTION
    private func requestMotionPermission(result: @escaping FlutterResult) {
        guard CMMotionActivityManager.isActivityAvailable() else {
            result(false)
            return
        }
        
        let status = CMMotionActivityManager.authorizationStatus()
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            handlePermissionRequest(
                permission: "motion",
                status: status,
                request: { completion in
                    let activityManager = CMMotionActivityManager()
                    let today = Date()
                    activityManager.queryActivityStarting(from: today, to: today, to: .main) { _, error in
                        completion(error == nil)
                    }
                },
                result: result
            )
        case .denied, .restricted:
            result(false)
        @unknown default:
            result(false)
        }
    }
    #endif
    
    #if PERMISSION_HEALTH
    private func requestHealthPermission(result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(false)
            return
        }
        
        handlePermissionRequest(
            permission: "health",
            status: "unknown",
            request: { completion in
                let healthStore = HKHealthStore()
                // Example: Request permissions for step count and body mass
                let typesToShare: Set<HKSampleType> = Set([
                    HKObjectType.quantityType(forIdentifier: .stepCount),
                    HKObjectType.quantityType(forIdentifier: .bodyMass)
                ].compactMap { $0 })

                let typesToRead: Set<HKSampleType> = Set([
                    HKObjectType.quantityType(forIdentifier: .stepCount),
                    HKObjectType.quantityType(forIdentifier: .bodyMass)
                ].compactMap { $0 })

                healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
                    completion(success)
                }
            },
            result: result
        )
    }
    #endif
    
    #if PERMISSION_MUSIC_LIBRARY
    private func requestMusicLibraryPermission(result: @escaping FlutterResult) {
        if #available(iOS 9.3, *) {
            let status = MPMediaLibrary.authorizationStatus()
            switch status {
            case .authorized:
                result(true)
            case .notDetermined:
                handlePermissionRequest(
                    permission: "music_library",
                    status: status,
                    request: { completion in
                        MPMediaLibrary.requestAuthorization { status in
                            completion(status == .authorized)
                        }
                    },
                    result: result
                )
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        } else {
            result(true)
        }
    }
    #endif
}
