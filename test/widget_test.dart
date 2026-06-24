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
    expect(find.text('단어 방어'), findsOneWidget);
  });

  testWidgets('opens a practice screen from a mode card', (tester) async {
    await tester.pumpWidget(const RetroHangulTypingApp());

    await tester.tap(find.widgetWithText(InkWell, '낱말 연습'));
    await tester.pumpAndSettle();

    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('여기에 입력'), findsOneWidget);
  });
}
