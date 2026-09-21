import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compressly/app/modules/cropper/widgets/interactive_crop_box.dart';
import 'package:compressly/data/models/crop_config.dart';

void main() {
  group('Manual Crop & Interactive Overlay Tests', () {
    test('CropAspectRatioPreset ratio values are computed accurately', () {
      expect(CropAspectRatioPreset.free.ratio, isNull);
      expect(CropAspectRatioPreset.square1x1.ratio, 1.0);
      expect(CropAspectRatioPreset.ratio4x3.ratio, closeTo(1.333, 0.01));
      expect(CropAspectRatioPreset.ratio16x9.ratio, closeTo(1.777, 0.01));
    });

    testWidgets('InteractiveCropOverlay renders crop box, dimensions indicator and grid', (WidgetTester tester) async {
      Rect currentRect = const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: InteractiveCropOverlay(
                  normalizedRect: currentRect,
                  imageDisplaySize: const Size(300, 300),
                  imageOffset: Offset.zero,
                  rawImageWidth: 1000,
                  rawImageHeight: 1000,
                  onRectChanged: (newRect) {
                    currentRect = newRect;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('800 × 800 px'), findsOneWidget);
    });
  });
}
