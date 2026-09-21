import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/file_name_generator.dart';
import '../../../../data/models/compression_history.dart';
import '../../../routes/app_pages.dart';

class ConverterController extends GetxController {
  final ImageProcessingService imageProcessingService = Get.find<ImageProcessingService>();
  final StorageService storageService = Get.find<StorageService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final PreferencesService preferencesService = Get.find<PreferencesService>();

  late String imagePath;
  late int originalWidth;
  late int originalHeight;
  late int originalSize;
  late String originalFormat;

  final RxString selectedTargetFormat = 'WEBP'.obs;
  final RxInt quality = 90.obs;
  final RxBool removeMetadata = true.obs;
  final RxBool isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    imagePath = args['imagePath'] as String? ?? '';
    originalWidth = args['width'] as int? ?? 1920;
    originalHeight = args['height'] as int? ?? 1080;
    originalSize = args['sizeBytes'] as int? ?? 0;
    originalFormat = args['format'] as String? ?? 'JPG';

    // Suggest opposite format
    if (originalFormat == 'JPG' || originalFormat == 'JPEG') {
      selectedTargetFormat.value = 'WEBP';
    } else if (originalFormat == 'PNG') {
      selectedTargetFormat.value = 'JPG';
    } else {
      selectedTargetFormat.value = 'JPG';
    }

    removeMetadata.value = preferencesService.removeMetadata.value;
  }

  void setTargetFormat(String format) {
    selectedTargetFormat.value = format;
  }

  Future<void> convertNow() async {
    try {
      isProcessing.value = true;

      final result = await imageProcessingService.convertFormat(
        inputPath: imagePath,
        targetFormat: selectedTargetFormat.value,
        quality: quality.value,
        removeMetadata: removeMetadata.value,
      );

      final outputName = FileNameGenerator.generateOutputFileName(
        originalPath: imagePath,
        operation: 'converted',
        targetExtension: selectedTargetFormat.value,
      );

      final savedFile = await storageService.saveImageBytes(
        bytes: result.bytes,
        fileName: outputName,
      );

      final historyRecord = CompressionHistory(
        id: const Uuid().v4(),
        originalPath: imagePath,
        outputPath: savedFile.path,
        fileName: outputName,
        originalSize: result.originalSize,
        compressedSize: result.outputSize,
        originalWidth: result.originalWidth,
        originalHeight: result.originalHeight,
        outputWidth: result.outputWidth,
        outputHeight: result.outputHeight,
        inputFormat: originalFormat,
        outputFormat: selectedTargetFormat.value,
        operation: 'Convert ($originalFormat → ${selectedTargetFormat.value})',
        createdAt: DateTime.now(),
      );

      await historyService.addHistory(historyRecord);

      Get.toNamed(
        Routes.COMPARISON,
        arguments: {
          'originalPath': imagePath,
          'outputPath': savedFile.path,
          'originalSize': result.originalSize,
          'compressedSize': result.outputSize,
          'originalWidth': result.originalWidth,
          'originalHeight': result.originalHeight,
          'outputWidth': result.outputWidth,
          'outputHeight': result.outputHeight,
          'format': result.format,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Conversion Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
