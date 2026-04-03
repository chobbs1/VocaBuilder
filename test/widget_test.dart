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
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VocaBuilderApp());

    // Verify login page elements are present
    expect(find.text('VoCa Builder'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Login validates empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(const VocaBuilderApp());

    // Tap login without entering anything
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pump();

    // Expect validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
