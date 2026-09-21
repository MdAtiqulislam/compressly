import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'core/constants/app_strings.dart';
import 'core/services/history_service.dart';
import 'core/services/image_processing_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/pro_service.dart';
import 'core/services/share_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Get.putAsync(() => PreferencesService().init());
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => HistoryService().init());
  await Get.putAsync(() => ProService().init());
  await Get.putAsync(() => ShareService().init());
  await Get.putAsync(() => ImageProcessingService().init());
}

void main() async {
  await initServices();

  final preferencesService = Get.find<PreferencesService>();

  runApp(
    GetMaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: preferencesService.themeMode.value,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
