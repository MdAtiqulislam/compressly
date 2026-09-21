import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PreferencesService extends GetxService {
  late SharedPreferences _prefs;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxString defaultFormat = 'JPG'.obs;
  final RxInt defaultQuality = AppConstants.qualityHigh.obs;
  final RxBool removeMetadata = true.obs;
  final RxBool maintainAspectRatio = true.obs;

  Future<PreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPreferences();
    return this;
  }

  void _loadPreferences() {
    final themeIndex = _prefs.getInt(AppConstants.keyThemeMode) ?? 0;
    if (themeIndex == 1) {
      themeMode.value = ThemeMode.light;
    } else if (themeIndex == 2) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }

    defaultFormat.value = _prefs.getString(AppConstants.keyDefaultFormat) ?? 'JPG';
    defaultQuality.value = _prefs.getInt(AppConstants.keyDefaultQuality) ?? AppConstants.qualityHigh;
    removeMetadata.value = _prefs.getBool(AppConstants.keyRemoveMetadata) ?? true;
    maintainAspectRatio.value = _prefs.getBool(AppConstants.keyMaintainAspectRatio) ?? true;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await _prefs.setInt(AppConstants.keyThemeMode, index);
    Get.changeThemeMode(mode);
  }

  Future<void> setDefaultFormat(String format) async {
    defaultFormat.value = format;
    await _prefs.setString(AppConstants.keyDefaultFormat, format);
  }

  Future<void> setDefaultQuality(int quality) async {
    defaultQuality.value = quality;
    await _prefs.setInt(AppConstants.keyDefaultQuality, quality);
  }

  Future<void> setRemoveMetadata(bool remove) async {
    removeMetadata.value = remove;
    await _prefs.setBool(AppConstants.keyRemoveMetadata, remove);
  }

  Future<void> setMaintainAspectRatio(bool maintain) async {
    maintainAspectRatio.value = maintain;
    await _prefs.setBool(AppConstants.keyMaintainAspectRatio, maintain);
  }
}
