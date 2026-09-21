import 'package:flutter_test/flutter_test.dart';
import 'package:compressly/core/utils/size_formatter.dart';

void main() {
  group('SizeFormatter Tests', () {
    test('formatBytes formats zero and small bytes correctly', () {
      expect(SizeFormatter.formatBytes(0), '0 B');
      expect(SizeFormatter.formatBytes(512), '512.0 B');
    });

    test('formatBytes formats KB and MB correctly', () {
      expect(SizeFormatter.formatBytes(1024), '1.0 KB');
      expect(SizeFormatter.formatBytes(204800), '200.0 KB');
      expect(SizeFormatter.formatBytes(5 * 1024 * 1024), '5.0 MB');
    });

    test('calculateSavingsPercentage computes correct ratio', () {
      expect(SizeFormatter.calculateSavingsPercentage(1000, 500), 50.0);
      expect(SizeFormatter.calculateSavingsPercentage(1000, 200), 80.0);
      expect(SizeFormatter.calculateSavingsPercentage(1000, 1000), 0.0);
      expect(SizeFormatter.calculateSavingsPercentage(1000, 1200), 0.0);
    });

    test('formatSavingsPercentage returns formatted string', () {
      expect(SizeFormatter.formatSavingsPercentage(1000, 250), '75.0%');
      expect(SizeFormatter.formatSavingsPercentage(4000, 382), '90.5%');
    });

    test('unit conversion helpers work accurately', () {
      expect(SizeFormatter.kbToBytes(100), 102400);
      expect(SizeFormatter.mbToBytes(1.5), (1.5 * 1024 * 1024).round());
    });
  });
}
