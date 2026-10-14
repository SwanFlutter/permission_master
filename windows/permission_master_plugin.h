#ifndef FLUTTER_PLUGIN_PERMISSION_MASTER_PLUGIN_H_
#define FLUTTER_PLUGIN_PERMISSION_MASTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace permission_master {

class PermissionMasterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PermissionMasterPlugin();

  virtual ~PermissionMasterPlugin();

  // Disallow copy and assign.
  PermissionMasterPlugin(const PermissionMasterPlugin&) = delete;
  PermissionMasterPlugin& operator=(const PermissionMasterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace permission_master

#endif  // FLUTTER_PLUGIN_PERMISSION_MASTER_PLUGIN_H_
