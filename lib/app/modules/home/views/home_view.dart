import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/pro_service.dart';
import '../../../routes/app_pages.dart';
import '../../main_navigation/controllers/main_nav_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/recent_item_tile.dart';
import '../widgets/stats_card.dart';
import '../widgets/tool_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final proService = Get.find<ProService>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Header & Branding
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: const DecorationImage(
                                  image: AssetImage(AppAssets.appIcon),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.appTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'Compress. Resize. Convert.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Pro Upgrade Badge / Status
                        Obx(() {
                          if (proService.isPro.value) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: AppColors.proGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return InkWell(
                            onTap: () => Get.toNamed(Routes.PREMIUM),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withAlpha(60)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
                                  SizedBox(width: 4),
                                  Text(
                                    'GO PRO',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Privacy Guarantee Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withAlpha(50)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '100% Offline & Private • Photos never leave your device',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Main CTA: Compress Image
                    ToolCard(
                      title: 'Compress Image',
                      description: 'Reduce file size while preserving sharp visual quality',
                      icon: Icons.compress_rounded,
                      iconColor: Colors.white,
                      isFeatured: true,
                      onTap: () => controller.onSelectTool(Routes.COMPRESSOR),
                    ),
                    const SizedBox(height: 14),
                    Builder(builder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final gridAspectRatio = screenWidth < 360 ? 1.05 : (screenWidth < 400 ? 1.18 : 1.25);
                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: gridAspectRatio,
                        children: [
                        ToolCard(
                          title: 'Target Size',
                          description: 'Hit exact size (<100 KB, <200 KB)',
                          icon: Icons.track_changes_rounded,
                          iconColor: AppColors.accent,
                          badge: 'HOT',
                          onTap: () => controller.onSelectTool(Routes.COMPRESSOR),
                        ),
                        ToolCard(
                          title: 'Batch Tools',
                          description: 'Process up to 50 photos at once',
                          icon: Icons.photo_library_rounded,
                          iconColor: AppColors.primary,
                          badge: 'FAST',
                          onTap: () => controller.onSelectTool(Routes.BATCH),
                        ),
                        ToolCard(
                          title: 'Resize Image',
                          description: 'Scale dimensions & aspect ratio',
                          icon: Icons.aspect_ratio_rounded,
                          iconColor: AppColors.secondary,
                          onTap: () => controller.onSelectTool(Routes.RESIZER),
                        ),
                        ToolCard(
                          title: 'Convert Format',
                          description: 'Convert to JPG, PNG, WEBP',
                          icon: Icons.transform_rounded,
                          iconColor: AppColors.warning,
                          onTap: () => controller.onSelectTool(Routes.CONVERTER),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                    // Crop & Rotate Full Width Card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => controller.onSelectTool(Routes.CROPPER),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.crop_rotate_rounded, color: Colors.purple, size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Crop & Rotate',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Free crop, presets, rotate 90/180° & flip',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats Card
                    Obx(() => StatsCard(
                          totalBytesSaved: controller.historyService.totalBytesSaved.value,
                          totalImagesProcessed: controller.historyService.totalImagesCompressed.value,
                        )),
                    const SizedBox(height: 24),
                    // Recent Operations Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.recentOperations,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Obx(() {
                          if (controller.historyService.historyList.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return TextButton(
                            onPressed: () {
                              final mainNavController = Get.find<MainNavController>();
                              mainNavController.changePage(2); // History tab
                            },
                            child: const Text('See All'),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Recent Items List or Empty State
            Obx(() {
              final recentList = controller.historyService.historyList.take(5).toList();
              if (recentList.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            AppStrings.noHistoryYet,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.pickImageToStart,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return RecentItemTile(
                        history: recentList[index],
                      );
                    },
                    childCount: recentList.length,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
