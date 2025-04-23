package com.example.permission_master

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class PermissionMasterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val requestCallbacks = mutableMapOf<Int, MethodChannel.Result>()
    private lateinit var storage: GetStorage

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "permission_master")
        channel.setMethodCallHandler(this)
        storage = GetStorage(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener { requestCode, permissions, grantResults ->
            handlePermissionResult(requestCode, permissions, grantResults)
            true
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
        requestCallbacks.clear()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val permissionHelper = activity?.let { PermissionHelper(it) }
            ?: return result.error("ACTIVITY_NULL", "Activity is null", null)

        Log.d("PermissionMaster", "Method called: ${call.method}")

        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "requestCameraPermission" -> requestSinglePermission(permissionHelper, Manifest.permission.CAMERA, result)
            "requestLocationPermission" -> {
                val permissions = PermissionVersionManager.getLocationPermissions()
                requestPermissionGroup(permissionHelper, permissions, result)
            }
            "requestStoragePermission" -> {
                val permissions = PermissionVersionManager.getStoragePermissions()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    // For Android 13+, request permissions one by one
                    requestPermissionsSequentially(permissionHelper, permissions, result)
                } else {
                    // For older versions, request as a group
                    requestPermissionGroup(permissionHelper, permissions, result)
                }
            }
            "requestManageExternalStorage" -> requestManageExternalStorage(result)
            "requestBluetoothPermission" -> {
                val permissions = PermissionVersionManager.getBluetoothPermissions()
                requestPermissionGroup(permissionHelper, permissions, result)
            }
            "requestSensorsPermission" -> requestSinglePermission(permissionHelper, Manifest.permission.BODY_SENSORS, result)
            "requestMicrophonePermission" -> requestSinglePermission(permissionHelper, Manifest.permission.RECORD_AUDIO, result)
            "requestNotificationPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    requestSinglePermission(permissionHelper, Manifest.permission.POST_NOTIFICATIONS, result)
                } else {
                    result.success(true)
                }
            }
            "requestSmsPermission" -> requestSinglePermission(permissionHelper, Manifest.permission.SEND_SMS, result)
            "requestContactsPermission" -> requestSinglePermission(permissionHelper, Manifest.permission.READ_CONTACTS, result)
            "requestCalendarPermission" -> requestSinglePermission(permissionHelper, Manifest.permission.READ_CALENDAR, result)
            "requestPhonePermission" -> requestSinglePermission(permissionHelper, Manifest.permission.READ_PHONE_STATE, result)
            "requestNearbyDevicesPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    requestSinglePermission(permissionHelper, Manifest.permission.NEARBY_WIFI_DEVICES, result)
                } else {
                    result.success(true)
                }
            }
            "requestActivityRecognitionPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    requestSinglePermission(permissionHelper, Manifest.permission.ACTIVITY_RECOGNITION, result)
                } else {
                    result.success(true)
                }
            }
            "requestAlarmPermission" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    requestSinglePermission(permissionHelper, Manifest.permission.SCHEDULE_EXACT_ALARM, result)
                } else {
                    result.success(true)
                }
            }
            "requestWifiPermission" -> requestSinglePermission(permissionHelper, Manifest.permission.ACCESS_WIFI_STATE, result)
            "checkPermissionStatus" -> checkPermissionStatus(call, permissionHelper, result)
            "checkMultiplePermissions" -> checkMultiplePermissions(call, permissionHelper, result)
            "requestDynamicPermissions" -> requestDynamicPermissions(call, permissionHelper, result)
            "openAppSettings" -> {
                try {
                    Log.d("PermissionMaster", "Opening app settings requested")
                    val success = permissionHelper.openAppSettings()
                    if (success) {
                        Log.d("PermissionMaster", "App settings opened successfully")
                        result.success(true)
                    } else {
                        Log.e("PermissionMaster", "Failed to open app settings")
                        result.success(false)
                    }
                } catch (e: Exception) {
                    Log.e("PermissionMaster", "Error opening app settings: ${e.message}", e)
                    result.error("SETTINGS_ERROR", "Error opening app settings: ${e.message}", null)
                }
            }
            "storage_write" -> {
                val key = call.argument<String>("key") ?: return result.error("INVALID_KEY", "Key cannot be null", null)
                val value = call.argument<Any>("value") ?: return result.error("INVALID_VALUE", "Value cannot be null", null)
                when (value) {
                    is Int -> storage.write(key, value)
                    is Long -> storage.write(key, value)
                    is Float -> storage.write(key, value)
                    is String -> storage.write(key, value)
                    is Boolean -> storage.write(key, value)
                    is HashMap<*, *> -> storage.write(key, value as HashMap<String, Any>)
                    else -> return result.error("UNSUPPORTED_TYPE", "Unsupported value type: ${value::class.java}", null)
                }
                result.success(true)
            }
            "storage_read" -> {
                val key = call.argument<String>("key") ?: return result.error("INVALID_KEY", "Key cannot be null", null)
                val defaultValue = call.argument<Any>("defaultValue") ?: return result.error("INVALID_DEFAULT", "Default value cannot be null", null)
                when (defaultValue) {
                    is Int -> result.success(storage.read(key, defaultValue))
                    is Long -> result.success(storage.read(key, defaultValue))
                    is Float -> result.success(storage.read(key, defaultValue))
                    is String -> result.success(storage.read(key, defaultValue))
                    is Boolean -> result.success(storage.read(key, defaultValue))
                    is HashMap<*, *> -> result.success(storage.read(key, defaultValue as HashMap<String, Any>))
                    else -> return result.error("UNSUPPORTED_TYPE", "Unsupported default value type: ${defaultValue::class.java}", null)
                }
            }
            "storage_contains" -> {
                val key = call.argument<String>("key") ?: return result.error("INVALID_KEY", "Key cannot be null", null)
                result.success(storage.contains(key))
            }
            "storage_remove" -> {
                val key = call.argument<String>("key") ?: return result.error("INVALID_KEY", "Key cannot be null", null)
                storage.remove(key)
                result.success(true)
            }
            "storage_clear" -> {
                storage.clear()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun requestSinglePermission(helper: PermissionHelper, permission: String, result: MethodChannel.Result) {
        when (val permissionResult = helper.requestPermission(permission)) {
            is PermissionResult.Granted -> result.success(true)
            is PermissionResult.Denied -> {
                requestCallbacks[permission.hashCode() and 0xFFFF] = result
            }
            is PermissionResult.ShowRationale -> channel.invokeMethod("onShowRationale", mapOf("permission" to permission))
            is PermissionResult.OpenSettings -> channel.invokeMethod("openAppSettings", null)
            is PermissionResult.Error -> result.error("PERMISSION_ERROR", permissionResult.error.message, null)
        }
    }

    private fun requestPermissionGroup(helper: PermissionHelper, permissions: Array<String>, result: MethodChannel.Result) {
        helper.requestPermissionGroup(permissions) { results ->
            val statusMap = results.mapValues { entry ->
                when (entry.value) {
                    is PermissionResult.Granted -> "GRANTED"
                    is PermissionResult.Denied -> {
                        requestCallbacks[permissions.hashCode() and 0xFFFF] = result
                        "DENIED"
                    }
                    is PermissionResult.ShowRationale -> "SHOW_RATIONALE"
                    is PermissionResult.OpenSettings -> "OPEN_SETTINGS"
                    is PermissionResult.Error -> "ERROR"
                }
            }
            result.success(statusMap)
        }
    }

    private fun requestManageExternalStorage(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            activity?.let { activity ->
                if (Environment.isExternalStorageManager()) {
                    result.success(true)
                } else {
                    val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                    activity.startActivity(intent)
                    result.success(false)
                }
            } ?: result.error("ACTIVITY_NULL", "Activity is null", null)
        } else {
            result.success(true)
        }
    }

    private fun checkPermissionStatus(call: MethodCall, helper: PermissionHelper, result: MethodChannel.Result) {
        val permission = call.argument<String>("permission")
            ?: return result.error("INVALID_ARGUMENT", "Permission string cannot be null", null)
        val status = helper.getPermissionStatus(permission)
        result.success(status.name)
    }

    private fun checkMultiplePermissions(call: MethodCall, helper: PermissionHelper, result: MethodChannel.Result) {
        val permissions = call.argument<List<String>>("permissions")
            ?: return result.error("INVALID_ARGUMENT", "Permissions list cannot be null", null)
        val statusMap = permissions.associateWith { helper.getPermissionStatus(it).name }
        result.success(statusMap)
    }

    private fun requestDynamicPermissions(call: MethodCall, helper: PermissionHelper, result: MethodChannel.Result) {
        val permissions = call.argument<List<String>>("permissions")
            ?: return result.error("INVALID_ARGUMENT", "Permissions list cannot be null", null)

        val permissionsArray = permissions.toTypedArray()
        helper.requestPermissionGroup(permissionsArray) { results ->
            val statusMap = results.mapValues { entry ->
                when (entry.value) {
                    is PermissionResult.Granted -> "GRANTED"
                    is PermissionResult.Denied -> {
                        requestCallbacks[permissionsArray.hashCode() and 0xFFFF] = result
                        "DENIED"
                    }
                    is PermissionResult.ShowRationale -> "SHOW_RATIONALE"
                    is PermissionResult.OpenSettings -> "OPEN_SETTINGS"
                    is PermissionResult.Error -> "ERROR"
                }
            }
            result.success(statusMap)
        }
    }

    private fun requestPermissionsSequentially(helper: PermissionHelper, permissions: Array<String>, result: MethodChannel.Result) {
        val results = mutableMapOf<String, String>()
        var currentIndex = 0

        fun requestNextPermission() {
            if (currentIndex >= permissions.size) {
                result.success(results)
                return
            }

            val permission = permissions[currentIndex]
            val permissionResult = helper.requestPermission(permission)
            
            when (permissionResult) {
                is PermissionResult.Granted -> {
                    results[permission] = "GRANTED"
                    currentIndex++
                    requestNextPermission()
                }
                is PermissionResult.Denied -> {
                    results[permission] = "DENIED"
                    currentIndex++
                    requestNextPermission()
                }
                is PermissionResult.ShowRationale -> {
                    results[permission] = "SHOW_RATIONALE"
                    channel.invokeMethod("onShowRationale", mapOf("permission" to permission))
                    currentIndex++
                    requestNextPermission()
                }
                is PermissionResult.OpenSettings -> {
                    results[permission] = "OPEN_SETTINGS"
                    channel.invokeMethod("openAppSettings", null)
                    currentIndex++
                    requestNextPermission()
                }
                is PermissionResult.Error -> {
                    results[permission] = "ERROR"
                    currentIndex++
                    requestNextPermission()
                }
            }
        }

        requestNextPermission()
    }

    private fun handlePermissionResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        val result = requestCallbacks[requestCode] ?: return

        try {
            // For storage permissions on Android 13+, we need to check all results
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && 
                permissions.any { it.startsWith("android.permission.READ_MEDIA_") }) {
                val results = mutableMapOf<String, String>()
                var allGranted = true
                var anyDenied = false
                
                for (i in permissions.indices) {
                    val permission = permissions[i]
                    val grantResult = grantResults[i]
                    val status = if (grantResult == PackageManager.PERMISSION_GRANTED) "GRANTED" else "DENIED"
                    results[permission] = status
                    
                    if (grantResult != PackageManager.PERMISSION_GRANTED) {
                        allGranted = false
                        anyDenied = true
                    }
                }
                
                if (allGranted) {
                    result.success(true)
                } else if (anyDenied) {
                    activity?.let { activity ->
                        var shouldOpenSettings = false
                        for (permission in permissions) {
                            if (!ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)) {
                                shouldOpenSettings = true
                                break
                            }
                        }
                        if (shouldOpenSettings) {
                            channel.invokeMethod("openAppSettings", null)
                        }
                        result.success(results)
                    } ?: result.success(results)
                }
            } else {
                // For other permissions or older Android versions
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    result.success(true)
                } else {
                    activity?.let { activity ->
                        var shouldOpenSettings = false
                        for (permission in permissions) {
                            if (!ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)) {
                                shouldOpenSettings = true
                                break
                            }
                        }
                        if (shouldOpenSettings) {
                            channel.invokeMethod("openAppSettings", null)
                        }
                        result.success(false)
                    } ?: result.success(false)
                }
            }
        } catch (e: Exception) {
            Log.e("PermissionMaster", "Error handling permission result: ${e.message}", e)
            try {
                result.error("PERMISSION_ERROR", "Error handling permission result: ${e.message}", null)
            } catch (e2: Exception) {
                Log.e("PermissionMaster", "Failed to send error result: ${e2.message}", e2)
            }
        } finally {
            requestCallbacks.remove(requestCode)
        }
    }

    private fun openAppSettings() {
        activity?.let { activity ->
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.fromParts("package", activity.packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
        }
    }
}
