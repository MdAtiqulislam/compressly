import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compressly/app/modules/home/widgets/stats_card.dart';
import 'package:compressly/app/modules/home/widgets/tool_card.dart';

void main() {
  testWidgets('StatsCard renders total savings and photo count', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatsCard(
            totalBytesSaved: 50 * 1024 * 1024,
            totalImagesProcessed: 12,
          ),
        ),
      ),
    );

    expect(find.text('Total Space Saved'), findsOneWidget);
    expect(find.text('50.0 MB'), findsOneWidget);
    expect(find.text('12 photos'), findsOneWidget);
  });

  testWidgets('ToolCard renders title, description, and triggers tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ToolCard(
            title: 'Compress Image',
            description: 'Reduce file size while keeping high quality',
            icon: Icons.compress_rounded,
            iconColor: Colors.blue,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Compress Image'), findsOneWidget);
    expect(find.text('Reduce file size while keeping high quality'), findsOneWidget);

    await tester.tap(find.text('Compress Image'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
