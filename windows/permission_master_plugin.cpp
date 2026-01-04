#include "permission_master_plugin.h"
// This must be included before many other Windows headers.
#include <windows.h>
// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <sstream>
#include <string>
#include <map>
// Windows specific includes for permissions
#include <mfapi.h>
#include <mfidl.h>
#include <mfreadwrite.h>
#include <mmdeviceapi.h>
#include <endpointvolume.h>
#include <functiondiscoverykeys_devpkey.h>
#include <shellapi.h>
#include <winsvc.h>
#include <winreg.h>
// WinRT includes removed to avoid Debug Assertion issues
// #include <winrt/base.h>
// #include <winrt/Windows.Foundation.h>
// #include <winrt/Windows.System.h>
// #include <winrt/Windows.ApplicationModel.h>
// #include <winrt/Windows.Devices.Geolocation.h>
// #include <winrt/Windows.Devices.Radios.h>
// #include <winrt/Windows.UI.Notifications.h>
#pragma comment(lib, "mf.lib")
#pragma comment(lib, "mfplat.lib")
#pragma comment(lib, "mfreadwrite.lib")
#pragma comment(lib, "mfuuid.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "windowsapp.lib")

namespace permission_master {

// Helper functions for Windows permissions
class WindowsPermissionHelper {
public:
    // Check camera permission status with improved detection
    static std::string CheckCameraPermissionWindows() {
        HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
        if (FAILED(hr)) {
            return "denied";
        }
        hr = MFStartup(MF_VERSION);
        if (FAILED(hr)) {
            CoUninitialize();
            return "denied";
        }
        IMFAttributes* pAttributes = NULL;
        hr = MFCreateAttributes(&pAttributes, 1);
        if (SUCCEEDED(hr)) {
            hr = pAttributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
        }
        IMFActivate** ppDevices = NULL;
        UINT32 count = 0;
        if (SUCCEEDED(hr)) {
            hr = MFEnumDeviceSources(pAttributes, &ppDevices, &count);
        }
        std::string result;
        if (count > 0) {
            // Try to actually access the camera to check if permission is granted
            IMFMediaSource* pSource = NULL;
            hr = ppDevices[0]->ActivateObject(__uuidof(IMFMediaSource), (void**)&pSource);
            if (SUCCEEDED(hr)) {
                result = "granted";
                pSource->Release();
            } else {
                // Camera exists but access denied (likely permission issue)
                result = "denied";
            }
        } else {
            // No camera devices found
            result = "not_available";
        }
        // Cleanup
        if (ppDevices) {
            for (UINT32 i = 0; i < count; i++) {
                ppDevices[i]->Release();
            }
            CoTaskMemFree(ppDevices);
        }
        if (pAttributes) pAttributes->Release();
        MFShutdown();
        CoUninitialize();
        return result;
    }

    // Check microphone permission status
    static std::string CheckMicrophonePermissionWindows() {
        HRESULT hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
        if (FAILED(hr)) {
            return "denied";
        }
        IMMDeviceEnumerator* pEnumerator = NULL;
        hr = CoCreateInstance(__uuidof(MMDeviceEnumerator), NULL, CLSCTX_ALL, __uuidof(IMMDeviceEnumerator), (void**)&pEnumerator);
        
        std::string result = "denied";
        if (SUCCEEDED(hr)) {
            IMMDevice* pDevice = NULL;
            hr = pEnumerator->GetDefaultAudioEndpoint(eCapture, eConsole, &pDevice);
            if (SUCCEEDED(hr)) {
                result = "granted";
                pDevice->Release();
            }
            pEnumerator->Release();
        }
        CoUninitialize();
        return result;
    }

    // Helper: read REG_SZ from registry
    static bool ReadRegString(HKEY root, const std::string& subkey, const char* valueName, std::string& out) {
        HKEY hKey;
        LONG res = RegOpenKeyExA(root, subkey.c_str(), 0, KEY_READ, &hKey);
        if (res != ERROR_SUCCESS) return false;
        char buffer[256];
        DWORD bufferSize = sizeof(buffer);
        DWORD type = 0;
        res = RegQueryValueExA(hKey, valueName, NULL, &type, reinterpret_cast<LPBYTE>(buffer), &bufferSize);
        RegCloseKey(hKey);
        if (res == ERROR_SUCCESS && (type == REG_SZ || type == REG_EXPAND_SZ)) {
            out.assign(buffer, buffer + strnlen(buffer, sizeof(buffer)));
            return true;
        }
        return false;
    }

