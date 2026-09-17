import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:handwriting_app/main.dart';

void main() {
  testWidgets('home screen shows capture actions', (WidgetTester tester) async {
    await tester.pumpWidget(const HandwritingApp());
    await tester.pumpAndSettle();

    expect(find.text('Handwriting'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.photo_library), findsOneWidget);
    expect(find.text('No scans yet. Tap + to start.'), findsOneWidget);
  });
}
