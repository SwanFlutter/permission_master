package com.example.permission_master

sealed class PermissionError : Exception() {
    object MaxAttemptsReached : PermissionError()
    object PermissionDenied : PermissionError()
    object NotImplemented : PermissionError()
    data class SystemError(val errorCode: Int) : PermissionError()
    
    override val message: String
        get() = when (this) {
            is MaxAttemptsReached -> "Maximum permission request attempts reached"
            is PermissionDenied -> "Permission was denied by user"
            is NotImplemented -> "Permission not implemented for this Android version"
            is SystemError -> "System error occurred with code: $errorCode"
        }
} 