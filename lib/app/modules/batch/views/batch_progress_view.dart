import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../data/models/batch_process_item.dart';
import '../../../routes/app_pages.dart';
import '../controllers/batch_controller.dart';

class BatchProgressView extends GetView<BatchController> {
  const BatchProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Processing'),
        centerTitle: true,
        automaticallyImplyLeading: !controller.isProcessing.value,
      ),
      body: SafeArea(
        child: Obx(() {
          final isDone = !controller.isProcessing.value && controller.overallProgress.value >= 1.0;

          return Column(
            children: [
              // Top Progress or Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: isDone
                    ? Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Batch Completed Successfully!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('Original Total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    SizeFormatter.formatBytes(controller.totalOriginalBytes),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.accent),
                              Column(
                                children: [
                                  const Text('Compressed Total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    SizeFormatter.formatBytes(controller.totalCompressedBytes),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Space Saved', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    SizeFormatter.formatBytes(controller.totalBytesSaved),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Processing ${controller.currentIndex.value} of ${controller.totalItems.value}...',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${(controller.overallProgress.value * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: controller.overallProgress.value,
                              minHeight: 8,
                              backgroundColor: AppColors.primary.withAlpha(30),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
              ),

              // Items Status List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.batchItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.batchItems[index];

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(item.originalPath),
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (item.status == BatchItemStatus.completed)
                                    Text(
                                      '${SizeFormatter.formatBytes(item.originalSize)} → ${SizeFormatter.formatBytes(item.compressedSize ?? 0)} (-${item.savingsPercentage.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  else if (item.status == BatchItemStatus.processing)
                                    const Text(
                                      'Optimizing on-device...',
                                      style: TextStyle(fontSize: 11, color: AppColors.primary),
                                    )
                                  else if (item.status == BatchItemStatus.failed)
                                    Text(
                                      item.errorMessage ?? 'Failed',
                                      style: const TextStyle(fontSize: 11, color: AppColors.error),
                                    )
                                  else
                                    Text(
                                      SizeFormatter.formatBytes(item.originalSize),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status Icon
                            if (item.status == BatchItemStatus.completed)
                              const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20)
                            else if (item.status == BatchItemStatus.processing)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else if (item.status == BatchItemStatus.failed)
                              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20)
                            else
                              const Icon(Icons.schedule_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Action Buttons when done
              if (isDone)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share All'),
                          onPressed: controller.shareAllBatchResults,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.until((route) => Get.currentRoute == Routes.MAIN_NAV || Get.currentRoute == Routes.HOME),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
