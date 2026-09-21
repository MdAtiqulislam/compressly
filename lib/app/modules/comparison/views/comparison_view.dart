import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/size_formatter.dart';
import '../controllers/comparison_controller.dart';

class ComparisonView extends GetView<ComparisonController> {
  const ComparisonView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final origFile = File(controller.originalPath);
    final compFile = File(controller.outputPath);

    final savings = SizeFormatter.formatSavingsPercentage(
      controller.originalSize,
      controller.compressedSize,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Before & After Comparison'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Metrics Comparison Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'BEFORE (ORIGINAL)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SizeFormatter.formatBytes(controller.originalSize),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${controller.originalWidth} × ${controller.originalHeight}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'SAVED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          savings,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'AFTER (OPTIMIZED)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SizeFormatter.formatBytes(controller.compressedSize),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${controller.outputWidth} × ${controller.outputHeight}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hint
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_rounded,
                    size: 14,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Drag slider left/right to compare quality • Pinch to zoom',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Interactive Comparison Split Slider
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      return Obx(() {
                        final splitX = width * controller.splitPosition.value;

                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final newRatio = details.localPosition.dx / width;
                            controller.updateSplit(newRatio);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Layer 1: Compressed (After) Image (Full background)
                              InteractiveViewer(
                                maxScale: 5.0,
                                child: Image.file(
                                  compFile,
                                  fit: BoxFit.contain,
                                  width: width,
                                  height: height,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Text('Failed to load image', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),

                              // Layer 2: Original (Before) Image (Clipped to split position)
                              ClipRect(
                                clipper: _SplitClipper(splitX: splitX),
                                child: Image.file(
                                  origFile,
                                  fit: BoxFit.contain,
                                  width: width,
                                  height: height,
                                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                ),
                              ),

                              // Layer 3: Split Divider Line and Handle
                              Positioned(
                                left: splitX - 1.5,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 3,
                                  color: Colors.white,
                                ),
                              ),

                              // Handle Button
                              Positioned(
                                left: splitX - 20,
                                top: (height / 2) - 20,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(80),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.unfold_more_rounded,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                ),
                              ),

                              // Tags: BEFORE / AFTER
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(160),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'BEFORE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(160),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'AFTER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double splitX;

  _SplitClipper({required this.splitX});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _SplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
