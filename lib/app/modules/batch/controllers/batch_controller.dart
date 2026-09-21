import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../core/services/pro_service.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/file_name_generator.dart';
import '../../../../data/models/batch_process_item.dart';
import '../../../../data/models/compression_config.dart';
import '../../../../data/models/compression_history.dart';
import '../../../routes/app_pages.dart';

enum BatchOperationType {
  targetSize,
  quality,
  resize,
  convert,
}

class BatchController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ImageProcessingService imageProcessingService = Get.find<ImageProcessingService>();
  final StorageService storageService = Get.find<StorageService>();
  final HistoryService historyService = Get.find<HistoryService>();
  final PreferencesService preferencesService = Get.find<PreferencesService>();
  final ProService proService = Get.find<ProService>();
  final ShareService shareService = Get.find<ShareService>();

  final RxList<BatchProcessItem> batchItems = <BatchProcessItem>[].obs;
  final Rx<BatchOperationType> selectedOperation = BatchOperationType.targetSize.obs;

  // Operation parameters
  final RxInt targetSizeKB = 200.obs;
  final RxInt quality = AppConstants.qualityHigh.obs;
  final RxString outputFormat = 'JPG'.obs;
  final RxDouble resizePercentage = 0.5.obs;
  final RxBool removeMetadata = true.obs;

  // Progress state
  final RxBool isProcessing = false.obs;
  final RxInt currentIndex = 0.obs;
  final RxInt totalItems = 0.obs;
  final RxDouble overallProgress = 0.0.obs;

  int get totalOriginalBytes => batchItems.fold(0, (sum, item) => sum + item.originalSize);
  int get totalCompressedBytes => batchItems.fold(0, (sum, item) => sum + (item.compressedSize ?? item.originalSize));
  int get totalBytesSaved => (totalOriginalBytes - totalCompressedBytes).clamp(0, totalOriginalBytes);

  Future<void> pickMultipleImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final maxCount = proService.maxBatchCount;
        final selected = pickedFiles.take(maxCount).toList();

        final items = <BatchProcessItem>[];
        for (final file in selected) {
          final f = File(file.path);
          final size = await f.length();
          items.add(BatchProcessItem(
            id: const Uuid().v4(),
            originalPath: file.path,
            fileName: file.name,
            originalSize: size,
          ));
        }
        batchItems.assignAll(items);
      }
    } catch (e) {
      Get.snackbar(
        'Picker Error',
        'Could not load multiple images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickMultipleFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final maxCount = proService.maxBatchCount;
        final selected = result.files.take(maxCount).toList();

        final items = <BatchProcessItem>[];
        for (final file in selected) {
          if (file.path != null) {
            final f = File(file.path!);
            final size = await f.length();
            items.add(BatchProcessItem(
              id: const Uuid().v4(),
              originalPath: file.path!,
              fileName: file.name,
              originalSize: size,
            ));
          }
        }
        batchItems.assignAll(items);
      }
    } catch (e) {
      Get.snackbar(
        'File Selection Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < batchItems.length) {
      batchItems.removeAt(index);
    }
  }

  Future<void> startBatchProcessing() async {
    if (batchItems.isEmpty) return;

    isProcessing.value = true;
    totalItems.value = batchItems.length;
    currentIndex.value = 0;
    overallProgress.value = 0.0;

    Get.toNamed(Routes.BATCH_PROGRESS);

    for (int i = 0; i < batchItems.length; i++) {
      currentIndex.value = i + 1;
      final item = batchItems[i];
      item.status = BatchItemStatus.processing;
      batchItems.refresh();

      try {
        ProcessedImageResult result;

        if (selectedOperation.value == BatchOperationType.targetSize) {
          final config = CompressionConfig(
            mode: CompressionMode.targetSize,
            targetSizeBytes: targetSizeKB.value * 1024,
            outputFormat: outputFormat.value,
            removeMetadata: removeMetadata.value,
          );
          result = await imageProcessingService.compressImage(
            inputPath: item.originalPath,
            config: config,
          );
        } else if (selectedOperation.value == BatchOperationType.quality) {
          final config = CompressionConfig(
            mode: CompressionMode.quality,
            quality: quality.value,
            outputFormat: outputFormat.value,
            removeMetadata: removeMetadata.value,
          );
          result = await imageProcessingService.compressImage(
            inputPath: item.originalPath,
            config: config,
          );
        } else if (selectedOperation.value == BatchOperationType.convert) {
          result = await imageProcessingService.convertFormat(
            inputPath: item.originalPath,
            targetFormat: outputFormat.value,
            quality: quality.value,
            removeMetadata: removeMetadata.value,
          );
        } else {
          // Resize
          final config = CompressionConfig(
            mode: CompressionMode.quality,
            quality: quality.value,
            outputFormat: outputFormat.value,
          );
          result = await imageProcessingService.compressImage(
            inputPath: item.originalPath,
            config: config,
          );
        }

        final outputName = FileNameGenerator.generateOutputFileName(
          originalPath: item.originalPath,
          operation: 'batch_${selectedOperation.value.name}',
          targetExtension: outputFormat.value,
          batchIndex: i,
        );

        final savedFile = await storageService.saveImageBytes(
          bytes: result.bytes,
          fileName: outputName,
        );

        item.outputPath = savedFile.path;
        item.compressedSize = result.outputSize;
        item.outputWidth = result.outputWidth;
        item.outputHeight = result.outputHeight;
        item.status = BatchItemStatus.completed;

        // Save into history
        final historyRecord = CompressionHistory(
          id: const Uuid().v4(),
          originalPath: item.originalPath,
          outputPath: savedFile.path,
          fileName: outputName,
          originalSize: item.originalSize,
          compressedSize: result.outputSize,
          originalWidth: result.originalWidth,
          originalHeight: result.originalHeight,
          outputWidth: result.outputWidth,
          outputHeight: result.outputHeight,
          inputFormat: item.originalPath.split('.').last.toUpperCase(),
          outputFormat: outputFormat.value,
          operation: 'Batch ${selectedOperation.value.name}',
          createdAt: DateTime.now(),
        );
        await historyService.addHistory(historyRecord);
      } catch (e) {
        item.status = BatchItemStatus.failed;
        item.errorMessage = e.toString();
      }

      overallProgress.value = (i + 1) / batchItems.length;
      batchItems.refresh();
    }

    isProcessing.value = false;
  }

  Future<void> shareAllBatchResults() async {
    final completedPaths = batchItems
        .where((item) => item.status == BatchItemStatus.completed && item.outputPath != null)
        .map((item) => item.outputPath!)
        .toList();

    if (completedPaths.isNotEmpty) {
      await shareService.shareMultipleFiles(filePaths: completedPaths);
    }
  }
}
