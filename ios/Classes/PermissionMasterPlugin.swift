import Flutter
import UIKit
import AVFoundation
import CoreLocation
import Photos
import CoreBluetooth
import Contacts
import UserNotifications

public class PermissionMasterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, CBCentralManagerDelegate {
    var locationManager: CLLocationManager?
    var bluetoothManager: CBCentralManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "permission_master", binaryMessenger: registrar.messenger())
        let instance = PermissionMasterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestCameraPermission":
            requestCameraPermission(result: result)
        case "requestLocationPermission":
            requestLocationPermission(result: result)
        case "requestMicrophonePermission":
            requestMicrophonePermission(result: result)
        case "requestPhotosPermission":
            requestPhotosPermission(result: result)
        case "requestBluetoothPermission":
            requestBluetoothPermission(result: result)
        case "requestContactsPermission":
            requestContactsPermission(result: result)
        case "requestNotificationPermission":
            requestNotificationPermission(result: result)
        case "requestProximitySensorPermission":
            requestProximitySensorPermission(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // Request camera permission
    private func requestCameraPermission(result: @escaping FlutterResult) {
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthStatus {
        case .authorized:
            result(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                result(granted)
            }
        default:
            result(false)
        }
    }

    // Request location permission
    private func requestLocationPermission(result: @escaping FlutterResult) {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        let locationAuthStatus = CLLocationManager.authorizationStatus()

        switch locationAuthStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            result(true)
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization() // درخواست مجوز
        default:
            result(false)
        }
    }

    // Request microphone permission
    private func requestMicrophonePermission(result: @escaping FlutterResult) {
        let microphoneAuthStatus = AVAudioSession.sharedInstance().recordPermission
        switch microphoneAuthStatus {
        case .granted:
            result(true)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                result(granted)
            }
        default:
            result(false)
        }
    }

    // Request permission to access photos
    private func requestPhotosPermission(result: @escaping FlutterResult) {
        let photosAuthStatus = PHPhotoLibrary.authorizationStatus()
        switch photosAuthStatus {
        case .authorized:
            result(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                result(status == .authorized)
            }
        default:
            result(false)
        }
    }

    // Request Bluetooth permission
    private func requestBluetoothPermission(result: @escaping FlutterResult) {
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
        if bluetoothManager?.state == .poweredOn {
            result(true)
        } else {
            bluetoothManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            channel.invokeMethod("onPermissionResult", arguments: ["requestCode": "bluetooth", "granted": true])
        } else {
            channel.invokeMethod("onPermissionResult", arguments: ["requestCode": "bluetooth", "granted": false])
        }
    }

    // Request Contacts permission
    private func requestContactsPermission(result: @escaping FlutterResult) {
        let contactAuthStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch contactAuthStatus {
        case .authorized:
            result(true)
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, _ in
                result(granted)
            }
        default:
            result(false)
        }
    }

    // Request Notification permission
    private func requestNotificationPermission(result: @escaping FlutterResult) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                result(granted)
            }
        } else {
            result(false)
        }
    }

    // Request Proximity Sensor permission (this is a sensor, no explicit permission is required in iOS)
    private func requestProximitySensorPermission(result: @escaping FlutterResult) {
        UIDevice.current.isProximityMonitoringEnabled = true
        result(true)
    }
}
