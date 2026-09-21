class AppConstants {
  AppConstants._();

  static const String appName = 'Compressly';
  static const String appTagline = 'Compress. Resize. Convert.';
  static const String appVersion = '1.0.0';

  // Target size presets in KB
  static const List<int> targetSizePresetsKB = [50, 100, 200, 500, 1024, 2048];

  // Quality presets (in %)
  static const int qualitySmall = 30;
  static const int qualityBalanced = 60;
  static const int qualityHigh = 80;
  static const int qualityMax = 95;

  // Resize dimension presets (Width x Height)
  static const List<Map<String, dynamic>> resizePresets = [
    {'label': '1:1 Square (1080×1080)', 'width': 1080, 'height': 1080},
    {'label': 'Full HD (1920×1080)', 'width': 1920, 'height': 1080},
    {'label': 'HD (1280×720)', 'width': 1280, 'height': 720},
    {'label': 'Web Standard (800×600)', 'width': 800, 'height': 600},
    {'label': 'Avatar (600×600)', 'width': 600, 'height': 600},
    {'label': 'Blog Banner (1200×800)', 'width': 1200, 'height': 800},
  ];

  // Supported image formats
  static const List<String> supportedInputExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'bmp',
  ];

  static const List<String> supportedOutputFormats = [
    'JPG',
    'PNG',
    'WEBP',
  ];

  // SharedPreferences Keys
  static const String keyThemeMode = 'prefs_theme_mode';
  static const String keyDefaultFormat = 'prefs_default_format';
  static const String keyDefaultQuality = 'prefs_default_quality';
  static const String keyRemoveMetadata = 'prefs_remove_metadata';
  static const String keyMaintainAspectRatio = 'prefs_maintain_aspect_ratio';
  static const String keyIsProUser = 'prefs_is_pro_user';
  static const String keyHistoryList = 'prefs_history_list';
  static const String keyTotalBytesSaved = 'prefs_total_bytes_saved';
  static const String keyTotalImagesCompressed = 'prefs_total_images_compressed';

  // Free Tier Limits
  static const int freeBatchLimit = 5;
  static const int proBatchLimit = 100;
}
