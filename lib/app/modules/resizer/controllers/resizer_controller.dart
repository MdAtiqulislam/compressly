import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/file_name_generator.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../data/models/compression_history.dart';
import '../../../../data/models/resize_config.dart';
import '../../../routes/app_pages.dart';

class ResizerController extends GetxController {
  final ImageProcessingService imageProcessingService = Get.find<ImageProcessingService>();
  final StorageService storageService = Get.find<StorageService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final PreferencesService preferencesService = Get.find<PreferencesService>();

  late String imagePath;
  late int originalWidth;
  late int originalHeight;
  late int originalSize;
  late String originalFormat;

  final Rx<ResizeMode> selectedMode = ResizeMode.dimensions.obs;
  late TextEditingController widthController;
  late TextEditingController heightController;
  final RxDouble percentage = 0.5.obs;
  final RxBool maintainAspectRatio = true.obs;
  final RxString selectedPresetLabel = ''.obs;

  final RxString outputFormat = 'JPG'.obs;
  final RxInt quality = 85.obs;
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

    widthController = TextEditingController(text: originalWidth.toString());
    heightController = TextEditingController(text: originalHeight.toString());
    outputFormat.value = preferencesService.defaultFormat.value;
    maintainAspectRatio.value = preferencesService.maintainAspectRatio.value;
  }

  void onWidthChanged(String val) {
    if (!maintainAspectRatio.value) return;
    final w = int.tryParse(val);
    if (w != null && originalWidth > 0) {
      final h = (w / (originalWidth / originalHeight)).round();
      heightController.text = h.toString();
    }
  }

  void onHeightChanged(String val) {
    if (!maintainAspectRatio.value) return;
    final h = int.tryParse(val);
    if (h != null && originalHeight > 0) {
      final w = (h * (originalWidth / originalHeight)).round();
      widthController.text = w.toString();
    }
  }

  void selectPreset(Map<String, dynamic> preset) {
    selectedPresetLabel.value = preset['label'] as String;
    widthController.text = preset['width'].toString();
    heightController.text = preset['height'].toString();
    selectedMode.value = ResizeMode.preset;
  }

  void setPercentage(double val) {
    percentage.value = val;
    final dims = ImageUtils.calculatePercentageDimensions(
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      percentage: val,
    );
    widthController.text = dims.width.toString();
    heightController.text = dims.height.toString();
  }

  Future<void> resizeNow() async {
    try {
      isProcessing.value = true;

      final targetW = int.tryParse(widthController.text) ?? originalWidth;
      final targetH = int.tryParse(heightController.text) ?? originalHeight;

      final config = ResizeConfig(
        mode: selectedMode.value,
        targetWidth: targetW,
        targetHeight: targetH,
        percentage: percentage.value,
        maintainAspectRatio: maintainAspectRatio.value,
        outputFormat: outputFormat.value,
        quality: quality.value,
      );

      final result = await imageProcessingService.resizeImage(
        inputPath: imagePath,
        config: config,
      );

      final outputName = FileNameGenerator.generateOutputFileName(
        originalPath: imagePath,
        operation: 'resized',
        targetExtension: outputFormat.value,
        width: result.outputWidth,
        height: result.outputHeight,
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
        operation: 'Resize (${result.outputWidth}×${result.outputHeight})',
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
        'Resize Error',
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