    // Helper: read REG_DWORD from registry
    static bool ReadRegDword(HKEY root, const std::string& subkey, const char* valueName, DWORD& out) {
        HKEY hKey;
        LONG res = RegOpenKeyExA(root, subkey.c_str(), 0, KEY_READ, &hKey);
        if (res != ERROR_SUCCESS) return false;
        DWORD data = 0;
        DWORD dataSize = sizeof(data);
        DWORD type = 0;
        res = RegQueryValueExA(hKey, valueName, NULL, &type, reinterpret_cast<LPBYTE>(&data), &dataSize);
        RegCloseKey(hKey);
        if (res == ERROR_SUCCESS && type == REG_DWORD) {
            out = data;
            return true;
        }
        return false;
    }

    // Helper: get executable path (ANSI)
    static std::string GetExecutablePathA() {
        wchar_t pathW[MAX_PATH] = {0};
        DWORD len = GetModuleFileNameW(NULL, pathW, MAX_PATH);
        if (len == 0) return std::string();
        int sizeNeeded = WideCharToMultiByte(CP_UTF8, 0, pathW, (int)len, NULL, 0, NULL, NULL);
        std::string pathA(sizeNeeded, 0);
        WideCharToMultiByte(CP_UTF8, 0, pathW, (int)len, pathA.data(), sizeNeeded, NULL, NULL);
        return pathA;
    }

    // Helper: check if Windows Location service (lfsvc) is running
    static bool IsLocationServiceRunning() {
        SC_HANDLE hSC = OpenSCManager(NULL, NULL, SC_MANAGER_CONNECT);
        if (!hSC) return false;
        SC_HANDLE hSvc = OpenServiceA(hSC, "lfsvc", SERVICE_QUERY_STATUS);
        if (!hSvc) {
            CloseServiceHandle(hSC);
            return false;
        }
        SERVICE_STATUS_PROCESS ssp = {0};
        DWORD bytesNeeded = 0;
        BOOL ok = QueryServiceStatusEx(hSvc, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded);
        CloseServiceHandle(hSvc);
        CloseServiceHandle(hSC);
        if (!ok) return false;
        return ssp.dwCurrentState == SERVICE_RUNNING;
    }

