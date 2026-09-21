import 'package:flutter_test/flutter_test.dart';
import 'package:compressly/core/utils/file_name_generator.dart';

void main() {
  group('FileNameGenerator Tests', () {
    test('generates compressed filename', () {
      final name = FileNameGenerator.generateOutputFileName(
        originalPath: '/path/to/my_photo.jpg',
        operation: 'compressed',
        targetExtension: 'jpg',
      );
      expect(name, 'my_photo_compressed.jpg');
    });

    test('generates resized filename with dimensions', () {
      final name = FileNameGenerator.generateOutputFileName(
        originalPath: '/photos/vacation.png',
        operation: 'resized',
        targetExtension: 'jpg',
        width: 1080,
        height: 1080,
      );
      expect(name, 'vacation_1080x1080.jpg');
    });

    test('generates batch indexed filename', () {
      final name = FileNameGenerator.generateOutputFileName(
        originalPath: '/photos/IMG_4500.jpeg',
        operation: 'compressed',
        targetExtension: 'webp',
        batchIndex: 2,
      );
      expect(name, 'IMG_4500_003_compressed.webp');
    });
  });
}
