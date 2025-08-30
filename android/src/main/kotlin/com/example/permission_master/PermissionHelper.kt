package com.example.permission_master

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import android.util.Log

class PermissionHelper(private val activity: Activity) {
    private val prefs: SharedPreferences = activity.getSharedPreferences("PermissionMaster", Context.MODE_PRIVATE)
    private val storage = GetStorage(activity)
    private val tag = "PermissionHelper"

    companion object {
        private const val MAX_ATTEMPTS = 2
        private const val PREFS_REQUEST_COUNT = "request_count_"
        private const val PREFS_LAST_REQUEST_TIME = "last_request_time_"
        private const val MIN_REQUEST_INTERVAL = 24 * 60 * 60 * 1000 // 24 hours
    }

    fun shouldShowPermissionRationale(permission: String): Boolean {
        return ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
    }

    fun canRequestPermission(permission: String): Boolean {
        // Always allow permission requests for better user experience
        // The system will handle showing rationale or blocking if needed
        return true
    }

    fun incrementRequestCount(permission: String) {
        val currentCount = getRequestCount(permission)
        prefs.edit()
            .putInt(PREFS_REQUEST_COUNT + permission, currentCount + 1)
            .putLong(PREFS_LAST_REQUEST_TIME + permission, System.currentTimeMillis())
            .apply()
    }

    fun getRequestCount(permission: String): Int = prefs.getInt(PREFS_REQUEST_COUNT + permission, 0)
    private fun getLastRequestTime(permission: String): Long = prefs.getLong(PREFS_LAST_REQUEST_TIME + permission, 0)

    fun openAppSettings(): Boolean {
        return try {
            val packageName = activity.packageName
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            }
            activity.applicationContext.startActivity(intent)
            Log.d("PermissionHelper", "App settings opened successfully for package: $packageName")
            true
        } catch (e: Exception) {
            Log.e("PermissionHelper", "Failed to open app settings: ${e.message}", e)
            false
        }
    }

    fun isPermissionGranted(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(activity, permission) == PackageManager.PERMISSION_GRANTED
    }

    fun resetRequestCount(permission: String) {
        prefs.edit()
            .remove(PREFS_REQUEST_COUNT + permission)
            .remove(PREFS_LAST_REQUEST_TIME + permission)
            .apply()
    }

    fun requestPermission(permission: String): PermissionResult {
        return try {
            // First check if the permission is supported on this Android version
            val (isSupported, minSdkVersion) = PermissionVersionManager.isPermissionSupported(permission)
            if (!isSupported) {
                // If not supported, return a special error with version information
                val versionName = PermissionVersionManager.getAndroidVersionName(minSdkVersion)
                return PermissionResult.Error(
                    PermissionError.UnsupportedVersion(
                        "This permission requires $versionName or higher",
                        minSdkVersion
                    )
                )
            }

            // For Android 5 and 6, we need special handling
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.M) {
                // For Android 5 (Lollipop), permissions are granted at install time
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                    return PermissionResult.Granted
                }
            }

            when {
                isPermissionGranted(permission) -> PermissionResult.Granted
                !canRequestPermission(permission) -> PermissionResult.OpenSettings
                shouldShowPermissionRationale(permission) -> {
                    // Instead of just returning ShowRationale, directly request the permission
                    // This fixes the issue where the first click shows a rationale instead of requesting permission
                    Log.d("PermissionHelper", "Should show rationale, but directly requesting permission: $permission")
                    incrementRequestCount(permission)
                    requestSystemPermission(permission)
                    PermissionResult.Requesting
                }
                else -> {
                    Log.d("PermissionHelper", "Requesting permission: $permission")
                    incrementRequestCount(permission)
                    requestSystemPermission(permission)
                    PermissionResult.Requesting
                }
            }
        } catch (e: Exception) {
            logError("Error requesting permission: ${e.message}")
            PermissionResult.Error(PermissionError.SystemError(-1))
        }
    }

    fun requestPermissionGroup(permissions: Array<String>, callback: (Map<String, PermissionResult>) -> Unit) {
        val results = permissions.associateWith { requestPermission(it) }
        callback(results)
    }

    private fun requestSystemPermission(permission: String) {
        ActivityCompat.requestPermissions(activity, arrayOf(permission), permission.hashCode() and 0xFFFF)
    }

    fun handlePermissionResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Map<String, Boolean> {
        return permissions.zip(grantResults.toTypedArray())
            .associate { (permission, result) -> permission to (result == PackageManager.PERMISSION_GRANTED) }
    }

    fun getPermissionStatus(permission: String): PermissionStatus {
        return when {
            isPermissionGranted(permission) -> PermissionStatus.GRANTED
            shouldShowPermissionRationale(permission) -> PermissionStatus.DENIED_WITH_RATIONALE
            else -> PermissionStatus.DENIED
        }
    }

    private fun logError(message: String) {
        Log.e(tag, message)
    }
}


enum class PermissionStatus {
    GRANTED,
    DENIED,
    DENIED_WITH_RATIONALE,
    PERMANENTLY_DENIED
}