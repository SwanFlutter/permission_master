package com.example.permission_master

import androidx.annotation.NonNull

import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.Manifest

import android.os.Build
/** PermissionMasterPlugin */
class PermissionMasterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "permission_master")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestCameraPermission" -> requestPermission(result, Manifest.permission.CAMERA, 1)
            "requestLocationPermission" -> requestLocationPermissions(result, 2)
            "requestStoragePermission" -> requestStoragePermissions(result, 3)
            else -> result.notImplemented()
        }
    }

    // Request camera permission
     private fun requestPermission(result: MethodChannel.Result, permission: String, requestCode: Int) {
        activity?.let {
            if (ContextCompat.checkSelfPermission(it, permission) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(it, arrayOf(permission), requestCode)
            } else {
                result.success(true) // مجوز قبلاً داده شده است
            }
        } ?: result.error("Activity is null", null, null)
    }

   // request location permissions
     private fun requestLocationPermissions(result: MethodChannel.Result, requestCode: Int) {
        activity?.let {
            val permissions = arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
            val permissionsToRequest = permissions.filter {
                ContextCompat.checkSelfPermission(it, it) != PackageManager.PERMISSION_GRANTED
            }

            if (permissionsToRequest.isNotEmpty()) {
                ActivityCompat.requestPermissions(it, permissionsToRequest.toTypedArray(), requestCode)
            } else {
                result.success(true) // تمام مجوزها داده شده‌اند
            }
        } ?: result.error("Activity is null", null, null)
    }

   // request storage permissions (with support for different versions)
   private fun requestStoragePermissions(result: MethodChannel.Result, requestCode: Int) {
        activity?.let {
            val permissions: MutableList<String> = mutableListOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                permissions.add(Manifest.permission.READ_MEDIA_IMAGES)
                permissions.add(Manifest.permission.READ_MEDIA_VIDEO)
                permissions.add(Manifest.permission.READ_MEDIA_AUDIO)
            }

            val permissionsToRequest = permissions.filter {
                ContextCompat.checkSelfPermission(it, it) != PackageManager.PERMISSION_GRANTED
            }

            if (permissionsToRequest.isNotEmpty()) {
                ActivityCompat.requestPermissions(it, permissionsToRequest.toTypedArray(), requestCode)
            } else {
                result.success(true) // تمام مجوزها داده شده‌اند
            }
        } ?: result.error("Activity is null", null, null)
    }

   // Manage permissions request response
override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
    when (requestCode) {
        1, 2, 3 -> {
            val permissionsGranted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }

            if (permissionsGranted) {
                channel.invokeMethod("onPermissionResult", mapOf("requestCode" to requestCode, "granted" to true))
            } else {
                channel.invokeMethod("onPermissionResult", mapOf("requestCode" to requestCode, "granted" to false))
            }
        }
        else -> {
            // Handle unrecognized request code
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            
            // Optionally, you can also notify the channel about the unhandled request code
            channel.invokeMethod("onPermissionResult", mapOf(
                "requestCode" to requestCode,
                "granted" to false,
                "error" to "Unrecognized request code"
            ))
        }
    }
}

    // Manage connection to Activity
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}


