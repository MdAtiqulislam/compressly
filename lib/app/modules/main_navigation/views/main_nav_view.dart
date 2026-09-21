import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../batch/views/batch_view.dart';
import '../../history/views/history_view.dart';
import '../../home/views/home_view.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/main_nav_controller.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeView(),
      const BatchView(),
      const HistoryView(),
      const SettingsView(),
    ];

    return Obx(() {
      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_rounded),
              label: AppStrings.batch,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: AppStrings.history,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: AppStrings.settings,
            ),
          ],
        ),
      );
    });
  }
}
