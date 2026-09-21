import 'dart:math';

class SizeFormatter {
  SizeFormatter._();

  /// Formats byte count into human-readable string (e.g. 1.2 MB, 350 KB, 850 B)
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final clampedIndex = i.clamp(0, suffixes.length - 1);
    final size = bytes / pow(1024, clampedIndex);
    return '${size.toStringAsFixed(decimals)} ${suffixes[clampedIndex]}';
  }

  /// Calculates percentage saved between original and compressed size (e.g. 75.4%)
  static double calculateSavingsPercentage(int originalBytes, int compressedBytes) {
    if (originalBytes <= 0 || compressedBytes >= originalBytes) return 0.0;
    return ((originalBytes - compressedBytes) / originalBytes) * 100.0;
  }

  /// Formats the savings percentage as a display string (e.g. "82.5%")
  static String formatSavingsPercentage(int originalBytes, int compressedBytes) {
    final savings = calculateSavingsPercentage(originalBytes, compressedBytes);
    return '${savings.toStringAsFixed(1)}%';
  }

  /// Converts KB to Bytes
  static int kbToBytes(int kb) => kb * 1024;

  /// Converts MB to Bytes
  static int mbToBytes(double mb) => (mb * 1024 * 1024).round();
}
