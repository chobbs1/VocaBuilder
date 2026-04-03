// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voca_builder/main.dart';

void main() {
  testWidgets('Word Capture page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VocaBuilderApp());

    // Verify Word Capture page elements are present
    expect(find.text('Capture Word'), findsOneWidget);
    expect(find.text('Word'), findsOneWidget);
    expect(find.text('Associations (optional)'), findsOneWidget);
    expect(find.text('Add to WordBase'), findsOneWidget);
    expect(find.text('Your WordBase'), findsOneWidget);
  });

  testWidgets('Word Capture validates empty word', (WidgetTester tester) async {
    await tester.pumpWidget(const VocaBuilderApp());

    // Tap add without entering anything
    await tester.tap(find.text('Add to WordBase'));
    await tester.pump();

    // Expect validation error
    expect(find.text('Please enter a word'), findsOneWidget);
  });

  testWidgets('Word Capture adds a word', (WidgetTester tester) async {
    await tester.pumpWidget(const VocaBuilderApp());

    // Enter a word
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enter a word'),
      'ephemeral',
    );

    // Tap add
    await tester.tap(find.text('Add to WordBase'));
    await tester.pump();

    // Word should appear in the list
    expect(find.text('ephemeral'), findsOneWidget);
    // Count chip should show 1
    expect(find.text('1'), findsOneWidget);
  });
}
