import 'package:get/get.dart';

class ComparisonController extends GetxController {
  late String originalPath;
  late String outputPath;
  late int originalSize;
  late int compressedSize;
  late int originalWidth;
  late int originalHeight;
  late int outputWidth;
  late int outputHeight;
  late String format;

  final RxDouble splitPosition = 0.5.obs; // 0.0 (all after) to 1.0 (all before)

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    originalPath = args['originalPath'] as String? ?? '';
    outputPath = args['outputPath'] as String? ?? '';
    originalSize = args['originalSize'] as int? ?? 0;
    compressedSize = args['compressedSize'] as int? ?? 0;
    originalWidth = args['originalWidth'] as int? ?? 0;
    originalHeight = args['originalHeight'] as int? ?? 0;
    outputWidth = args['outputWidth'] as int? ?? 0;
    outputHeight = args['outputHeight'] as int? ?? 0;
    format = args['format'] as String? ?? 'JPG';
  }

  void updateSplit(double pos) {
    splitPosition.value = pos.clamp(0.0, 1.0);
  }
}
