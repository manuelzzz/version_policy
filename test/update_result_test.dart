import 'package:test/test.dart';
import 'package:version_policy/version_policy.dart';

UpdateResult _result({
  required String current,
  required String latest,
  required UpdateRequirement requirement,
  String? triggering,
}) {
  return UpdateResult(
    currentVersion: AppVersion.parse(current),
    latestVersion: AppVersion.parse(latest),
    requirement: requirement,
    triggeringVersion: triggering == null ? null : AppVersion.parse(triggering),
  );
}

void main() {
  group('UpdateResult', () {
    test('exposes the fields it was constructed with', () {
      final result = _result(
        current: '1.0.0',
        latest: '1.4.0',
        requirement: UpdateRequirement.required,
        triggering: '1.3.0',
      );

      expect(result.currentVersion, AppVersion.parse('1.0.0'));
      expect(result.latestVersion, AppVersion.parse('1.4.0'));
      expect(result.requirement, UpdateRequirement.required);
      expect(result.triggeringVersion, AppVersion.parse('1.3.0'));
    });

    group('hasUpdate', () {
      test('is false when requirement is none', () {
        final result = _result(
          current: '1.4.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.none,
        );

        expect(result.hasUpdate, isFalse);
      });

      test('is true when requirement is optional', () {
        final result = _result(
          current: '1.0.0',
          latest: '1.1.0',
          requirement: UpdateRequirement.optional,
          triggering: '1.1.0',
        );

        expect(result.hasUpdate, isTrue);
      });

      test('is true when requirement is required', () {
        final result = _result(
          current: '1.0.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.required,
          triggering: '1.3.0',
        );

        expect(result.hasUpdate, isTrue);
      });
    });

    group('equality', () {
      test('two results with identical fields are equal', () {
        final a = _result(
          current: '1.0.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.required,
          triggering: '1.3.0',
        );
        final b = _result(
          current: '1.0.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.required,
          triggering: '1.3.0',
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('results differing only by triggeringVersion are not equal', () {
        final a = _result(
          current: '1.0.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.required,
          triggering: '1.3.0',
        );
        final b = _result(
          current: '1.0.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.required,
          triggering: '1.2.0',
        );

        expect(a, isNot(b));
      });

      test('results differing only by requirement are not equal', () {
        final a = _result(
          current: '1.0.0',
          latest: '1.1.0',
          requirement: UpdateRequirement.optional,
          triggering: '1.1.0',
        );
        final b = _result(
          current: '1.0.0',
          latest: '1.1.0',
          requirement: UpdateRequirement.required,
          triggering: '1.1.0',
        );

        expect(a, isNot(b));
      });

      test('a null triggeringVersion is handled correctly', () {
        final a = _result(
          current: '1.4.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.none,
        );
        final b = _result(
          current: '1.4.0',
          latest: '1.4.0',
          requirement: UpdateRequirement.none,
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });
    });

    test('toString includes all fields', () {
      final result = _result(
        current: '1.0.0',
        latest: '1.4.0',
        requirement: UpdateRequirement.required,
        triggering: '1.3.0',
      );

      final string = result.toString();
      expect(string, contains('1.0.0'));
      expect(string, contains('1.4.0'));
      expect(string, contains('required'));
      expect(string, contains('1.3.0'));
    });
  });
}
