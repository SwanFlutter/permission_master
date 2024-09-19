import Flutter
import UIKit
import AVFoundation
import CoreLocation
import Photos

public class PermissionMasterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?

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

    // Delegate method to handle permission changes for location
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            channel.invokeMethod("onPermissionResult", arguments: ["requestCode": "location", "granted": true])
        default:
            channel.invokeMethod("onPermissionResult", arguments: ["requestCode": "location", "granted": false])
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
}
