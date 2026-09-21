import 'package:get/get.dart';
import '../controllers/resizer_controller.dart';

class ResizerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResizerController>(
      () => ResizerController(),
    );
  }
}
