import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../routes/app_pages.dart';
import '../widgets/image_picker_bottom_sheet.dart';

class HomeController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final ImageProcessingService imageProcessingService = Get.find<ImageProcessingService>();
  final HistoryService historyService = Get.find<HistoryService>();

  final RxBool isLoading = false.obs;

  void onSelectTool(String route) {
    if (route == Routes.BATCH) {
      Get.toNamed(Routes.BATCH);
      return;
    }

    ImagePickerBottomSheet.show(
      onSourceSelected: (source) => _pickImageAndNavigate(source, route),
      onFilesSelected: () => _pickFileAndNavigate(route),
    );
  }

  Future<void> _pickImageAndNavigate(ImageSource source, String targetRoute) async {
    try {
      isLoading.value = true;
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        final info = await imageProcessingService.getImageInfo(picked.path);
        Get.toNamed(
          targetRoute,
          arguments: {
            'imagePath': picked.path,
            'width': info.width,
            'height': info.height,
            'sizeBytes': info.sizeBytes,
            'format': info.format,
          },
        );
      }
    } catch (e) {
      Get.snackbar(
        'Image Selection Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _pickFileAndNavigate(String targetRoute) async {
    try {
      isLoading.value = true;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final info = await imageProcessingService.getImageInfo(path);
        Get.toNamed(
          targetRoute,
          arguments: {
            'imagePath': path,
            'width': info.width,
            'height': info.height,
            'sizeBytes': info.sizeBytes,
            'format': info.format,
          },
        );
      }
    } catch (e) {
      Get.snackbar(
        'File Selection Error',
        AppStrings.errorUnsupportedFormat,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
