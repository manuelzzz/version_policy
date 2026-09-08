import 'package:test/test.dart';
import 'package:version_policy/version_policy.dart';

Release _release(String version, UpdatePolicy policy) {
  return Release(version: AppVersion.parse(version), policy: policy);
}

void main() {
  group('VersionPolicyEngine', () {
    test('throws DuplicateReleaseVersionError when releases contain a '
        'duplicate version', () {
      expect(
        () => VersionPolicyEngine(
          releases: [
            _release('1.0.0', UpdatePolicy.optional),
            _release('1.1.0', UpdatePolicy.required),
            _release('1.1.0', UpdatePolicy.optional),
          ],
        ),
        throwsA(
          isA<DuplicateReleaseVersionError>().having(
            (e) => e.version,
            'version',
            AppVersion.parse('1.1.0'),
          ),
        ),
      );
    });

    test('duplicate detection applies regardless of matching or differing '
        'policy', () {
      expect(
        () => VersionPolicyEngine(
          releases: [
            _release('1.0.0', UpdatePolicy.required),
            _release('1.0.0', UpdatePolicy.required),
          ],
        ),
        throwsA(isA<DuplicateReleaseVersionError>()),
      );
    });

    test('DuplicateReleaseVersionError is an ArgumentError', () {
      expect(
        () => VersionPolicyEngine(
          releases: [
            _release('1.0.0', UpdatePolicy.optional),
            _release('1.0.0', UpdatePolicy.optional),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('the README motivating example resolves to required at 1.3.0', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0', UpdatePolicy.optional),
          _release('1.2.0', UpdatePolicy.optional),
          _release('1.3.0', UpdatePolicy.required),
          _release('1.4.0', UpdatePolicy.optional),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

      expect(result.requirement, UpdateRequirement.required);
      expect(result.latestVersion, AppVersion.parse('1.4.0'));
      expect(result.triggeringVersion, AppVersion.parse('1.3.0'));
      expect(result.currentVersion, AppVersion.parse('1.0.0'));
      expect(result.hasUpdate, isTrue);
    });

    test('current version already equal to the latest release is none', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0', UpdatePolicy.optional),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.1.0'));

      expect(result.requirement, UpdateRequirement.none);
      expect(result.latestVersion, AppVersion.parse('1.1.0'));
      expect(result.triggeringVersion, isNull);
      expect(result.hasUpdate, isFalse);
    });

    test('current version ahead of every known release is none', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0', UpdatePolicy.required),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('2.0.0'));

      expect(result.requirement, UpdateRequirement.none);
      expect(result.latestVersion, AppVersion.parse('1.1.0'));
      expect(result.triggeringVersion, isNull);
    });

    test('empty release list is none with latestVersion == currentVersion', () {
      final engine = VersionPolicyEngine(releases: const []);

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

      expect(result.requirement, UpdateRequirement.none);
      expect(result.latestVersion, AppVersion.parse('1.0.0'));
      expect(result.triggeringVersion, isNull);
      expect(result.hasUpdate, isFalse);
    });

    test(
      'current version absent from the release list is only a lower bound',
      () {
        final engine = VersionPolicyEngine(
          releases: [
            _release('1.0.0', UpdatePolicy.optional),
            _release('1.2.0', UpdatePolicy.optional),
          ],
        );

        final result = engine.evaluate(
          currentVersion: AppVersion.parse('1.1.0'),
        );

        expect(result.requirement, UpdateRequirement.optional);
        expect(result.latestVersion, AppVersion.parse('1.2.0'));
        expect(result.triggeringVersion, AppVersion.parse('1.2.0'));
      },
    );

    test('exactly one required release between current and latest', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0', UpdatePolicy.required),
          _release('1.2.0', UpdatePolicy.optional),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

      expect(result.requirement, UpdateRequirement.required);
      expect(result.triggeringVersion, AppVersion.parse('1.1.0'));
      expect(result.latestVersion, AppVersion.parse('1.2.0'));
    });

    test('multiple required releases trigger on the closest one above '
        'current, not the latest', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0', UpdatePolicy.required),
          _release('1.2.0', UpdatePolicy.required),
          _release('1.3.0', UpdatePolicy.optional),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

      expect(result.requirement, UpdateRequirement.required);
      expect(result.triggeringVersion, AppVersion.parse('1.1.0'));
      expect(result.latestVersion, AppVersion.parse('1.3.0'));
    });

    test(
      'all releases above current optional resolves to optional at latest',
      () {
        final engine = VersionPolicyEngine(
          releases: [
            _release('1.0.0', UpdatePolicy.optional),
            _release('1.1.0', UpdatePolicy.optional),
            _release('1.2.0', UpdatePolicy.optional),
          ],
        );

        final result = engine.evaluate(
          currentVersion: AppVersion.parse('1.0.0'),
        );

        expect(result.requirement, UpdateRequirement.optional);
        expect(result.triggeringVersion, AppVersion.parse('1.2.0'));
        expect(result.latestVersion, AppVersion.parse('1.2.0'));
      },
    );

    test('result does not depend on the order releases were supplied in', () {
      final inOrder = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0', UpdatePolicy.optional),
          _release('1.2.0', UpdatePolicy.required),
          _release('1.3.0', UpdatePolicy.optional),
        ],
      );
      final shuffled = VersionPolicyEngine(
        releases: [
          _release('1.3.0', UpdatePolicy.optional),
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.2.0', UpdatePolicy.required),
          _release('1.1.0', UpdatePolicy.optional),
        ],
      );

      final current = AppVersion.parse('1.0.0');

      expect(
        inOrder.evaluate(currentVersion: current),
        shuffled.evaluate(currentVersion: current),
      );
    });

    test('a release exactly at the current version is not the trigger', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.required),
          _release('1.1.0', UpdatePolicy.optional),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

      expect(result.requirement, UpdateRequirement.optional);
      expect(result.triggeringVersion, AppVersion.parse('1.1.0'));
    });

    test('pre-release versions are ordered correctly on the upgrade path', () {
      final engine = VersionPolicyEngine(
        releases: [
          _release('1.0.0', UpdatePolicy.optional),
          _release('1.1.0-beta.1', UpdatePolicy.required),
          _release('1.1.0', UpdatePolicy.optional),
        ],
      );

      final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

      expect(result.requirement, UpdateRequirement.required);
      expect(result.triggeringVersion, AppVersion.parse('1.1.0-beta.1'));
      expect(result.latestVersion, AppVersion.parse('1.1.0'));
    });
  });
}
