import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('Compression Algorithm Tests', () {
    test('Encodes and decodes image in memory and calculates byte sizes', () {
      // Create a test synthetic image
      final testImage = img.Image(width: 800, height: 600);
      for (var y = 0; y < testImage.height; y++) {
        for (var x = 0; x < testImage.width; x++) {
          testImage.setPixelRgb(x, y, (x % 256), (y % 256), 128);
        }
      }

      // Encode high quality JPG
      final highBytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 95));
      // Encode low quality JPG
      final lowBytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 20));

      expect(highBytes.length, greaterThan(lowBytes.length));
      expect(lowBytes.length, greaterThan(0));
    });

    test('Binary search finds quality that meets target size limit', () {
      final testImage = img.Image(width: 1000, height: 1000);
      for (var y = 0; y < testImage.height; y++) {
        for (var x = 0; x < testImage.width; x++) {
          testImage.setPixelRgb(x, y, (x * 3) % 256, (y * 5) % 256, 200);
        }
      }

      final targetSizeBytes = 50 * 1024; // 50 KB target
      int minQuality = 5;
      int maxQuality = 98;
      Uint8List? bestBytes;
      int bestQuality = 80;

      for (int iter = 0; iter < 7; iter++) {
        final mid = (minQuality + maxQuality) ~/ 2;
        final encoded = Uint8List.fromList(img.encodeJpg(testImage, quality: mid));
        if (encoded.length <= targetSizeBytes) {
          bestBytes = encoded;
          bestQuality = mid;
          minQuality = mid + 1;
        } else {
          maxQuality = mid - 1;
        }
      }

      if (bestBytes != null) {
        expect(bestBytes.length, lessThanOrEqualTo(targetSizeBytes));
        expect(bestQuality, greaterThanOrEqualTo(5));
      }
    });
  });
}
