import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/config/strings.dart';
import 'package:jarvis/features/home/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders app name', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.text(AppStrings.appName), findsOneWidget);
    });

    testWidgets('renders phase label', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.text(AppStrings.phase0Label), findsOneWidget);
    });

    testWidgets('renders rocket icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.byIcon(Icons.rocket_launch_outlined), findsOneWidget);
    });
  });
}
