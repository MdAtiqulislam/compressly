import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/size_formatter.dart';
import '../controllers/resizer_controller.dart';

class ResizerView extends GetView<ResizerController> {
  const ResizerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resize Image'),
        centerTitle: true,
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Preview Header Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(controller.imagePath),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Original Resolution',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${controller.originalWidth} × ${controller.originalHeight} px',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                SizeFormatter.formatBytes(controller.originalSize),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Percentage Scaling
                  const Text(
                    'Quick Scale Percentage',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [0.25, 0.50, 0.75].map((pct) {
                      final isSelected = (controller.percentage.value - pct).abs() < 0.01;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('${(pct * 100).toInt()}%'),
                          selected: isSelected,
                          onSelected: (_) => controller.setPercentage(pct),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Custom Width and Height Inputs
                  const Text(
                    'Custom Dimensions (px)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.widthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Width',
                            suffixText: 'px',
                          ),
                          onChanged: controller.onWidthChanged,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Height',
                            suffixText: 'px',
                          ),
                          onChanged: controller.onHeightChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Maintain Aspect Ratio Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Maintain Aspect Ratio',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Prevents image stretching and distortion',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: controller.maintainAspectRatio.value,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => controller.maintainAspectRatio.value = val,
                  ),
                  const SizedBox(height: 16),

                  // Preset Dimensions List
                  const Text(
                    'Standard Presets',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.resizePresets.map((preset) {
                      final isSelected = controller.selectedPresetLabel.value == preset['label'];
                      return ActionChip(
                        label: Text(preset['label'] as String),
                        backgroundColor: isSelected ? AppColors.primary.withAlpha(30) : null,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.grey.withAlpha(50),
                        ),
                        onPressed: () => controller.selectPreset(preset),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Output Format
                  const Text(
                    'Output Format',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: AppConstants.supportedOutputFormats.map((format) {
                      final isSelected = controller.outputFormat.value == format;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(format),
                          selected: isSelected,
                          onSelected: (_) => controller.outputFormat.value = format,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Bottom Sticky Resize Button
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.isProcessing.value ? null : controller.resizeNow,
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
                            Text('Resizing image...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.aspect_ratio_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Resize & Save',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
