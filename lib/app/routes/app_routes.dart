part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const MAIN_NAV = _Paths.MAIN_NAV;
  static const HOME = _Paths.HOME;
  static const COMPRESSOR = _Paths.COMPRESSOR;
  static const COMPRESSION_RESULT = _Paths.COMPRESSION_RESULT;
  static const RESIZER = _Paths.RESIZER;
  static const CONVERTER = _Paths.CONVERTER;
  static const CROPPER = _Paths.CROPPER;
  static const BATCH = _Paths.BATCH;
  static const BATCH_PROGRESS = _Paths.BATCH_PROGRESS;
  static const COMPARISON = _Paths.COMPARISON;
  static const HISTORY = _Paths.HISTORY;
  static const SETTINGS = _Paths.SETTINGS;
  static const PREMIUM = _Paths.PREMIUM;
}

abstract class _Paths {
  _Paths._();
  static const MAIN_NAV = '/';
  static const HOME = '/home';
  static const COMPRESSOR = '/compressor';
  static const COMPRESSION_RESULT = '/compression-result';
  static const RESIZER = '/resizer';
  static const CONVERTER = '/converter';
  static const CROPPER = '/cropper';
  static const BATCH = '/batch';
  static const BATCH_PROGRESS = '/batch-progress';
  static const COMPARISON = '/comparison';
  static const HISTORY = '/history';
  static const SETTINGS = '/settings';
  static const PREMIUM = '/premium';
}
