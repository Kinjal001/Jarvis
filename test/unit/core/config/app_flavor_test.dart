import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis/core/config/app_flavor.dart';

void main() {
  group('AppFlavor', () {
    test('has exactly three values', () {
      expect(AppFlavor.values.length, 3);
    });

    test('flavor names match expected strings', () {
      expect(AppFlavor.dev.name, 'dev');
      expect(AppFlavor.staging.name, 'staging');
      expect(AppFlavor.prod.name, 'prod');
    });

    test('can be matched by name', () {
      final flavor = AppFlavor.values.firstWhere((f) => f.name == 'staging');
      expect(flavor, AppFlavor.staging);
    });

    test('prod is distinct from dev and staging', () {
      expect(AppFlavor.prod, isNot(AppFlavor.dev));
      expect(AppFlavor.prod, isNot(AppFlavor.staging));
    });
  });
}
