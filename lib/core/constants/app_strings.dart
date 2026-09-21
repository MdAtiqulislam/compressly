class AppStrings {
  AppStrings._();

  static const String appTitle = 'Compressly';
  static const String home = 'Home';
  static const String batch = 'Batch Tools';
  static const String history = 'History';
  static const String settings = 'Settings';
  static const String pro = 'Compressly Pro';

  // Home CTA & Tools
  static const String compressImage = 'Compress Image';
  static const String compressDesc = 'Reduce file size while keeping high quality';
  static const String targetSizeCompress = 'Target Size';
  static const String targetSizeDesc = 'Hit exact file size (e.g. < 100 KB)';
  static const String resizeImage = 'Resize';
  static const String resizeDesc = 'Change dimensions or aspect ratio';
  static const String convertImage = 'Convert';
  static const String convertDesc = 'Convert between JPG, PNG & WEBP';
  static const String cropRotate = 'Crop & Rotate';
  static const String cropRotateDesc = 'Trim, aspect crop, flip and rotate';
  static const String batchProcess = 'Batch Processing';
  static const String batchDesc = 'Process multiple photos at once';

  // Stats
  static const String totalSaved = 'Total Space Saved';
  static const String imagesProcessed = 'Images Processed';
  static const String recentOperations = 'Recent Operations';
  static const String noHistoryYet = 'No compressed images yet';
  static const String pickImageToStart = 'Pick an image to start compressing!';

  // Privacy Statement
  static const String privacyTagline = '100% Private & Offline';
  static const String privacyDesc = 'Your photos never leave your device. All compression happens locally.';

  // Actions
  static const String selectImage = 'Select Image';
  static const String chooseFromGallery = 'Gallery';
  static const String takePhoto = 'Camera';
  static const String chooseFiles = 'Files';
  static const String compressNow = 'Compress Now';
  static const String saveToDevice = 'Save to Device';
  static const String shareImage = 'Share';
  static const String compareBeforeAfter = 'Before / After';
  static const String clearHistory = 'Clear History';

  // Errors
  static const String errorNoImageSelected = 'No image selected.';
  static const String errorUnsupportedFormat = 'Unsupported image format.';
  static const String errorPermissionDenied = 'Photo access permission is required.';
  static const String errorCompressionFailed = 'Unable to compress image. Please try again.';
  static const String errorTargetSizeImpossible = 'Target size could not be reached with acceptable quality. Try a larger target size.';
}