    // Check location permission status
    static std::string CheckLocationPermissionWindows() {
        try {
            // Check if location service is running first - if not, definitely denied
            bool serviceRunning = IsLocationServiceRunning();
            if (!serviceRunning) {
                return "denied";
            }
            
            // Check the main Windows location setting
            DWORD locationEnabled = 1; // Default assume enabled
            
            // Check system-wide location setting (HKEY_LOCAL_MACHINE)
            if (ReadRegDword(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\CapabilityAccessManager\\ConsentStore\\location", "Value", locationEnabled)) {
                if (locationEnabled == 0) {
                    return "denied"; // Location is disabled system-wide
                }
            }
            
            // Reset and check user-level location setting (HKEY_CURRENT_USER) - this is the main toggle
            locationEnabled = 1; // Reset to default
            if (ReadRegDword(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\CapabilityAccessManager\\ConsentStore\\location", "Value", locationEnabled)) {
                if (locationEnabled == 0) {
                    return "denied"; // User has disabled location
                }
            }
            
            // Check string version of the registry value
            std::string globalValue;
            if (ReadRegString(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\CapabilityAccessManager\\ConsentStore\\location", "Value", globalValue)) {
                if (_stricmp(globalValue.c_str(), "Deny") == 0) {
                    return "denied";
                }
            }
            
            // Check legacy Windows 10 location setting
            DWORD legacyLocationEnabled = 1; // Default assume enabled
            if (ReadRegDword(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\DeviceAccess\\Global\\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}", "Value", legacyLocationEnabled)) {
                if (legacyLocationEnabled == 0) {
                    return "denied";
                }
            }
            
            // Check Windows 11 location privacy setting
            DWORD privacyLocationEnabled = 1;
            if (ReadRegDword(HKEY_CURRENT_USER, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", privacyLocationEnabled)) {
                if (privacyLocationEnabled == 0) {
                    return "denied";
                }
            }
            
            // If service is running and no registry denies found, location is granted
            return "granted";
            
        } catch (...) {
            // ignore exceptions
        }
        return "denied";
    }

    // Check notification permission status
    static std::string CheckNotificationPermissionWindows() {
        // For Windows desktop apps, notification permission is typically granted
        return "granted";
    }

    // Check radios permission status
    static std::string CheckRadiosPermissionWindows() {
        // Return granted as radios permission is complex in Windows
        return "granted";
    }

    // Check voice activation permission (Speech)
    static std::string CheckVoiceActivationPermissionWindows() {
        // Windows doesn't have a direct API for voice activation permission
        // This is typically handled through microphone permission
        return CheckMicrophonePermissionWindows();
    }

    // Check email permission (not applicable in Windows desktop apps)
    static std::string CheckEmailPermissionWindows() {
        // Email permission is not applicable for desktop Windows applications
        return "not_applicable";
    }

    // Open Windows Settings for Location
    static void OpenWindowsLocationSettings() {
        ShellExecuteA(NULL, "open", "ms-settings:privacy-location", NULL, NULL, SW_SHOWNORMAL);
    }

    // Open Windows Settings for Notifications
    static void OpenWindowsNotificationSettings() {
        ShellExecuteA(NULL, "open", "ms-settings:notifications", NULL, NULL, SW_SHOWNORMAL);
    }

    // Open Windows Settings for Radios (Bluetooth & devices)
    static void OpenWindowsRadiosSettings() {
        ShellExecuteA(NULL, "open", "ms-settings:bluetooth", NULL, NULL, SW_SHOWNORMAL);
    }

    // Open Windows Settings for Speech
    static void OpenWindowsSpeechSettings() {
        ShellExecuteA(NULL, "open", "ms-settings:privacy-speech", NULL, NULL, SW_SHOWNORMAL);
    }
};

// static
void PermissionMasterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "permission_master",
          &flutter::StandardMethodCodec::GetInstance());
  auto plugin = std::make_unique<PermissionMasterPlugin>();
  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  registrar->AddPlugin(std::move(plugin));
}

PermissionMasterPlugin::PermissionMasterPlugin() {}
PermissionMasterPlugin::~PermissionMasterPlugin() {}

void PermissionMasterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  const std::string& method_name = method_call.method_name();
  
  if (method_name.compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  }
  // Camera permission methods
  else if (method_name.compare("requestCameraPermissionWindows") == 0) {
    // Instead of just checking, guide user to settings
    ShellExecuteA(NULL, "open", "ms-settings:privacy-webcam", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("requested"));
  }
  else if (method_name.compare("checkCameraPermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckCameraPermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Microphone permission methods
  else if (method_name.compare("requestMicrophonePermissionWindows") == 0) {
    // Guide user to settings instead of just checking
    ShellExecuteA(NULL, "open", "ms-settings:privacy-microphone", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("requested"));
  }
  else if (method_name.compare("checkMicrophonePermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckMicrophonePermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Settings methods
  else if (method_name.compare("openAppSettingsWindows") == 0) {
    ShellExecuteA(NULL, "open", "ms-settings:privacy", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("opened"));
  }
  else if (method_name.compare("openCameraSettingsWindows") == 0) {
    ShellExecuteA(NULL, "open", "ms-settings:privacy-webcam", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("opened"));
  }
  else if (method_name.compare("openMicrophoneSettingsWindows") == 0) {
    ShellExecuteA(NULL, "open", "ms-settings:privacy-microphone", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("opened"));
  }
  // Location permission methods
  else if (method_name.compare("requestLocationPermissionWindows") == 0) {
    // First check current status; if already granted, don't open settings
    std::string permission_status = WindowsPermissionHelper::CheckLocationPermissionWindows();
    if (permission_status == "granted") {
      result->Success(flutter::EncodableValue("granted"));
    } else {
      ShellExecuteA(NULL, "open", "ms-settings:privacy-location", NULL, NULL, SW_SHOWNORMAL);
      result->Success(flutter::EncodableValue("requested"));
    }
  }
  else if (method_name.compare("checkLocationPermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckLocationPermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Notification permission methods
  else if (method_name.compare("requestNotificationPermissionWindows") == 0) {
    // Guide user to settings
    ShellExecuteA(NULL, "open", "ms-settings:notifications", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("requested"));
  }
  else if (method_name.compare("checkNotificationPermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckNotificationPermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Radios permission methods
  else if (method_name.compare("requestRadiosPermissionWindows") == 0) {
    // Guide user to settings
    ShellExecuteA(NULL, "open", "ms-settings:bluetooth", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("requested"));
  }
  else if (method_name.compare("checkRadiosPermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckRadiosPermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Voice activation permission methods
  else if (method_name.compare("requestVoiceActivationPermissionWindows") == 0) {
    // Guide user to settings
    ShellExecuteA(NULL, "open", "ms-settings:privacy-speech", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("requested"));
  }
  else if (method_name.compare("checkVoiceActivationPermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckVoiceActivationPermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Email permission methods
  else if (method_name.compare("requestEmailPermissionWindows") == 0) {
    result->Success(flutter::EncodableValue("not_supported"));
  }
  else if (method_name.compare("checkEmailPermissionWindows") == 0) {
    std::string permission_status = WindowsPermissionHelper::CheckEmailPermissionWindows();
    result->Success(flutter::EncodableValue(permission_status));
  }
  // Additional settings methods
  else if (method_name.compare("openLocationSettingsWindows") == 0) {
    ShellExecuteA(NULL, "open", "ms-settings:privacy-location", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("opened"));
  }
  else if (method_name.compare("openNotificationSettingsWindows") == 0) {
    ShellExecuteA(NULL, "open", "ms-settings:notifications", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("opened"));
  }
  else if (method_name.compare("openRadiosSettingsWindows") == 0) {
    ShellExecuteA(NULL, "open", "ms-settings:bluetooth", NULL, NULL, SW_SHOWNORMAL);
    result->Success(flutter::EncodableValue("opened"));
  }
  else if (method_name.compare("openSpeechSettingsWindows") == 0) {
    WindowsPermissionHelper::OpenWindowsSpeechSettings();
    result->Success(flutter::EncodableValue("opened"));
  }
  // Generic permission check
  else if (method_name.compare("checkPermissionStatusWindows") == 0) {
    const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (arguments) {
      auto permission_it = arguments->find(flutter::EncodableValue("permission"));
      if (permission_it != arguments->end()) {
        const auto* permission = std::get_if<std::string>(&permission_it->second);
        if (permission) {
          std::string permission_status = "denied";
          if (permission->find("camera") != std::string::npos || permission->find("CAMERA") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckCameraPermissionWindows();
          } else if (permission->find("microphone") != std::string::npos || permission->find("RECORD_AUDIO") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckMicrophonePermissionWindows();
          } else if (permission->find("location") != std::string::npos || permission->find("ACCESS_FINE_LOCATION") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckLocationPermissionWindows();
          } else if (permission->find("notification") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckNotificationPermissionWindows();
          } else if (permission->find("radios") != std::string::npos || permission->find("bluetooth") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckRadiosPermissionWindows();
          } else if (permission->find("voice") != std::string::npos || permission->find("speech") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckVoiceActivationPermissionWindows();
          } else if (permission->find("email") != std::string::npos) {
            permission_status = WindowsPermissionHelper::CheckEmailPermissionWindows();
          }
          result->Success(flutter::EncodableValue(permission_status));
          return;
        }
      }
    }
    result->Success(flutter::EncodableValue("denied"));
  }
  else {
    result->NotImplemented();
  }
}
}  // namespace permission_master