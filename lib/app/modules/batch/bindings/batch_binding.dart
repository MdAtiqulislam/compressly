import 'package:get/get.dart';
import '../controllers/batch_controller.dart';

class BatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BatchController>(
      () => BatchController(),
    );
  }
}
