import 'package:flutter_test/flutter_test.dart';
import 'package:compressly/core/utils/image_utils.dart';

void main() {
  group('ImageUtils Tests', () {
    test('calculateAspectRatioDimensions computes correct height from width', () {
      final dims = ImageUtils.calculateAspectRatioDimensions(
        originalWidth: 1920,
        originalHeight: 1080,
        targetWidth: 960,
      );
      expect(dims.width, 960);
      expect(dims.height, 540);
    });

    test('calculateAspectRatioDimensions computes correct width from height', () {
      final dims = ImageUtils.calculateAspectRatioDimensions(
        originalWidth: 4000,
        originalHeight: 3000,
        targetHeight: 1500,
      );
      expect(dims.width, 2000);
      expect(dims.height, 1500);
    });

    test('calculatePercentageDimensions computes exact proportions', () {
      final dims = ImageUtils.calculatePercentageDimensions(
        originalWidth: 2000,
        originalHeight: 1000,
        percentage: 0.5,
      );
      expect(dims.width, 1000);
      expect(dims.height, 500);
    });

    test('inferFormat accurately detects extensions', () {
      expect(ImageUtils.inferFormat('sample.png'), 'PNG');
      expect(ImageUtils.inferFormat('photo.WEBP'), 'WEBP');
      expect(ImageUtils.inferFormat('image.jpeg'), 'JPG');
      expect(ImageUtils.inferFormat('picture.jpg'), 'JPG');
    });
  });
}
