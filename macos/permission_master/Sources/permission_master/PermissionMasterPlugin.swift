import Cocoa
import FlutterMacOS
import Photos
import CoreLocation
import Contacts
import CoreBluetooth
import UserNotifications
import AVFoundation
import EventKit
import Speech

public class PermissionMasterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let contactStore = CNContactStore()
    private var centralManager: CBCentralManager?
    private var eventStore: EKEventStore?
    private let storage = GetStorage()
    
    // Dictionary to store pending results
    private var pendingResults = [String: FlutterResult]()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "permission_master", binaryMessenger: registrar.messenger)
        let instance = PermissionMasterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("PermissionMaster: Method called: \(call.method)")
        
        switch call.method {
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
        case "requestCameraPermission":
            requestCameraPermission(result: result)
        case "requestLocationPermission":
            requestLocationPermission(result: result)
        case "requestStoragePermission", "requestPhotoLibraryPermission":
            requestPhotoLibraryPermission(result: result)
        case "requestBluetoothPermission":
            requestBluetoothPermission(result: result)
        case "requestContactsPermission":
            requestContactsPermission(result: result)
        case "requestNotificationPermission":
            requestNotificationPermission(result: result)
        case "requestMicrophonePermission":
            requestMicrophonePermission(result: result)
        case "requestCalendarPermission":
            requestCalendarPermission(result: result)
        case "requestRemindersPermission":
            requestRemindersPermission(result: result)
        case "requestSpeechRecognitionPermission":
            requestSpeechRecognitionPermission(result: result)
        case "requestMusicLibraryPermission":
            result("NOT_SUPPORTED")
        case "requestMusicPermission":
            result("NOT_SUPPORTED")
        // macOS specific methods with Mac suffix
        case "requestCameraPermissionMac":
            requestCameraPermission(result: result)
        case "requestMicrophonePermissionMac":
            requestMicrophonePermission(result: result)
        case "requestLocationPermissionMac":
            requestLocationPermission(result: result)
        case "requestPhotoLibraryPermissionMac":
            requestPhotoLibraryPermission(result: result)
        case "requestContactsPermissionMac":
            requestContactsPermission(result: result)
        case "requestNotificationPermissionMac":
            requestNotificationPermission(result: result)
        case "requestBluetoothPermissionMac":
            requestBluetoothPermission(result: result)
        case "requestCalendarPermissionMac":
            requestCalendarPermission(result: result)
        case "requestRemindersPermissionMac":
            requestRemindersPermission(result: result)
        case "requestSpeechRecognitionPermissionMac":
            requestSpeechRecognitionPermission(result: result)
        case "checkCameraPermissionMac":
            checkCameraPermission(result: result)
        case "checkMicrophonePermissionMac":
            checkMicrophonePermission(result: result)
        case "checkLocationPermissionMac":
            checkLocationPermission(result: result)
        case "checkPhotoLibraryPermissionMac":
            checkPhotoLibraryPermission(result: result)
        case "checkContactsPermissionMac":
            checkContactsPermission(result: result)
        case "checkNotificationPermissionMac":
            checkNotificationPermission(result: result)
        case "checkBluetoothPermissionMac":
            checkBluetoothPermission(result: result)
        case "checkCalendarPermissionMac":
            checkCalendarPermission(result: result)
        case "checkRemindersPermissionMac":
            checkRemindersPermission(result: result)
        case "checkSpeechRecognitionPermissionMac":
            checkSpeechRecognitionPermission(result: result)
        case "openAppSettingsMac":
            openAppSettings(result: result)
        case "requestActivityRecognitionPermission":
            result("NOT_SUPPORTED")
        case "requestPhonePermission":
            result("NOT_SUPPORTED")
        case "requestSmsPermission":
            result("NOT_SUPPORTED")
        case "requestWifiPermission":
            result("NOT_SUPPORTED")
        case "requestNearbyDevicesPermission":
            result("NOT_SUPPORTED")
        case "requestAlarmPermission":
            result("NOT_SUPPORTED")
        case "requestSensorsPermission":
            result("NOT_SUPPORTED")
        case "requestMotionPermission":
            result("NOT_SUPPORTED")
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
    
    // MARK: - Permission Status Enum
    enum PermissionStatus: String {
        case granted = "granted"
        case denied = "denied"
        case notDetermined = "not_determined"
        case restricted = "restricted"
        case permanentlyDenied = "permanently_denied"
        case notSupported = "not_supported"
    }
    
    // MARK: - Check Permission Status
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
                requestCameraPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
            case "location", "fine_location", "coarse_location":
                requestLocationPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
            case "storage", "photos", "photo_library":
                requestPhotoLibraryPermission(result: { response in
                    if let boolResponse = response as? Bool {
                        results[permission] = boolResponse ? "GRANTED" : "DENIED"
                    } else {
                        results[permission] = "ERROR"
                    }
                    dispatchGroup.leave()
                })
            default:
                results[permission] = "NOT_SUPPORTED"
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            result(results)
        }
    }
    
    // MARK: - Get Permission Status
    private func getPermissionStatus(for permission: String) -> PermissionStatus {
        switch permission {
        case "camera":
            return getCameraPermissionStatus()
        case "location", "fine_location", "coarse_location":
            return getLocationPermissionStatus()
        case "storage", "photos", "photo_library":
            return getPhotoLibraryPermissionStatus()
        case "bluetooth":
            return getBluetoothPermissionStatus()
        case "contacts":
            return getContactsPermissionStatus()
        case "notification", "notifications":
            return getNotificationPermissionStatus()
        case "microphone":
            return getMicrophonePermissionStatus()
        case "calendar":
            return getCalendarPermissionStatus()
        case "reminders":
            return getRemindersPermissionStatus()
        case "speech":
            return getSpeechRecognitionPermissionStatus()
        default:
            return .notSupported
        }
    }
    
    // MARK: - Camera Permission
    private func requestCameraPermission(result: @escaping FlutterResult) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    result(granted)
                }
            }
        case .denied, .restricted:
            result("OPEN_SETTINGS")
        @unknown default:
            result(false)
        }
    }
    
    private func getCameraPermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return .granted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    // MARK: - Individual Permission Check Methods
    private func checkCameraPermission(result: @escaping FlutterResult) {
        let status = getCameraPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkMicrophonePermission(result: @escaping FlutterResult) {
        let status = getMicrophonePermissionStatus()
        result(status.rawValue)
    }
    
    private func checkLocationPermission(result: @escaping FlutterResult) {
        let status = getLocationPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkPhotoLibraryPermission(result: @escaping FlutterResult) {
        let status = getPhotoLibraryPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkContactsPermission(result: @escaping FlutterResult) {
        let status = getContactsPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkNotificationPermission(result: @escaping FlutterResult) {
        let status = getNotificationPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkBluetoothPermission(result: @escaping FlutterResult) {
        let status = getBluetoothPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkCalendarPermission(result: @escaping FlutterResult) {
        let status = getCalendarPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkRemindersPermission(result: @escaping FlutterResult) {
        let status = getRemindersPermissionStatus()
        result(status.rawValue)
    }
    
    private func checkSpeechRecognitionPermission(result: @escaping FlutterResult) {
        let status = getSpeechRecognitionPermissionStatus()
        result(status.rawValue)
    }
    
    // MARK: - Location Permission
    private func requestLocationPermission(result: @escaping FlutterResult) {
        let status: CLAuthorizationStatus
        if #available(macOS 11.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            result(true)
        case .notDetermined:
            pendingResults["location"] = result
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            result("OPEN_SETTINGS")
        @unknown default:
            result(false)
        }
    }
    
    private func getLocationPermissionStatus() -> PermissionStatus {
        let status: CLAuthorizationStatus
        if #available(macOS 11.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return .granted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let result = pendingResults["location"] {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                result(true)
            case .denied, .restricted:
                result(false)
            default:
                break
            }
            pendingResults.removeValue(forKey: "location")
        }
    }
    
    // MARK: - Photo Library Permission
    private func requestPhotoLibraryPermission(result: @escaping FlutterResult) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            result(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    result(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            result("OPEN_SETTINGS")
        @unknown default:
            result(false)
        }
    }
    
    private func getPhotoLibraryPermissionStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            return .granted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    // MARK: - Bluetooth Permission
    private func requestBluetoothPermission(result: @escaping FlutterResult) {
        if #available(macOS 10.15, *) {
            if centralManager == nil {
                centralManager = CBCentralManager(delegate: self, queue: nil)
            }
            
            let status = centralManager?.authorization ?? .notDetermined
            
            switch status {
            case .allowedAlways:
                result(true)
            case .denied, .restricted:
                result("OPEN_SETTINGS")
            case .notDetermined:
                pendingResults["bluetooth"] = result
                // Bluetooth permission is requested automatically when CBCentralManager is initialized
            @unknown default:
                result(false)
            }
        } else {
            result(true) // Older versions don't require explicit permission
        }
    }
    
    private func getBluetoothPermissionStatus() -> PermissionStatus {
        if #available(macOS 10.15, *) {
            if centralManager == nil {
                centralManager = CBCentralManager(delegate: self, queue: nil)
            }
            
            let status = centralManager?.authorization ?? .notDetermined
            
            switch status {
            case .allowedAlways:
                return .granted
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            case .notDetermined:
                return .notDetermined
            @unknown default:
                return .denied
            }
        } else {
            return .granted // Older versions don't require explicit permission
        }
    }
    
    // MARK: - Contacts Permission
    private func requestContactsPermission(result: @escaping FlutterResult) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    result(granted)
                }
            }
        case .denied, .restricted:
            result("OPEN_SETTINGS")
        @unknown default:
            result(false)
        }
    }
    
    private func getContactsPermissionStatus() -> PermissionStatus {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .authorized:
            return .granted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    // MARK: - Notification Permission
    private func requestNotificationPermission(result: @escaping FlutterResult) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    result(true)
                case .notDetermined:
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            result(granted)
                        }
                    }
                case .denied:
                    result("OPEN_SETTINGS")
                @unknown default:
                    result(false)
                }
            }
        }
    }
    
    private func getNotificationPermissionStatus() -> PermissionStatus {
        var status: PermissionStatus = .notDetermined
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                status = .granted
            case .denied:
                status = .denied
            case .notDetermined:
                status = .notDetermined
            @unknown default:
                status = .denied
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        return status
    }
    
    // MARK: - Microphone Permission
    private func requestMicrophonePermission(result: @escaping FlutterResult) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    result(granted)
                }
            }
        case .denied, .restricted:
            result("OPEN_SETTINGS")
        @unknown default:
            result(false)
        }
    }
    
    private func getMicrophonePermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch status {
        case .authorized:
            return .granted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    // MARK: - Calendar Permission
    private func requestCalendarPermission(result: @escaping FlutterResult) {
        if eventStore == nil {
            eventStore = EKEventStore()
        }
        
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if #available(macOS 14.0, *) {
            switch status {
            case .fullAccess:
                result(true)
            case .writeOnly:
                result(true)
            case .authorized:
                result(true)
            case .notDetermined:
                eventStore?.requestFullAccessToEvents { granted, _ in
                    DispatchQueue.main.async {
                        result(granted)
                    }
                }
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
                eventStore?.requestAccess(to: .event) { granted, _ in
                    DispatchQueue.main.async {
                        result(granted)
                    }
                }
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        }
    }
    
    private func getCalendarPermissionStatus() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        if #available(macOS 14.0, *) {
            switch status {
            case .fullAccess, .authorized:
                return .granted
            case .writeOnly:
                return .granted
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            @unknown default:
                return .denied
            }
        } else {
            switch status {
            case .authorized:
                return .granted
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            @unknown default:
                return .denied
            }
        }
    }
    
    // MARK: - Reminders Permission
    private func requestRemindersPermission(result: @escaping FlutterResult) {
        if eventStore == nil {
            eventStore = EKEventStore()
        }
        
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        if #available(macOS 14.0, *) {
            switch status {
            case .fullAccess:
                result(true)
            case .writeOnly:
                result(true)
            case .authorized:
                result(true)
            case .notDetermined:
                eventStore?.requestFullAccessToReminders { granted, _ in
                    DispatchQueue.main.async {
                        result(granted)
                    }
                }
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
                eventStore?.requestAccess(to: .reminder) { granted, _ in
                    DispatchQueue.main.async {
                        result(granted)
                    }
                }
            case .denied, .restricted:
                result(false)
            @unknown default:
                result(false)
            }
        }
    }
    
    private func getRemindersPermissionStatus() -> PermissionStatus {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        if #available(macOS 14.0, *) {
            switch status {
            case .fullAccess, .authorized:
                return .granted
            case .writeOnly:
                return .granted
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            @unknown default:
                return .denied
            }
        } else {
            switch status {
            case .authorized:
                return .granted
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .restricted:
                return .restricted
            @unknown default:
                return .denied
            }
        }
    }
    
    // MARK: - Speech Recognition Permission
    private func requestSpeechRecognitionPermission(result: @escaping FlutterResult) {
        let status = SFSpeechRecognizer.authorizationStatus()
        
        switch status {
        case .authorized:
            result(true)
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    result(newStatus == .authorized)
                }
            }
        case .denied, .restricted:
            result("OPEN_SETTINGS")
        @unknown default:
            result(false)
        }
    }
    
    private func getSpeechRecognitionPermissionStatus() -> PermissionStatus {
        let status = SFSpeechRecognizer.authorizationStatus()
        
        switch status {
        case .authorized:
            return .granted
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
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
    
    // MARK: - Open App Settings
    private func openAppSettings(result: @escaping FlutterResult) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy") {
            NSWorkspace.shared.open(url)
            result(true)
        } else {
            result(false)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension PermissionMasterPlugin: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if let result = pendingResults["bluetooth"] {
            if #available(macOS 10.15, *) {
                switch central.authorization {
                case .allowedAlways:
                    result(true)
                case .denied, .restricted:
                    result(false)
                case .notDetermined:
                    break // Wait for authorization change
                @unknown default:
                    result(false)
                }
            } else {
                result(true)
            }
            
            if central.authorization != .notDetermined {
                pendingResults.removeValue(forKey: "bluetooth")
            }
        }
    }
}
