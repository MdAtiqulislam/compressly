import 'package:get/get.dart';
import '../controllers/compressor_controller.dart';

class CompressorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompressorController>(
      () => CompressorController(),
    );
  }
}
