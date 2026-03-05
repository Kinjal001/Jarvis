import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/config/strings.dart';

void main() {
  group('AppStrings', () {
    test('appName is Jarvis', () {
      expect(AppStrings.appName, 'Jarvis');
    });

    test('no string is empty', () {
      expect(AppStrings.appName, isNotEmpty);
      expect(AppStrings.appTagline, isNotEmpty);
      expect(AppStrings.loading, isNotEmpty);
      expect(AppStrings.error, isNotEmpty);
    });
  });
}
