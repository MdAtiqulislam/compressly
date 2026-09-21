import 'package:get/get.dart';
import '../../../../core/services/pro_service.dart';

class PremiumController extends GetxController {
  final ProService proService = Get.find<ProService>();
  final RxBool isPurchasing = false.obs;

  Future<void> buyLifetime() async {
    isPurchasing.value = true;
    try {
      await proService.purchaseLifetimePro();
      Get.snackbar(
        'Upgrade Successful!',
        'Welcome to Compressly Pro! All premium features are unlocked.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> restore() async {
    isPurchasing.value = true;
    try {
      await proService.restorePurchases();
      Get.snackbar(
        'Purchases Restored',
        'Your Pro purchase has been verified and restored.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
    } finally {
      isPurchasing.value = false;
    }
  }
}
