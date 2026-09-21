import 'package:get/get.dart';
import '../controllers/converter_controller.dart';

class ConverterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConverterController>(
      () => ConverterController(),
    );
  }
}
