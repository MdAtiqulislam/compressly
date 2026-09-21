import 'package:get/get.dart';
import '../controllers/cropper_controller.dart';

class CropperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CropperController>(
      () => CropperController(),
    );
  }
}
