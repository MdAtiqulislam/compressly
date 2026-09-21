import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/file_name_generator.dart';
import '../../../../data/models/compression_config.dart';
import '../../../../data/models/compression_history.dart';
import '../../../routes/app_pages.dart';

class CompressorController extends GetxController {
  final ImageProcessingService imageProcessingService = Get.find<ImageProcessingService>();
  final StorageService storageService = Get.find<StorageService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final PreferencesService preferencesService = Get.find<PreferencesService>();
  final ShareService shareService = Get.find<ShareService>();

  // Input Image parameters
  late String imagePath;
  late int originalWidth;
  late int originalHeight;
  late int originalSize;
  late String originalFormat;

  // Compression UI state
  final Rx<CompressionMode> selectedMode = CompressionMode.targetSize.obs;
  final RxInt quality = AppConstants.qualityHigh.obs;
  final RxInt selectedTargetKB = 200.obs;
  final TextEditingController customTargetController = TextEditingController(text: '200');
  final RxString customUnit = 'KB'.obs; // 'KB' or 'MB'

  final RxString outputFormat = 'JPG'.obs;
  final RxBool removeMetadata = true.obs;
  final RxBool isProcessing = false.obs;

  // Result state
  final Rx<ProcessedImageResult?> processedResult = Rx<ProcessedImageResult?>(null);
  final Rx<File?> savedOutputFile = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    imagePath = args['imagePath'] as String? ?? '';
    originalWidth = args['width'] as int? ?? 1920;
    originalHeight = args['height'] as int? ?? 1080;
    originalSize = args['sizeBytes'] as int? ?? 0;
    originalFormat = args['format'] as String? ?? 'JPG';

    outputFormat.value = preferencesService.defaultFormat.value;
    quality.value = preferencesService.defaultQuality.value;
    removeMetadata.value = preferencesService.removeMetadata.value;
  }

  void setMode(CompressionMode mode) {
    selectedMode.value = mode;
  }

  void setTargetPreset(int kb) {
    selectedTargetKB.value = kb;
    if (kb >= 1024) {
      customTargetController.text = (kb / 1024).toStringAsFixed(0);
      customUnit.value = 'MB';
    } else {
      customTargetController.text = kb.toString();
      customUnit.value = 'KB';
    }
  }

  void setQuality(int value) {
    quality.value = value;
  }

  void setFormat(String format) {
    outputFormat.value = format;
  }

  int get effectiveTargetSizeBytes {
    final value = double.tryParse(customTargetController.text) ?? 200;
    if (customUnit.value == 'MB') {
      return (value * 1024 * 1024).round();
    }
    return (value * 1024).round();
  }

  Future<void> compressNow() async {
    try {
      isProcessing.value = true;

      final config = CompressionConfig(
        mode: selectedMode.value,
        quality: quality.value,
        targetSizeBytes: selectedMode.value == CompressionMode.targetSize
            ? effectiveTargetSizeBytes
            : null,
        outputFormat: outputFormat.value,
        removeMetadata: removeMetadata.value,
      );

      final result = await imageProcessingService.compressImage(
        inputPath: imagePath,
        config: config,
      );

      processedResult.value = result;

      // Generate output file name
      final outputName = FileNameGenerator.generateOutputFileName(
        originalPath: imagePath,
        operation: selectedMode.value == CompressionMode.targetSize ? 'target_compressed' : 'compressed',
        targetExtension: outputFormat.value,
      );

      // Save to local device storage
      final savedFile = await storageService.saveImageBytes(
        bytes: result.bytes,
        fileName: outputName,
      );

      savedOutputFile.value = savedFile;

      // Add to history
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
        outputFormat: outputFormat.value,
        operation: selectedMode.value == CompressionMode.targetSize ? 'Target Size' : 'Quality Compress',
        createdAt: DateTime.now(),
      );

      await historyService.addHistory(historyRecord);

      // Navigate to Compression Result View
      Get.toNamed(Routes.COMPRESSION_RESULT);
    } catch (e) {
      Get.snackbar(
        'Compression Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> shareResult() async {
    if (savedOutputFile.value != null) {
      await shareService.shareFile(filePath: savedOutputFile.value!.path);
    }
  }
}
