import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/size_formatter.dart';
import '../controllers/batch_controller.dart';

class BatchView extends GetView<BatchController> {
  const BatchView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Processing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_rounded),
            onPressed: controller.pickMultipleImages,
            tooltip: 'Add Images',
          ),
        ],
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
                  // Pick Button Banner if empty
                  if (controller.batchItems.isEmpty) ...[
                    InkWell(
                      onTap: controller.pickMultipleImages,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select Multiple Images',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pick up to 50 photos to compress or convert at once',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: controller.pickMultipleImages,
                              icon: const Icon(Icons.add_photo_alternate_rounded),
                              label: const Text('Browse Gallery'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Selected Items Header & Horizontal List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.batchItems.length} Images Selected',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Total: ${SizeFormatter.formatBytes(controller.totalOriginalBytes)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: controller.batchItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.batchItems[index];
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(File(item.originalPath)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => controller.removeItem(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Batch Operation Selector
                  const Text(
                    'Choose Batch Action',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _BatchOpChip(
                        label: 'Target Size (e.g. <200 KB)',
                        isSelected: controller.selectedOperation.value == BatchOperationType.targetSize,
                        onTap: () => controller.selectedOperation.value = BatchOperationType.targetSize,
                      ),
                      _BatchOpChip(
                        label: 'Quality Compress',
                        isSelected: controller.selectedOperation.value == BatchOperationType.quality,
                        onTap: () => controller.selectedOperation.value = BatchOperationType.quality,
                      ),
                      _BatchOpChip(
                        label: 'Format Convert',
                        isSelected: controller.selectedOperation.value == BatchOperationType.convert,
                        onTap: () => controller.selectedOperation.value = BatchOperationType.convert,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Target Size Presets for Batch
                  if (controller.selectedOperation.value == BatchOperationType.targetSize) ...[
                    const Text(
                      'Batch Target Size Limit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.targetSizePresetsKB.map((kb) {
                        final isSelected = controller.targetSizeKB.value == kb;
                        final label = kb >= 1024 ? '${(kb / 1024).toStringAsFixed(0)} MB' : '$kb KB';
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) => controller.targetSizeKB.value = kb,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Quality Slider for Batch
                  if (controller.selectedOperation.value == BatchOperationType.quality) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quality Level', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${controller.quality.value}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    Slider(
                      value: controller.quality.value.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 90,
                      onChanged: (val) => controller.quality.value = val.round(),
                    ),
                  ],

                  const SizedBox(height: 16),
                  // Output Format for Batch
                  const Text(
                    'Output Format',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
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

            // Start Batch Button
            if (controller.batchItems.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: controller.isProcessing.value ? null : controller.startBatchProcessing,
                    child: Text(
                      'Process ${controller.batchItems.length} Images',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

class _BatchOpChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BatchOpChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
