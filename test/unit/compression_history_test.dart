import 'package:flutter_test/flutter_test.dart';
import 'package:compressly/data/models/compression_history.dart';

void main() {
  group('CompressionHistory Tests', () {
    test('serializes and deserializes JSON perfectly', () {
      final history = CompressionHistory(
        id: 'test-123',
        originalPath: '/test/image.jpg',
        outputPath: '/test/output/image_compressed.jpg',
        fileName: 'image_compressed.jpg',
        originalSize: 4000000,
        compressedSize: 800000,
        originalWidth: 4000,
        originalHeight: 3000,
        outputWidth: 2000,
        outputHeight: 1500,
        inputFormat: 'JPG',
        outputFormat: 'JPG',
        operation: 'Target Size',
        createdAt: DateTime(2026, 8, 22, 12, 0, 0),
      );

      final json = history.toJson();
      final fromJson = CompressionHistory.fromJson(json);

      expect(fromJson.id, 'test-123');
      expect(fromJson.originalSize, 4000000);
      expect(fromJson.compressedSize, 800000);
      expect(fromJson.bytesSaved, 3200000);
      expect(fromJson.savingsPercentage, 80.0);
      expect(fromJson.operation, 'Target Size');
    });
  });
}
