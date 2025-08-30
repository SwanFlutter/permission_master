package com.example.permission_master

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import org.json.JSONObject

class GetStorage(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences(
        "permission_master",
        Context.MODE_PRIVATE
    )
    private val prefix = "permission_master_"
    private val tag = "GetStorage"

    fun <T> write(key: String, value: T) {
        try {
            val editor = prefs.edit()
            when (value) {
                is Int -> editor.putInt(prefix + key, value)
                is Long -> editor.putLong(prefix + key, value)
                is Float -> editor.putFloat(prefix + key, value)
                is String -> editor.putString(prefix + key, value)
                is Boolean -> editor.putBoolean(prefix + key, value)
                is HashMap<*, *> -> {
                    @Suppress("UNCHECKED_CAST")
                    editor.putString(prefix + key, JSONObject(value as Map<*, *>).toString())
                }
                else -> throw IllegalArgumentException("Unsupported data type: ${value?.let { it::class.java.name } ?: "null"}")
            }
            editor.apply()
        } catch (e: Exception) {
            logError("Error writing data: ${e.message}")
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun <T> read(key: String, defaultValue: T): T {
        return try {
            when (defaultValue) {
                is Int -> prefs.getInt(prefix + key, defaultValue) as T
                is Long -> prefs.getLong(prefix + key, defaultValue) as T
                is Float -> prefs.getFloat(prefix + key, defaultValue) as T
                is String -> prefs.getString(prefix + key, defaultValue) as T
                is Boolean -> prefs.getBoolean(prefix + key, defaultValue) as T
                is HashMap<*, *> -> {
                    val jsonString = prefs.getString(prefix + key, null)
                    jsonString?.let {
                        @Suppress("UNCHECKED_CAST")
                        JSONObject(it).toMap() as T
                    } ?: defaultValue
                }
                else -> throw IllegalArgumentException("Unsupported default data type: ${defaultValue?.let { it::class.java.name } ?: "null"}")
            }
        } catch (e: Exception) {
            logError("Error reading data: ${e.message}")
            defaultValue
        }
    }

    fun contains(key: String): Boolean {
        return prefs.contains(prefix + key)
    }

    fun remove(key: String) {
        try {
            prefs.edit().remove(prefix + key).apply()
        } catch (e: Exception) {
            logError("Error removing key: ${e.message}")
        }
    }

    fun clear() {
        try {
            prefs.edit().clear().apply()
        } catch (e: Exception) {
            logError("Error clearing storage: ${e.message}")
        }
    }

    private fun JSONObject.toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        keys().forEach { key ->
            map[key] = get(key)
        }
        return map
    }

    private fun logError(message: String?) {
        Log.e(tag, message ?: "Unknown error")
    }
}
