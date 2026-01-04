#ifndef FLUTTER_PLUGIN_PERMISSION_MASTER_PLUGIN_H_
#define FLUTTER_PLUGIN_PERMISSION_MASTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

namespace permission_master {

/**
 * @brief Plugin class for managing system permissions on Windows platforms.
 *
 * This class implements the Flutter plugin interface for requesting and checking
 * various system permissions such as camera, microphone, location, etc.
 */
class PermissionMasterPlugin : public flutter::Plugin {
 public:
  /**
   * @brief Registers the plugin with the given registrar.
   * @param registrar The plugin registrar for Windows.
   */
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  /**
   * @brief Constructs a new PermissionMasterPlugin instance.
   */
  PermissionMasterPlugin();

  /**
   * @brief Destroys the PermissionMasterPlugin instance.
   */
  virtual ~PermissionMasterPlugin();

  // Disallow copy and assign.
  PermissionMasterPlugin(const PermissionMasterPlugin&) = delete;
  PermissionMasterPlugin& operator=(const PermissionMasterPlugin&) = delete;

  /**
   * @brief Handles method calls from Dart.
   * @param method_call The method call received from Dart.
   * @param result The result to be sent back to Dart.
   */
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace permission_master

#endif  // FLUTTER_PLUGIN_PERMISSION_MASTER_PLUGIN_H_