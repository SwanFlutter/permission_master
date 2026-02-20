package com.example.permission_master

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
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

class PermissionMasterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val requestCallbacks = mutableMapOf<Int, MethodChannel.Result>()
    private lateinit var storage: GetStorage

    private val sequentialPermissionQueue = mutableListOf<Pair<String, MethodChannel.Result>>()
    private var isProcessingPermissionQueue = false

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
        sequentialPermissionQueue.clear()
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
                requestPermissionsSequentially(permissionHelper, permissions, result)
            }
            "requestStoragePermission" -> {
                val permissions = PermissionVersionManager.getStoragePermissions()
                Log.d("PermissionMaster", "Requesting storage permissions for Android ${Build.VERSION.SDK_INT}: ${permissions.joinToString()}")
                requestPermissionsSequentially(permissionHelper, permissions, result)
            }
            "requestManageExternalStorage" -> requestManageExternalStorage(result)
            "requestBluetoothPermission" -> {
                val permissions = PermissionVersionManager.getBluetoothPermissions()
                requestPermissionsSequentially(permissionHelper, permissions, result)
            }
            "requestSensorsPermission" -> {
                Log.d("PermissionMaster", "Requesting BODY_SENSORS permission on Android ${Build.VERSION.SDK_INT}")

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
                    // Check if already granted
                    if (permissionHelper.isPermissionGranted(Manifest.permission.BODY_SENSORS)) {
                        Log.d("PermissionMaster", "BODY_SENSORS already granted")
                        savePermissionStatus(Manifest.permission.BODY_SENSORS, true)
                        result.success(true)
                        return
                    }

                    // Check device capabilities
                    val packageManager = activity?.packageManager
                    val hasHeartRateFeature = packageManager?.hasSystemFeature(PackageManager.FEATURE_SENSOR_HEART_RATE) ?: false
                    val hasStepCounterFeature = packageManager?.hasSystemFeature(PackageManager.FEATURE_SENSOR_STEP_COUNTER) ?: false

                    Log.d("PermissionMaster", "Device features - HeartRate: $hasHeartRateFeature, StepCounter: $hasStepCounterFeature")

                    // If device doesn't have required features, this permission is not applicable
                    if (!hasHeartRateFeature && !hasStepCounterFeature) {
                        Log.w("PermissionMaster", "Device doesn't support body sensors, skipping permission")
                        savePermissionStatus(Manifest.permission.BODY_SENSORS, true)
                        result.success(true)
                        return
                    }

                    val requestCount = permissionHelper.getRequestCount(Manifest.permission.BODY_SENSORS)

                    // Since this permission is being automatically denied by system,
                    // we'll try only once and then accept the system's decision
                    if (requestCount >= 1) {
                        Log.w("PermissionMaster", "BODY_SENSORS already attempted, system restrictions may apply")
                        savePermissionStatus(Manifest.permission.BODY_SENSORS, false)
                        result.success(false)
                        return
                    }

                    Log.d("PermissionMaster", "Attempting BODY_SENSORS permission request")
                    requestSinglePermission(permissionHelper, Manifest.permission.BODY_SENSORS, result)

                } else {
                    Log.d("PermissionMaster", "BODY_SENSORS not needed for Android ${Build.VERSION.SDK_INT}")
                    savePermissionStatus(Manifest.permission.BODY_SENSORS, true)
                    result.success(true)
                }
            }
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
                Log.d("PermissionMaster", "Request Alarm Permission called")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (canScheduleExactAlarms()) {
                        Log.d("PermissionMaster", "Alarm permission already granted")
                        savePermissionStatus(Manifest.permission.SCHEDULE_EXACT_ALARM, true)
                        result.success(true)
                    } else {
                        Log.d("PermissionMaster", "Need to request alarm permission")
                        val requestCode = Manifest.permission.SCHEDULE_EXACT_ALARM.hashCode() and 0xFFFF
                        requestCallbacks[requestCode] = result

                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:${activity?.packageName}")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            activity?.startActivity(intent)
                            channel.invokeMethod("onAlarmPermissionNeeded", null)
                        } catch (e: Exception) {
                            Log.e("PermissionMaster", "Error opening alarm settings: ${e.message}", e)
                            result.error("ALARM_SETTINGS_ERROR", "Failed to open alarm settings: ${e.message}", null)
                        }
                    }
                } else {
                    Log.d("PermissionMaster", "Alarm permission not needed for this Android version")
                    savePermissionStatus(Manifest.permission.SCHEDULE_EXACT_ALARM, true)
                    result.success(true)
                }
            }
            "requestHealthPermission" -> {
                Log.d("PermissionMaster", "Request Health Permission called")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    // Android 14+ (API 34+) supports Health Connect
                    // Health Connect requires special handling through Health Connect API
                    // For now, we'll direct users to Health Connect settings
                    try {
                        val intent = Intent("androidx.health.ACTION_HEALTH_CONNECT_SETTINGS").apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        activity?.startActivity(intent)
                        result.success("OPEN_SETTINGS")
                    } catch (e: Exception) {
                        Log.e("PermissionMaster", "Health Connect not available: ${e.message}", e)
                        result.error("HEALTH_NOT_AVAILABLE", "Health Connect is not available on this device", null)
                    }
                } else {
                    Log.d("PermissionMaster", "Health permission not supported for Android ${Build.VERSION.SDK_INT}")
                    result.success("NOT_SUPPORTED")
                }
            }
            "canScheduleExactAlarms" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val hasPermission = canScheduleExactAlarms()
                    savePermissionStatus(Manifest.permission.SCHEDULE_EXACT_ALARM, hasPermission)
                    result.success(hasPermission)
                } else {
                    savePermissionStatus(Manifest.permission.SCHEDULE_EXACT_ALARM, true)
                    result.success(true)
                }
            }
            "checkAlarmPermissionAfterSettings" -> {
                Log.d("PermissionMaster", "Check alarm permission after settings called")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val hasPermission = canScheduleExactAlarms()
                    Log.d("PermissionMaster", "Alarm permission status after settings: $hasPermission")

                    savePermissionStatus(Manifest.permission.SCHEDULE_EXACT_ALARM, hasPermission)

                    val requestCode = Manifest.permission.SCHEDULE_EXACT_ALARM.hashCode() and 0xFFFF
                    val storedResult = requestCallbacks.remove(requestCode)

                    if (storedResult != null) {
                        Log.d("PermissionMaster", "Returning result to stored callback")
                        storedResult.success(hasPermission)
                    }

                    result.success(hasPermission)
                } else {
                    Log.d("PermissionMaster", "Alarm permission always granted for this Android version")
                    savePermissionStatus(Manifest.permission.SCHEDULE_EXACT_ALARM, true)
                    result.success(true)
                }
            }
            "getAndroidVersion" -> {
                result.success(Build.VERSION.SDK_INT)
            }
            "hasModernStorageAccess" -> {
                Log.d("PermissionMaster", "Checking storage access for Android ${Build.VERSION.SDK_INT}")

                when {
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> {
                        val hasImages = permissionHelper.isPermissionGranted(Manifest.permission.READ_MEDIA_IMAGES)
                        val hasVideo = permissionHelper.isPermissionGranted(Manifest.permission.READ_MEDIA_VIDEO)
                        val hasAudio = permissionHelper.isPermissionGranted(Manifest.permission.READ_MEDIA_AUDIO)

                        savePermissionStatus(Manifest.permission.READ_MEDIA_IMAGES, hasImages)
                        savePermissionStatus(Manifest.permission.READ_MEDIA_VIDEO, hasVideo)
                        savePermissionStatus(Manifest.permission.READ_MEDIA_AUDIO, hasAudio)

                        val hasAccess = hasImages || hasVideo || hasAudio
                        Log.d("PermissionMaster", "Android 13+ media permissions: Images=$hasImages, Video=$hasVideo, Audio=$hasAudio, Overall=$hasAccess")
                        result.success(hasAccess)
                    }
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                        val hasStorage = permissionHelper.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)
                        savePermissionStatus(Manifest.permission.READ_EXTERNAL_STORAGE, hasStorage)
                        Log.d("PermissionMaster", "Android 11-12 READ_EXTERNAL_STORAGE: $hasStorage")
                        result.success(hasStorage)
                    }
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> {
                        val hasRead = permissionHelper.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)
                        val hasWrite = permissionHelper.isPermissionGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        savePermissionStatus(Manifest.permission.READ_EXTERNAL_STORAGE, hasRead)
                        savePermissionStatus(Manifest.permission.WRITE_EXTERNAL_STORAGE, hasWrite)
                        val hasAccess = hasRead && hasWrite
                        Log.d("PermissionMaster", "Android 6-10 storage permissions: Read=$hasRead, Write=$hasWrite, Overall=$hasAccess")
                        result.success(hasAccess)
                    }
                    else -> {
                        savePermissionStatus(Manifest.permission.READ_EXTERNAL_STORAGE, true)
                        savePermissionStatus(Manifest.permission.WRITE_EXTERNAL_STORAGE, true)
                        result.success(true)
                    }
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
                    is HashMap<*, *> -> {
                        @Suppress("UNCHECKED_CAST")
                        storage.write(key, value as HashMap<String, Any>)
                    }
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
                    is HashMap<*, *> -> {
                        @Suppress("UNCHECKED_CAST")
                        result.success(storage.read(key, defaultValue as HashMap<String, Any>))
                    }
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
            "clearPermissionCounts" -> {
                // Clear all permission request counts to allow fresh permission requests
                val permissionHelper = activity?.let { PermissionHelper(it) }
                    ?: return result.error("ACTIVITY_NULL", "Activity is null", null)
                
                val permissions = arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    Manifest.permission.READ_MEDIA_IMAGES,
                    Manifest.permission.READ_MEDIA_VIDEO,
                    Manifest.permission.READ_MEDIA_AUDIO,
                    Manifest.permission.RECORD_AUDIO,
                    Manifest.permission.READ_CONTACTS,
                    Manifest.permission.READ_CALENDAR,
                    Manifest.permission.READ_PHONE_STATE,
                    Manifest.permission.SEND_SMS,
                    Manifest.permission.POST_NOTIFICATIONS,
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_CONNECT,
                    Manifest.permission.BLUETOOTH_ADVERTISE,
                    Manifest.permission.NEARBY_WIFI_DEVICES,
                    Manifest.permission.ACTIVITY_RECOGNITION,
                    Manifest.permission.BODY_SENSORS
                )
                
                permissions.forEach { permission ->
                    permissionHelper.resetRequestCount(permission)
                }
                
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun requestSinglePermission(helper: PermissionHelper, permission: String, result: MethodChannel.Result) {
        if (helper.isPermissionGranted(permission)) {
            savePermissionStatus(permission, true)
            result.success(true)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            savePermissionStatus(permission, true)
            result.success(true)
            return
        }


        val requestCode = permission.hashCode() and 0xFFFF
        requestCallbacks[requestCode] = result

        try {
            Log.d("PermissionMaster", "Requesting permission: $permission")
            
            // Special handling for BODY_SENSORS - don't increment count immediately
            if (permission != Manifest.permission.BODY_SENSORS) {
                helper.incrementRequestCount(permission)
            }
            
            ActivityCompat.requestPermissions(
                activity!!,
                arrayOf(permission),
                requestCode
            )
        } catch (e: Exception) {
            Log.e("PermissionMaster", "Error requesting permission: ${e.message}", e)
            result.error("PERMISSION_ERROR", "Error requesting permission: ${e.message}", null)
            requestCallbacks.remove(requestCode)
        }
    }

    private fun requestPermissionsSequentially(helper: PermissionHelper, permissions: Array<String>, result: MethodChannel.Result) {
        Log.d("PermissionMaster", "Requesting permissions sequentially: ${permissions.joinToString()}")

        val results = mutableMapOf<String, Boolean>()

        var allGranted = true
        for (permission in permissions) {
            val isGranted = helper.isPermissionGranted(permission)
            results[permission] = isGranted
            if (!isGranted) {
                allGranted = false
            }
        }

        if (allGranted) {
            for (permission in permissions) {
                savePermissionStatus(permission, true)
            }
            result.success(true)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            for (permission in permissions) {
                savePermissionStatus(permission, true)
            }
            result.success(true)
            return
        }

        val groupRequestCode = permissions.joinToString().hashCode() and 0xFFFF

        class SequentialPermissionHandler(
            private val permissions: Array<String>,
            private val result: MethodChannel.Result
        ) {
            private var currentIndex = 0
            private val permissionResults = mutableMapOf<String, Boolean>()

            fun processNextPermission() {
                if (currentIndex >= permissions.size) {
                    val allGranted = permissionResults.values.all { it }
                    result.success(allGranted)
                    return
                }

                val permission = permissions[currentIndex]

                if (helper.isPermissionGranted(permission)) {
                    savePermissionStatus(permission, true)
                    permissionResults[permission] = true
                    currentIndex++
                    processNextPermission()
                    return
                }


                val requestCode = permission.hashCode() and 0xFFFF

                requestCallbacks[requestCode] = object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        val granted = result as? Boolean ?: false
                        permissionResults[permission] = granted
                        savePermissionStatus(permission, granted)

                        currentIndex++
                        processNextPermission()
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        permissionResults[permission] = false
                        savePermissionStatus(permission, false)

                        currentIndex++
                        processNextPermission()
                    }

                    override fun notImplemented() {
                        permissionResults[permission] = false
                        savePermissionStatus(permission, false)

                        currentIndex++
                        processNextPermission()
                    }
                }

                try {
                    Log.d("PermissionMaster", "Requesting permission: $permission")
                    
                    // Special handling for BODY_SENSORS - don't increment count immediately
                    if (permission != Manifest.permission.BODY_SENSORS) {
                        helper.incrementRequestCount(permission)
                    }
                    
                    ActivityCompat.requestPermissions(
                        activity!!,
                        arrayOf(permission),
                        requestCode
                    )
                } catch (e: Exception) {
                    Log.e("PermissionMaster", "Error requesting permission: ${e.message}", e)
                    requestCallbacks.remove(requestCode)

                    permissionResults[permission] = false
                    savePermissionStatus(permission, false)

                    currentIndex++
                    processNextPermission()
                }
            }
        }

        val handler = SequentialPermissionHandler(permissions, result)
        handler.processNextPermission()
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

    private fun handlePermissionResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        val result = requestCallbacks[requestCode] ?: return

        try {
            Log.d("PermissionMaster", "Handling permission result for requestCode: $requestCode, permissions: ${permissions.joinToString()}, grantResults: ${grantResults.joinToString()}")

            if (permissions.isNotEmpty() && grantResults.isNotEmpty()) {
                val granted = grantResults[0] == PackageManager.PERMISSION_GRANTED
                val permission = permissions[0]

                Log.d("PermissionMaster", "Permission $permission result: ${if (granted) "GRANTED" else "DENIED"}")

                // For BODY_SENSORS, increment count only after getting result
                if (permission == Manifest.permission.BODY_SENSORS && !granted) {
                    activity?.let { PermissionHelper(it).incrementRequestCount(permission) }
                }

                savePermissionStatus(permission, granted)
                result.success(granted)
            } else {
                Log.w("PermissionMaster", "Empty permissions or grant results array")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("PermissionMaster", "Error handling permission result: ${e.message}", e)
            try {
                result.success(false)
            } catch (e2: Exception) {
                Log.e("PermissionMaster", "Failed to send error result: ${e2.message}", e2)
            }
        } finally {
            requestCallbacks.remove(requestCode)
        }
    }

    private fun savePermissionStatus(permission: String, granted: Boolean) {
        try {
            val status = if (granted) "GRANTED" else "DENIED"
            Log.d("PermissionMaster", "Saving permission status for $permission: $status")

            storage.write("permission_${permission}_status", status)
            storage.write("permission_${permission}_time", System.currentTimeMillis())

            if (permission.contains("STORAGE") || permission.contains("MEDIA")) {
                storage.write("permission_android.permission.READ_EXTERNAL_STORAGE_status", status)
                storage.write("permission_android.permission.WRITE_EXTERNAL_STORAGE_status", status)
            }
        } catch (e: Exception) {
            Log.e("PermissionMaster", "Error saving permission status: ${e.message}", e)
        }
    }

    private fun checkPermissionStatus(call: MethodCall, helper: PermissionHelper, result: MethodChannel.Result) {
        val permission = call.argument<String>("permission")
            ?: return result.error("INVALID_ARGUMENT", "Permission string cannot be null", null)

        if (permission == "android.permission.READ_EXTERNAL_STORAGE" ||
            permission == "android.permission.WRITE_EXTERNAL_STORAGE" ||
            permission == "android.permission.READ_MEDIA_IMAGES" ||
            permission == "android.permission.READ_MEDIA_VIDEO" ||
            permission == "android.permission.READ_MEDIA_AUDIO") {
            try {
                Log.d("PermissionMaster", "Checking storage permission status: $permission")

                val hasAccess = when {
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> {
                        val hasImages = helper.isPermissionGranted(Manifest.permission.READ_MEDIA_IMAGES)
                        val hasVideo = helper.isPermissionGranted(Manifest.permission.READ_MEDIA_VIDEO)
                        val hasAudio = helper.isPermissionGranted(Manifest.permission.READ_MEDIA_AUDIO)
                        hasImages || hasVideo || hasAudio
                    }
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                        helper.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)
                    }
                    Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> {
                        val hasRead = helper.isPermissionGranted(Manifest.permission.READ_EXTERNAL_STORAGE)
                        val hasWrite = helper.isPermissionGranted(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                        hasRead && hasWrite
                    }
                    else -> {
                        true
                    }
                }

                Log.d("PermissionMaster", "Storage access check result: $hasAccess")
                result.success(if (hasAccess) "GRANTED" else "DENIED")
                return
            } catch (e: Exception) {
                Log.e("PermissionMaster", "Error checking storage access: ${e.message}", e)
            }
        }

        val savedStatusKey = "permission_${permission}_status"
        if (storage.contains(savedStatusKey)) {
            val savedStatus = storage.read(savedStatusKey, "")
            if (savedStatus == "GRANTED") {
                Log.d("PermissionMaster", "Using saved GRANTED status for $permission")
                result.success("GRANTED")
                return
            }
        }

        val status = helper.getPermissionStatus(permission)
        savePermissionStatus(permission, status == PermissionStatus.GRANTED)
        result.success(status.name)
    }

    private fun checkMultiplePermissions(call: MethodCall, helper: PermissionHelper, result: MethodChannel.Result) {
        val permissions = call.argument<List<String>>("permissions")
            ?: return result.error("INVALID_ARGUMENT", "Permissions list cannot be null", null)

        val statusMap = mutableMapOf<String, String>()

        for (permission in permissions) {
            val savedStatusKey = "permission_${permission}_status"
            if (storage.contains(savedStatusKey)) {
                val savedStatus = storage.read(savedStatusKey, "")
                if (savedStatus == "GRANTED") {
                    Log.d("PermissionMaster", "Using saved GRANTED status for $permission")
                    statusMap[permission] = "GRANTED"
                    continue
                }
            }

            val status = helper.getPermissionStatus(permission)
            savePermissionStatus(permission, status == PermissionStatus.GRANTED)
            statusMap[permission] = status.name
        }

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
                    is PermissionResult.Requesting -> {
                        Log.d("PermissionMaster", "Permission is being requested: ${entry.key}")
                        requestCallbacks[permissionsArray.hashCode() and 0xFFFF] = result
                        "REQUESTING"
                    }
                    is PermissionResult.ShowRationale -> {
                        Log.d("PermissionMaster", "Should show rationale, but directly requesting permission: ${entry.key}")
                        requestCallbacks[permissionsArray.hashCode() and 0xFFFF] = result
                        "REQUESTING"
                    }
                    is PermissionResult.OpenSettings -> "OPEN_SETTINGS"
                    is PermissionResult.Error -> "ERROR"
                }
            }

            if (statusMap.values.any { it == "REQUESTING" }) {
                Log.d("PermissionMaster", "Some permissions are being requested, waiting for result")
            } else {
                result.success(statusMap)
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = activity?.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            return alarmManager?.canScheduleExactAlarms() ?: false
        }
        return true
    }
}
