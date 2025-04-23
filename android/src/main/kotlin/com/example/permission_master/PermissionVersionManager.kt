package com.example.permission_master

import android.Manifest
import android.os.Build
import androidx.annotation.RequiresApi

object PermissionVersionManager {
    fun getStoragePermissions(): Array<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            arrayOf(
                Manifest.permission.READ_MEDIA_IMAGES,
                Manifest.permission.READ_MEDIA_VIDEO,
                Manifest.permission.READ_MEDIA_AUDIO
            )
        } else {
            arrayOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            )
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
}