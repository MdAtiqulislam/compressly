import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/utils/size_formatter.dart';
import '../../../../data/models/compression_history.dart';
import '../../../routes/app_pages.dart';

class RecentItemTile extends StatelessWidget {
  final CompressionHistory history;
  final VoidCallback? onDelete;

  const RecentItemTile({
    super.key,
    required this.history,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final file = File(history.outputPath);
    final fileExists = file.existsSync();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            Routes.COMPARISON,
            arguments: {
              'originalPath': history.originalPath,
              'outputPath': history.outputPath,
              'originalSize': history.originalSize,
              'compressedSize': history.compressedSize,
              'originalWidth': history.originalWidth,
              'originalHeight': history.originalHeight,
              'outputWidth': history.outputWidth,
              'outputHeight': history.outputHeight,
              'format': history.outputFormat,
            },
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image thumbnail preview
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 52,
                  height: 52,
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  child: fileExists
                      ? Image.file(
                          file,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_rounded,
                            size: 24,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          SizeFormatter.formatBytes(history.originalSize),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          SizeFormatter.formatBytes(history.compressedSize),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${SizeFormatter.formatSavingsPercentage(history.originalSize, history.compressedSize)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Share button
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                onPressed: () {
                  if (fileExists) {
                    Get.find<ShareService>().shareFile(filePath: history.outputPath);
                  } else {
                    Get.snackbar(
                      'File not found',
                      'The output file might have been moved or deleted.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
