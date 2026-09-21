import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/pro_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/services/storage_service.dart';

class SettingsController extends GetxController {
  final PreferencesService preferencesService = Get.find<PreferencesService>();
  final StorageService storageService = Get.find<StorageService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final ProService proService = Get.find<ProService>();
  final ShareService shareService = Get.find<ShareService>();

  final RxInt tempStorageBytes = 0.obs;
  final RxInt outputStorageBytes = 0.obs;
  final RxInt totalStorageBytes = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshStorageInfo();
  }

  Future<void> refreshStorageInfo() async {
    final info = await storageService.calculateStorageUsage();
    tempStorageBytes.value = info.tempBytes;
    outputStorageBytes.value = info.outputBytes;
    totalStorageBytes.value = info.totalBytes;
  }

  Future<void> clearCache() async {
    await storageService.clearTemporaryCache();
    await refreshStorageInfo();
    Get.snackbar(
      'Cache Cleared',
      'Temporary processing files have been removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> clearHistory() async {
    await historyService.clearAllHistory();
    Get.snackbar(
      'History Cleared',
      'All local history records have been reset.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void setTheme(ThemeMode mode) {
    preferencesService.setThemeMode(mode);
  }

  void setDefaultFormat(String format) {
    preferencesService.setDefaultFormat(format);
  }

  void setDefaultQuality(int quality) {
    preferencesService.setDefaultQuality(quality);
  }

  void toggleRemoveMetadata(bool val) {
    preferencesService.setRemoveMetadata(val);
  }

  void toggleMaintainAspectRatio(bool val) {
    preferencesService.setMaintainAspectRatio(val);
  }

  void shareApp() {
    shareService.shareApp();
  }
}
