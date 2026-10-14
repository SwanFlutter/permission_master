import 'package:flutter/material.dart';

import 'permission_type.dart';

/// Configuration for customizing the permission dialog appearance and content.
class PermissionDialogConfig {
  /// Title displayed at the top of the dialog.
  final String? title;

  /// Description text explaining why the permission is needed.
  final String? description;

  /// Custom icon widget. If null, a default icon based on permission type is used.
  final Widget? icon;

  /// Background color of the icon container. Defaults to the permission's accent color.
  final Color? iconBackgroundColor;

  /// Label for the confirm/allow button.
  final String confirmLabel;

  /// Label for the cancel/deny button.
  final String cancelLabel;

  /// Whether to show a list of what the app will use the permission for.
  final List<String>? usageReasons;

  const PermissionDialogConfig({
    this.title,
    this.description,
    this.icon,
    this.iconBackgroundColor,
    this.confirmLabel = 'Allow',
    this.cancelLabel = 'Not Now',
    this.usageReasons,
  });
}

/// A beautiful pre-permission dialog that explains why a permission is needed
/// before the system dialog appears.
class PermissionDialog extends StatelessWidget {
  final PermissionType permission;
  final PermissionDialogConfig config;

  const PermissionDialog({
    super.key,
    required this.permission,
    this.config = const PermissionDialogConfig(),
  });

