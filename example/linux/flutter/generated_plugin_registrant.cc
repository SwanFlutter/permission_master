//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <permission_master/permission_master_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) permission_master_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PermissionMasterPlugin");
  permission_master_plugin_register_with_registrar(permission_master_registrar);
}
