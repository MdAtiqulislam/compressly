import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // Pro Upgrade Card if not pro
            Obx(() {
              final isPro = controller.proService.isPro.value;
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: isPro ? AppColors.primaryGradient : AppColors.proGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: (isPro ? AppColors.primary : Colors.pink).withAlpha(80),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPro ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? 'Compressly Pro Active' : 'Upgrade to Pro',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPro
                                ? 'All premium tools & batch limits unlocked.'
                                : 'Unlock target compression, unlimited batch & ad-free.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isPro)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.pink.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        onPressed: () => Get.toNamed(Routes.PREMIUM),
                        child: const Text('Upgrade'),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // SECTION 1: General Preferences
            _SectionHeader(title: 'General Preferences'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  // Theme Mode
                  Obx(() => ListTile(
                        leading: const Icon(Icons.brightness_6_rounded),
                        title: const Text('App Theme'),
                        subtitle: Text(
                          controller.preferencesService.themeMode.value == ThemeMode.system
                              ? 'System Default'
                              : controller.preferencesService.themeMode.value == ThemeMode.dark
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () => _showThemeDialog(context),
                      )),
                  const Divider(height: 1),
                  // Default Format
                  Obx(() => ListTile(
                        leading: const Icon(Icons.image_outlined),
                        title: const Text('Default Output Format'),
                        subtitle: Text(controller.preferencesService.defaultFormat.value),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () => _showFormatDialog(context),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 2: Processing & Privacy
            _SectionHeader(title: 'Processing & Privacy'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                        secondary: const Icon(Icons.security_rounded, color: AppColors.accent),
                        title: const Text('Remove Metadata (EXIF)'),
                        subtitle: const Text('Strip GPS & camera information from output images'),
                        value: controller.preferencesService.removeMetadata.value,
                        activeTrackColor: AppColors.accent,
                        onChanged: controller.toggleRemoveMetadata,
                      )),
                  const Divider(height: 1),
                  Obx(() => SwitchListTile(
                        secondary: const Icon(Icons.aspect_ratio_rounded),
                        title: const Text('Maintain Aspect Ratio'),
                        subtitle: const Text('Auto-balance height when resizing width'),
                        value: controller.preferencesService.maintainAspectRatio.value,
                        activeTrackColor: AppColors.primary,
                        onChanged: controller.toggleMaintainAspectRatio,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 3: Storage & Maintenance
            _SectionHeader(title: 'Storage & Cache'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  Obx(() => ListTile(
                        leading: const Icon(Icons.folder_special_rounded),
                        title: const Text('Compressed Files Storage'),
                        subtitle: Text(SizeFormatter.formatBytes(controller.outputStorageBytes.value)),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: controller.refreshStorageInfo,
                        ),
                      )),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_rounded, color: Colors.orange),
                    title: const Text('Clear Temporary Cache'),
                    subtitle: const Text('Free up cache used during compression'),
                    onTap: controller.clearCache,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    title: const Text('Clear All History'),
                    subtitle: const Text('Reset history records'),
                    onTap: controller.clearHistory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 4: About & Info
            _SectionHeader(title: 'About Compressly'),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.share_rounded),
                    title: const Text('Share App with Friends'),
                    onTap: controller.shareApp,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Guarantee'),
                    subtitle: const Text('100% on-device processing. No data uploaded.'),
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About Compressly'),
                    subtitle: const Text('Version 1.0.0'),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select App Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: controller.preferencesService.themeMode.value,
              onChanged: (mode) {
                if (mode != null) {
                  controller.setTheme(mode);
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              value: ThemeMode.light,
              groupValue: controller.preferencesService.themeMode.value,
              onChanged: (mode) {
                if (mode != null) {
                  controller.setTheme(mode);
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              value: ThemeMode.dark,
              groupValue: controller.preferencesService.themeMode.value,
              onChanged: (mode) {
                if (mode != null) {
                  controller.setTheme(mode);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Default Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedOutputFormats.map((format) {
            return RadioListTile<String>(
              title: Text(format),
              value: format,
              groupValue: controller.preferencesService.defaultFormat.value,
              onChanged: (val) {
                if (val != null) {
                  controller.setDefaultFormat(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Privacy Policy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is our utmost priority.\n\n'
            '• 100% Offline Processing: All image compression, resizing, cropping, and format conversion happens locally inside your device\'s background isolates.\n'
            '• Zero Cloud Uploads: We never upload or transfer your photos to any remote server.\n'
            '• Metadata Stripping: When enabled, EXIF GPS coordinates, camera model, and time tags are purged before saving.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compressly'),
        content: const Text(
          'Compressly is a fast, offline-first image compression and format conversion utility app built for performance and privacy.\n\nVersion: 1.0.0\nTechnology: Flutter & Pure Dart',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
        ),
      ),
    );
  }
}