  /// Shows the dialog and returns true if the user wants to allow, false otherwise.
  static Future<bool> show(
    BuildContext context, {
    required PermissionType permission,
    PermissionDialogConfig config = const PermissionDialogConfig(),
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return PermissionDialog(permission: permission, config: config);
      },
    );
    return result ?? false;
  }

  /// Shows a "Go to Settings" dialog when permission is permanently denied.
  static Future<bool> showSettingsDialog(
    BuildContext context, {
    required PermissionType permission,
    String? title,
    String? description,
  }) async {
    final info = _PermissionInfo.from(permission);
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SettingsDialog(
          permission: permission,
          info: info,
          title: title,
          description: description,
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final info = _PermissionInfo.from(permission);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final title = config.title ?? info.title;
    final description = config.description ?? info.description;
    final accentColor = config.iconBackgroundColor ?? info.color;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Top section with gradient banner ───
              _buildHeader(context, info, accentColor),

              // ─── Content ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    if (config.usageReasons != null &&
                        config.usageReasons!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildUsageReasons(
                        context,
                        config.usageReasons!,
                        accentColor,
                        isDark,
                      ),
                    ],
                  ],
                ),
              ),

              // ─── Buttons ───
              _buildButtons(context, accentColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    _PermissionInfo info,
    Color accentColor,
  ) {
    final icon = config.icon ?? Icon(info.icon, color: Colors.white, size: 36);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageReasons(
    BuildContext context,
    List<String> reasons,
    Color accentColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reasons
            .map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF374151),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, Color accentColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // Allow button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                config.confirmLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? Colors.white54
                    : const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                config.cancelLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings dialog (for permanently denied permissions)
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsDialog extends StatelessWidget {
  final PermissionType permission;
  final _PermissionInfo info;
  final String? title;
  final String? description;

  const _SettingsDialog({
    required this.permission,
    required this.info,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with warning color
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFFF6B35).withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  children: [
                    Text(
                      title ?? 'Permission Blocked',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description ??
                          'You\'ve previously denied ${info.title.toLowerCase()} access. '
                              'Please open Settings and enable it to continue.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Steps hint
                    _buildStepsHint(context, isDark),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.settings_rounded, size: 18),
                        label: const Text(
                          'Open Settings',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white54
                              : const Color(0xFF9CA3AF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Maybe Later',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsHint(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildStep('1', 'Tap "Open Settings" below', isDark),
          const SizedBox(height: 6),
          _buildStep('2', 'Find Permissions', isDark),
          const SizedBox(height: 6),
          _buildStep('3', 'Enable the required permission', isDark),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Permission metadata
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _PermissionInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory _PermissionInfo.from(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return const _PermissionInfo(
          title: 'Camera Access',
          description: 'Allow this app to use your camera to take photos and record videos.',
          icon: Icons.camera_alt_rounded,
          color: Color(0xFF5B8DEF),
        );
      case PermissionType.microphone:
        return const _PermissionInfo(
          title: 'Microphone Access',
          description: 'Allow this app to use your microphone for voice messages and calls.',
          icon: Icons.mic_rounded,
          color: Color(0xFFEF5B5B),
        );
      case PermissionType.fineLocation:
      case PermissionType.backgroundLocation:
        return const _PermissionInfo(
          title: 'Location Access',
          description: 'Allow this app to access your location to provide relevant content.',
          icon: Icons.location_on_rounded,
          color: Color(0xFF34C759),
        );
      case PermissionType.readStorage:
      case PermissionType.writeStorage:
        return const _PermissionInfo(
          title: 'Storage Access',
          description: 'Allow this app to access your files and media to save and share content.',
          icon: Icons.folder_rounded,
          color: Color(0xFFFF9500),
        );
      case PermissionType.contacts:
        return const _PermissionInfo(
          title: 'Contacts Access',
          description:
              'Allow this app to read your contacts to make sharing easier.',
          icon: Icons.contacts_rounded,
          color: Color(0xFF30B0C7),
        );
      case PermissionType.notifications:
        return const _PermissionInfo(
          title: 'Notifications',
          description:
              'Allow this app to send you notifications to keep you updated.',
          icon: Icons.notifications_rounded,
          color: Color(0xFFFF6B35),
        );
      case PermissionType.bluetooth:
      case PermissionType.bluetoothAdmin:
      case PermissionType.bluetoothScan:
      case PermissionType.bluetoothAdvertise:
      case PermissionType.bluetoothConnect:
        return const _PermissionInfo(
          title: 'Bluetooth Access',
          description:
              'Allow this app to use Bluetooth to connect with nearby devices.',
          icon: Icons.bluetooth_rounded,
          color: Color(0xFF007AFF),
        );
      case PermissionType.calendar:
        return const _PermissionInfo(
          title: 'Calendar Access',
          description: 'Allow this app to read your calendar to manage events and reminders.',
          icon: Icons.calendar_month_rounded,
          color: Color(0xFFAF52DE),
        );
      case PermissionType.phone:
        return const _PermissionInfo(
          title: 'Phone Access',
          description: 'Allow this app to access your phone state information.',
          icon: Icons.phone_rounded,
          color: Color(0xFF34C759),
        );
      case PermissionType.sms:
        return const _PermissionInfo(
          title: 'SMS Access',
          description: 'Allow this app to send and read SMS messages.',
          icon: Icons.sms_rounded,
          color: Color(0xFF5B8DEF),
        );
      case PermissionType.activityRecognition:
        return const _PermissionInfo(
          title: 'Activity Recognition',
          description: 'Allow this app to recognize your physical activities like walking and running.',
          icon: Icons.directions_run_rounded,
          color: Color(0xFFFF9500),
        );
      case PermissionType.bodySensors:
        return const _PermissionInfo(
          title: 'Body Sensors',
          description: 'Allow this app to access data from your body sensors like heart rate.',
          icon: Icons.monitor_heart_rounded,
          color: Color(0xFFEF5B5B),
        );
      case PermissionType.alarm:
        return const _PermissionInfo(
          title: 'Exact Alarms',
          description: 'Allow this app to schedule exact alarms and reminders.',
          icon: Icons.alarm_rounded,
          color: Color(0xFFFF6B35),
        );
      case PermissionType.nearbyDevices:
      case PermissionType.accessWifi:
      case PermissionType.changeWifi:
        return const _PermissionInfo(
          title: 'Nearby Devices',
          description:
              'Allow this app to find and connect to nearby Wi-Fi devices.',
          icon: Icons.wifi_rounded,
          color: Color(0xFF30B0C7),
        );
      case PermissionType.health:
        return const _PermissionInfo(
          title: 'Health Data',
          description: 'Allow this app to access your health and fitness data.',
          icon: Icons.favorite_rounded,
          color: Color(0xFFEF5B5B),
        );
    }
  }
}
