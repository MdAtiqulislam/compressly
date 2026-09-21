import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ProService extends GetxService {
  late SharedPreferences _prefs;
  final RxBool isPro = false.obs;

  Future<ProService> init() async {
    _prefs = await SharedPreferences.getInstance();
    isPro.value = _prefs.getBool(AppConstants.keyIsProUser) ?? false;
    return this;
  }

  Future<bool> purchaseLifetimePro() async {
    // Simulate payment transaction
    await Future.delayed(const Duration(milliseconds: 600));
    isPro.value = true;
    await _prefs.setBool(AppConstants.keyIsProUser, true);
    return true;
  }

  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 600));
    // For demo/freemium, if restored or already pro
    isPro.value = true;
    await _prefs.setBool(AppConstants.keyIsProUser, true);
    return true;
  }

  Future<void> resetProStatus() async {
    isPro.value = false;
    await _prefs.setBool(AppConstants.keyIsProUser, false);
  }

  int get maxBatchCount => isPro.value ? AppConstants.proBatchLimit : AppConstants.freeBatchLimit;
}
