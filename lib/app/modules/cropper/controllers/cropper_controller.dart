import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/file_name_generator.dart';
import '../../../../data/models/compression_history.dart';
import '../../../../data/models/crop_config.dart';
import '../../../routes/app_pages.dart';

class CropperController extends GetxController {
  final ImageProcessingService imageProcessingService = Get.find<ImageProcessingService>();
  final StorageService storageService = Get.find<StorageService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final PreferencesService preferencesService = Get.find<PreferencesService>();

  late String imagePath;
  late int originalWidth;
  late int originalHeight;
  late int originalSize;
  late String originalFormat;

  final Rx<CropAspectRatioPreset> selectedRatioPreset = CropAspectRatioPreset.free.obs;
  final RxInt rotationDegrees = 0.obs;
  final RxBool flipHorizontal = false.obs;
  final RxBool flipVertical = false.obs;

  // Normalized crop bounds (0.0 to 1.0)
  final Rx<Rect> cropRectNormalized = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0).obs;

  final RxString outputFormat = 'JPG'.obs;
  final RxInt quality = 90.obs;
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
    outputFormat.value = preferencesService.defaultFormat.value;
  }

  void updateCropRect(Rect rect) {
    cropRectNormalized.value = rect;
  }

  void resetCrop() {
    selectedRatioPreset.value = CropAspectRatioPreset.free;
    cropRectNormalized.value = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
  }

  void setRatioPreset(CropAspectRatioPreset preset) {
    selectedRatioPreset.value = preset;
    final ratio = preset.ratio;
    if (ratio == null) {
      cropRectNormalized.value = const Rect.fromLTWH(0.0, 0.0, 1.0, 1.0);
    } else {
      final imgAspect = originalWidth / originalHeight;
      if (imgAspect > ratio) {
        // Image is wider than crop box
        final normW = (ratio / imgAspect).clamp(0.1, 1.0);
        final normX = (1.0 - normW) / 2.0;
        cropRectNormalized.value = Rect.fromLTWH(normX, 0.0, normW, 1.0);
      } else {
        // Image is taller than crop box
        final normH = (imgAspect / ratio).clamp(0.1, 1.0);
        final normY = (1.0 - normH) / 2.0;
        cropRectNormalized.value = Rect.fromLTWH(0.0, normY, 1.0, normH);
      }
    }
  }

  void rotateCW() {
    rotationDegrees.value = (rotationDegrees.value + 90) % 360;
  }

  void rotateCCW() {
    rotationDegrees.value = (rotationDegrees.value - 90 + 360) % 360;
  }

  void toggleFlipH() {
    flipHorizontal.value = !flipHorizontal.value;
  }

  void toggleFlipV() {
    flipVertical.value = !flipVertical.value;
  }

  Future<void> cropAndSave() async {
    try {
      isProcessing.value = true;

      final norm = cropRectNormalized.value;
      final cropX = (norm.left * originalWidth).round().clamp(0, originalWidth - 1);
      final cropY = (norm.top * originalHeight).round().clamp(0, originalHeight - 1);
      final cropW = (norm.width * originalWidth).round().clamp(1, originalWidth - cropX);
      final cropH = (norm.height * originalHeight).round().clamp(1, originalHeight - cropY);

      final config = CropTransformConfig(
        rotationDegrees: rotationDegrees.value,
        flipHorizontal: flipHorizontal.value,
        flipVertical: flipVertical.value,
        cropX: cropX,
        cropY: cropY,
        cropWidth: cropW,
        cropHeight: cropH,
        outputFormat: outputFormat.value,
        quality: quality.value,
      );

      final result = await imageProcessingService.transformCrop(
        inputPath: imagePath,
        config: config,
      );

      final outputName = FileNameGenerator.generateOutputFileName(
        originalPath: imagePath,
        operation: 'cropped',
        targetExtension: outputFormat.value,
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
        outputFormat: outputFormat.value,
        operation: 'Crop & Rotate',
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
        'Transform Error',
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
