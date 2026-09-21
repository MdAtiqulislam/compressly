import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../data/models/compression_config.dart';
import '../controllers/compressor_controller.dart';

class CompressorView extends GetView<CompressorController> {
  const CompressorView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress Image'),
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
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 70,
                              height: 70,
                              color: Colors.grey.withAlpha(50),
                              child: const Icon(Icons.image),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.imagePath.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      SizeFormatter.formatBytes(controller.originalSize),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${controller.originalWidth} × ${controller.originalHeight}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mode Selector Tabs (Target Size vs Quality)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ModeTab(
                            title: 'Target File Size',
                            subtitle: 'Exact size guarantee',
                            icon: Icons.track_changes_rounded,
                            isSelected: controller.selectedMode.value == CompressionMode.targetSize,
                            onTap: () => controller.setMode(CompressionMode.targetSize),
                          ),
                        ),
                        Expanded(
                          child: _ModeTab(
                            title: 'Quality Based',
                            subtitle: 'Adjust quality slider',
                            icon: Icons.tune_rounded,
                            isSelected: controller.selectedMode.value == CompressionMode.quality,
                            onTap: () => controller.setMode(CompressionMode.quality),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Target Size Options
                  if (controller.selectedMode.value == CompressionMode.targetSize) ...[
                    const Text(
                      'Select Target File Size',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.targetSizePresetsKB.map((preset) {
                        final isSelected = controller.selectedTargetKB.value == preset;
                        final label = preset >= 1024 ? '${(preset / 1024).toStringAsFixed(0)} MB' : '$preset KB';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) => controller.setTargetPreset(preset),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Custom Target Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.customTargetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Custom Target Size',
                              hintText: 'Enter size',
                              prefixIcon: Icon(Icons.edit_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButtonHideUnderline(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: controller.customUnit.value,
                              items: const [
                                DropdownMenuItem(value: 'KB', child: Text('KB')),
                                DropdownMenuItem(value: 'MB', child: Text('MB')),
                              ],
                              onChanged: (val) {
                                if (val != null) controller.customUnit.value = val;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Quality Slider & Presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Compression Quality',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${controller.quality.value}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: controller.quality.value.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 90,
                      onChanged: (val) => controller.setQuality(val.round()),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QualityPresetButton(
                          label: 'Small (30%)',
                          quality: AppConstants.qualitySmall,
                          isSelected: controller.quality.value == AppConstants.qualitySmall,
                          onTap: () => controller.setQuality(AppConstants.qualitySmall),
                        ),
                        _QualityPresetButton(
                          label: 'Balanced (60%)',
                          quality: AppConstants.qualityBalanced,
                          isSelected: controller.quality.value == AppConstants.qualityBalanced,
                          onTap: () => controller.setQuality(AppConstants.qualityBalanced),
                        ),
                        _QualityPresetButton(
                          label: 'High (80%)',
                          quality: AppConstants.qualityHigh,
                          isSelected: controller.quality.value == AppConstants.qualityHigh,
                          onTap: () => controller.setQuality(AppConstants.qualityHigh),
                        ),
                        _QualityPresetButton(
                          label: 'Max (95%)',
                          quality: AppConstants.qualityMax,
                          isSelected: controller.quality.value == AppConstants.qualityMax,
                          onTap: () => controller.setQuality(AppConstants.qualityMax),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Output Format Selector
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
                          onSelected: (_) => controller.setFormat(format),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Metadata Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Remove EXIF & GPS Metadata',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Protects privacy and saves extra file size',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: controller.removeMetadata.value,
                    activeTrackColor: AppColors.accent,
                    onChanged: (val) => controller.removeMetadata.value = val,
                  ),
                ],
              ),
            ),

            // Bottom Sticky Compress Button
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.isProcessing.value ? null : controller.compressNow,
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
                            Text('Compressing on-device...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt_rounded),
                            SizedBox(width: 8),
                            Text(
                              'Compress Now',
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

class _ModeTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : null,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white.withAlpha(200) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualityPresetButton extends StatelessWidget {
  final String label;
  final int quality;
  final bool isSelected;
  final VoidCallback onTap;

  const _QualityPresetButton({
    required this.label,
    required this.quality,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withAlpha(60),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : null,
          ),
        ),
      ),
    );
  }
}
