import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hanme_typing_web/main.dart';

void main() {
  testWidgets('shows the retro typing home screen', (tester) async {
    await tester.pumpWidget(const RetroHangulTypingApp());

    expect(find.text('레트로 한글 타자'), findsOneWidget);
    expect(find.text('자리 연습'), findsOneWidget);
    expect(find.text('낱말 연습'), findsOneWidget);
    expect(find.text('긴글 연습'), findsOneWidget);
    expect(find.text('베네치아'), findsOneWidget);
  });

  testWidgets('opens a practice screen from a mode card', (tester) async {
    await tester.pumpWidget(const RetroHangulTypingApp());

    await tester.tap(find.widgetWithText(InkWell, '낱말 연습'));
    await tester.pumpAndSettle();

    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('여기에 입력'), findsOneWidget);
  });

  testWidgets('advances immediately after a correct key drill answer', (
    tester,
  ) async {
    await tester.pumpWidget(const RetroHangulTypingApp());

    await tester.tap(find.widgetWithText(InkWell, '자리 연습'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 12'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '마');
    await tester.pump();

    expect(find.text('2 / 12'), findsOneWidget);
    final input = tester.widget<TextField>(find.byType(TextField));
    expect(input.controller?.text, isEmpty);
  });

  testWidgets('venice waits for space before clearing a word', (tester) async {
    await tester.pumpWidget(const RetroHangulTypingApp());

    await tester.tap(find.widgetWithText(InkWell, '베네치아'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '학교');
    await tester.pump();

    var input = tester.widget<TextField>(find.byType(TextField));
    expect(input.controller?.text, '학교');

    await tester.enterText(find.byType(TextField), '학교 ');
    await tester.pump();

    expect(find.text('연습 완료'), findsNothing);
    input = tester.widget<TextField>(find.byType(TextField));
    expect(input.controller?.text, isEmpty);
  });
}
