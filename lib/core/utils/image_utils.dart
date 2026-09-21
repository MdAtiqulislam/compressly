import 'dart:math';

class ImageUtils {
  ImageUtils._();

  /// Calculates new dimensions maintaining aspect ratio given target width or height
  static ({int width, int height}) calculateAspectRatioDimensions({
    required int originalWidth,
    required int originalHeight,
    int? targetWidth,
    int? targetHeight,
  }) {
    if (originalWidth <= 0 || originalHeight <= 0) {
      return (width: targetWidth ?? 100, height: targetHeight ?? 100);
    }

    final aspectRatio = originalWidth / originalHeight;

    if (targetWidth != null && targetHeight == null) {
      return (
        width: targetWidth,
        height: (targetWidth / aspectRatio).round().clamp(1, 100000),
      );
    } else if (targetHeight != null && targetWidth == null) {
      return (
        width: (targetHeight * aspectRatio).round().clamp(1, 100000),
        height: targetHeight,
      );
    } else if (targetWidth != null && targetHeight != null) {
      return (width: targetWidth, height: targetHeight);
    }

    return (width: originalWidth, height: originalHeight);
  }

  /// Calculates percentage-scaled dimensions
  static ({int width, int height}) calculatePercentageDimensions({
    required int originalWidth,
    required int originalHeight,
    required double percentage, // 0.1 to 1.0 (or 10% to 100%)
  }) {
    final scale = percentage > 1.0 ? percentage / 100.0 : percentage;
    final w = max(1, (originalWidth * scale).round());
    final h = max(1, (originalHeight * scale).round());
    return (width: w, height: h);
  }

  /// Returns standard aspect ratio as string (e.g. "16:9", "4:3", "1:1")
  static String getAspectRatioString(int width, int height) {
    if (width <= 0 || height <= 0) return '1:1';
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final divisor = gcd(width, height);
    final wRatio = width ~/ divisor;
    final hRatio = height ~/ divisor;
    if (wRatio > 30 || hRatio > 30) {
      final ratio = width / height;
      return '${ratio.toStringAsFixed(2)}:1';
    }
    return '$wRatio:$hRatio';
  }

  /// Detects image format from file extension or magic bytes
  static String inferFormat(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'PNG';
    if (lower.endsWith('.webp')) return 'WEBP';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'JPG';
    return 'JPG';
  }
}
