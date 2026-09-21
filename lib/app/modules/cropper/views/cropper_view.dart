import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/crop_config.dart';
import '../controllers/cropper_controller.dart';
import '../widgets/interactive_crop_box.dart';

class CropperView extends GetView<CropperController> {
  const CropperView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Crop & Rotate'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset Crop',
            onPressed: controller.resetCrop,
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // Top Instruction Pill
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Drag corner handles or move the box to crop manually',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Manual Crop Viewport
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final viewportW = constraints.maxWidth;
                      final viewportH = constraints.maxHeight;

                      final is90or270 = controller.rotationDegrees.value == 90 ||
                          controller.rotationDegrees.value == 270;
                      final rawW = is90or270
                          ? controller.originalHeight
                          : controller.originalWidth;
                      final rawH = is90or270
                          ? controller.originalWidth
                          : controller.originalHeight;

                      final imageAspect = rawW / rawH;
                      final viewportAspect = viewportW / viewportH;

                      double displayW, displayH, offsetX, offsetY;

                      if (viewportAspect > imageAspect) {
                        displayH = viewportH;
                        displayW = viewportH * imageAspect;
                        offsetX = (viewportW - displayW) / 2;
                        offsetY = 0;
                      } else {
                        displayW = viewportW;
                        displayH = viewportW / imageAspect;
                        offsetX = 0;
                        offsetY = (viewportH - displayH) / 2;
                      }

                      return Stack(
                        children: [
                          // Base Image Display
                          Positioned(
                            left: offsetX,
                            top: offsetY,
                            width: displayW,
                            height: displayH,
                            child: Transform.rotate(
                              angle: controller.rotationDegrees.value *
                                  (3.141592653589793 / 180),
                              child: Transform.scale(
                                scaleX: controller.flipHorizontal.value ? -1.0 : 1.0,
                                scaleY: controller.flipVertical.value ? -1.0 : 1.0,
                                child: Image.file(
                                  File(controller.imagePath),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),

                          // Manual Draggable Crop Overlay
                          Positioned.fill(
                            child: InteractiveCropOverlay(
                              normalizedRect: controller.cropRectNormalized.value,
                              targetAspectRatio: controller.selectedRatioPreset.value.ratio,
                              imageDisplaySize: Size(displayW, displayH),
                              imageOffset: Offset(offsetX, offsetY),
                              rawImageWidth: rawW,
                              rawImageHeight: rawH,
                              onRectChanged: controller.updateCropRect,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Controls Panel
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Aspect Ratios & Manual Crop Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Crop Mode & Ratios',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: controller.resetCrop,
                        icon: const Icon(Icons.refresh_rounded, size: 14),
                        label: const Text('Reset', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: CropAspectRatioPreset.values.map((preset) {
                        final isSelected = controller.selectedRatioPreset.value == preset;
                        final label = preset == CropAspectRatioPreset.free
                            ? 'Manual (Free)'
                            : preset.label;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (_) => controller.setRatioPreset(preset),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rotate & Flip Toolbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.rotate_left_rounded,
                        label: '-90°',
                        onTap: controller.rotateCCW,
                      ),
                      _ActionButton(
                        icon: Icons.rotate_right_rounded,
                        label: '+90°',
                        onTap: controller.rotateCW,
                      ),
                      _ActionButton(
                        icon: Icons.flip_rounded,
                        label: 'Flip H',
                        isActive: controller.flipHorizontal.value,
                        onTap: controller.toggleFlipH,
                      ),
                      _ActionButton(
                        icon: Icons.flip_camera_android_rounded,
                        label: 'Flip V',
                        isActive: controller.flipVertical.value,
                        onTap: controller.toggleFlipV,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Apply & Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isProcessing.value ? null : controller.cropAndSave,
                      child: controller.isProcessing.value
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Processing Crop...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded),
                                SizedBox(width: 8),
                                Text(
                                  'Apply Crop & Save',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.withAlpha(60),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.primary : null,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
