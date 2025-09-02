#include "include/permission_master/permission_master_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define PERMISSION_MASTER_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), permission_master_plugin_get_type(), \
                              PermissionMasterPlugin))

struct _PermissionMasterPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(PermissionMasterPlugin, permission_master_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void permission_master_plugin_handle_method_call(
    PermissionMasterPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestCameraPermissionLinux") == 0) {
    // For now, return "granted" as a placeholder
    // In a real implementation, you would check system permissions
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestMicrophonePermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestLocationPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestStoragePermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestContactsPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestCalendarPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestNotificationPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestBluetoothPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestNetworkPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "requestUsbPermissionLinux") == 0) {
    g_autoptr(FlValue) result = fl_value_new_string("granted");
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else if (strcmp(method, "openAppSettingsLinux") == 0) {
    // Open system settings (placeholder implementation)
    system("gnome-control-center privacy");
    g_autoptr(FlValue) result = fl_value_new_null();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void permission_master_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(permission_master_plugin_parent_class)->dispose(object);
}

static void permission_master_plugin_class_init(PermissionMasterPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = permission_master_plugin_dispose;
}

static void permission_master_plugin_init(PermissionMasterPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  PermissionMasterPlugin* plugin = PERMISSION_MASTER_PLUGIN(user_data);
  permission_master_plugin_handle_method_call(plugin, method_call);
}

void permission_master_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  PermissionMasterPlugin* plugin = PERMISSION_MASTER_PLUGIN(
      g_object_new(permission_master_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "permission_master",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}