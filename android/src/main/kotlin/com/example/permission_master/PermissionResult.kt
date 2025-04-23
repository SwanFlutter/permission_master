package com.example.permission_master

sealed class PermissionResult {
    object Granted : PermissionResult()
    object Denied : PermissionResult()
    object ShowRationale : PermissionResult()
    object OpenSettings : PermissionResult()
    data class Error(val error: PermissionError) : PermissionResult()
} 