import 'package:get/get.dart';
import '../modules/batch/bindings/batch_binding.dart';
import '../modules/batch/views/batch_progress_view.dart';
import '../modules/batch/views/batch_view.dart';
import '../modules/comparison/bindings/comparison_binding.dart';
import '../modules/comparison/views/comparison_view.dart';
import '../modules/compressor/bindings/compressor_binding.dart';
import '../modules/compressor/views/compression_result_view.dart';
import '../modules/compressor/views/compressor_view.dart';
import '../modules/converter/bindings/converter_binding.dart';
import '../modules/converter/views/converter_view.dart';
import '../modules/cropper/bindings/cropper_binding.dart';
import '../modules/cropper/views/cropper_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/main_navigation/bindings/main_nav_binding.dart';
import '../modules/main_navigation/views/main_nav_view.dart';
import '../modules/premium/bindings/premium_binding.dart';
import '../modules/premium/views/premium_view.dart';
import '../modules/resizer/bindings/resizer_binding.dart';
import '../modules/resizer/views/resizer_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.MAIN_NAV;

  static final routes = [
    GetPage(
      name: _Paths.MAIN_NAV,
      page: () => const MainNavView(),
      binding: MainNavBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.COMPRESSOR,
      page: () => const CompressorView(),
      binding: CompressorBinding(),
    ),
    GetPage(
      name: _Paths.COMPRESSION_RESULT,
      page: () => const CompressionResultView(),
      binding: CompressorBinding(),
    ),
    GetPage(
      name: _Paths.RESIZER,
      page: () => const ResizerView(),
      binding: ResizerBinding(),
    ),
    GetPage(
      name: _Paths.CONVERTER,
      page: () => const ConverterView(),
      binding: ConverterBinding(),
    ),
    GetPage(
      name: _Paths.CROPPER,
      page: () => const CropperView(),
      binding: CropperBinding(),
    ),
    GetPage(
      name: _Paths.BATCH,
      page: () => const BatchView(),
      binding: BatchBinding(),
    ),
    GetPage(
      name: _Paths.BATCH_PROGRESS,
      page: () => const BatchProgressView(),
      binding: BatchBinding(),
    ),
    GetPage(
      name: _Paths.COMPARISON,
      page: () => const ComparisonView(),
      binding: ComparisonBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: _Paths.PREMIUM,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
    ),
  ];
}
