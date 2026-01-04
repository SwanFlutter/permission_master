#include "include/permission_master/permission_master_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "permission_master_plugin.h"

void PermissionMasterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  permission_master::PermissionMasterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
