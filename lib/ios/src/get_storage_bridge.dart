import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A bridge class to interact with the native storage methods using MethodChannel.
/// Example usage:
/// ```dart
/// void main() async {
///   final storage = GetStorageBridge();
///
///   // Write a value
///   await storage.write('myKey', 'myValue');
///
///   // Read a value
///   final value = await storage.read('myKey', 'defaultValue');
///   print('Read value: \$value');
///
///   // Check if a key exists
///   final exists = await storage.contains('myKey');
///   print('Key exists: \$exists');
///
///   // Remove a key
///   await storage.remove('myKey');
///
///   // Clear all keys
///   await storage.clear();
/// }
///
///
/// ```
///
///
class GetStorageBridge {
  static const MethodChannel _channel = MethodChannel('permission_master_ios');

  /// Writes a value to storage.
  ///
  /// [key] The key under which to store the value.
  /// [value] The value to store. Can be of various types including Map.
  Future<void> write<T>(String key, T value) async {
    try {
      if (value is Map<String, dynamic>) {
        await _channel.invokeMethod('storage_write', {
          'key': key,
          'value': jsonEncode(value),
        });
      } else {
        await _channel.invokeMethod('storage_write', {
          'key': key,
          'value': value,
        });
      }
    } on PlatformException catch (e) {
      debugPrint("Error writing to storage: ${e.message}");
    }
  }

  /// Reads a value from storage.
  ///
  /// [key] The key for the value to read.
  /// [defaultValue] The default value to return if the key is not found.
  Future<T> read<T>(String key, T defaultValue) async {
    try {
      final result = await _channel.invokeMethod('storage_read', {
        'key': key,
        'defaultValue': defaultValue,
      });

      if (result == null) return defaultValue;

      if (defaultValue is Map<String, dynamic> && result is String) {
        return jsonDecode(result) as T;
      }

      if (defaultValue is Map<String, int> && result is Map) {
        Map<String, int> convertedMap = {};
        result.forEach((key, value) {
          if (key is String) {
            if (value is int) {
              convertedMap[key] = value;
            } else if (value is num) {
              convertedMap[key] = value.toInt();
            }
          }
        });
        return convertedMap as T;
      }

      return result as T;
    } on PlatformException catch (e) {
      debugPrint("Error reading from storage: ${e.message}");
      return defaultValue;
    }
  }

  /// Checks if a key exists in storage.
  ///
  /// [key] The key to check.
  Future<bool> contains(String key) async {
    try {
      return await _channel.invokeMethod('storage_contains', {'key': key});
    } on PlatformException catch (e) {
      debugPrint("Error checking key presence: ${e.message}");
      return false;
    }
  }

  /// Removes a key from storage.
  ///
  /// [key] The key to remove.
  Future<void> remove(String key) async {
    try {
      await _channel.invokeMethod('storage_remove', {'key': key});
    } on PlatformException catch (e) {
      debugPrint("Error removing key: ${e.message}");
    }
  }

  /// Clears all keys from storage.
  Future<void> clear() async {
    try {
      await _channel.invokeMethod('storage_clear');
    } on PlatformException catch (e) {
      debugPrint("Error clearing storage: ${e.message}");
    }
  }
}
