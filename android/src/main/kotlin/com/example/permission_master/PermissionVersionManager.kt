package com.example.permission_master

import android.Manifest
import android.os.Build
import androidx.annotation.RequiresApi

object PermissionVersionManager {
    /**
     * Gets the appropriate storage permissions based on Android version
     * - Android 5-10 (API 21-29): READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE
     * - Android 11-12 (API 30-32): READ_EXTERNAL_STORAGE (WRITE_EXTERNAL_STORAGE is deprecated but included for compatibility)
     * - Android 13+ (API 33+): READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO
     *
     * @return Array of permission strings appropriate for the device's Android version
     */
    fun getStoragePermissions(): Array<String> {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> {
                // Android 13+ (API 33+)
                arrayOf(
                    Manifest.permission.READ_MEDIA_IMAGES,
                    Manifest.permission.READ_MEDIA_VIDEO,
                    Manifest.permission.READ_MEDIA_AUDIO
                )
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                // Android 11-12 (API 30-32)
                // Note: WRITE_EXTERNAL_STORAGE is effectively ignored on Android 11+ when targeting API 30+
                // but we include it for apps that might target lower API levels
                arrayOf(
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
            }
            else -> {
                // Android 5-10 (API 21-29)
                arrayOf(
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
            }
        }
    }

    fun getBluetoothPermissions(): Array<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_ADVERTISE
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN
            )
        }
    }

    fun getLocationPermissions(includeBackground: Boolean = false): Array<String> {
        val basePermissions = arrayOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )
        return if (includeBackground && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            basePermissions + Manifest.permission.ACCESS_BACKGROUND_LOCATION
        } else {
            basePermissions
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun getPhonePermissions(): Array<String> {
        return arrayOf(
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.CALL_PHONE,
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.WRITE_CALL_LOG,
            Manifest.permission.READ_PHONE_NUMBERS,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) Manifest.permission.ANSWER_PHONE_CALLS else null
        ).filterNotNull().toTypedArray()
    }

    fun getManageExternalStoragePermission(): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Manifest.permission.MANAGE_EXTERNAL_STORAGE
        } else null
    }

    fun isNotificationPermissionRequired(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
    fun isExactAlarmPermissionRequired(): Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S

    /**
     * Checks if a permission is supported on the current Android version
     * @param permission The permission to check
     * @return A pair of (isSupported, minSdkVersion) where minSdkVersion is the minimum SDK version required for the permission
     */
    fun isPermissionSupported(permission: String): Pair<Boolean, Int> {
        return when (permission) {
            Manifest.permission.SCHEDULE_EXACT_ALARM -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S, Build.VERSION_CODES.S)
            Manifest.permission.POST_NOTIFICATIONS -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU, Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.BLUETOOTH_SCAN,
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.BLUETOOTH_ADVERTISE -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S, Build.VERSION_CODES.S)
            Manifest.permission.ACTIVITY_RECOGNITION -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q, Build.VERSION_CODES.Q)
            Manifest.permission.NEARBY_WIFI_DEVICES -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S, Build.VERSION_CODES.S)
            Manifest.permission.READ_MEDIA_IMAGES,
            Manifest.permission.READ_MEDIA_VIDEO,
            Manifest.permission.READ_MEDIA_AUDIO -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU, Build.VERSION_CODES.TIRAMISU)
            Manifest.permission.ACCESS_BACKGROUND_LOCATION -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q, Build.VERSION_CODES.Q)
            Manifest.permission.MANAGE_EXTERNAL_STORAGE -> Pair(Build.VERSION.SDK_INT >= Build.VERSION_CODES.R, Build.VERSION_CODES.R)
            else -> Pair(true, 1) // Default to supported for other permissions
        }
    }

    /**
     * Gets the Android version name for a specific SDK version
     * @param sdkVersion The SDK version to get the name for
     * @return The Android version name (e.g., "Android 12")
     */
    fun getAndroidVersionName(sdkVersion: Int): String {
        return when (sdkVersion) {
            Build.VERSION_CODES.S -> "Android 12"
            Build.VERSION_CODES.S_V2 -> "Android 12L"
            Build.VERSION_CODES.TIRAMISU -> "Android 13"
            Build.VERSION_CODES.UPSIDE_DOWN_CAKE -> "Android 14"
            Build.VERSION_CODES.R -> "Android 11"
            Build.VERSION_CODES.Q -> "Android 10"
            Build.VERSION_CODES.P -> "Android 9"
            Build.VERSION_CODES.O, Build.VERSION_CODES.O_MR1 -> "Android 8"
            else -> "Android $sdkVersion"
        }
    }
}