import 'package:test/test.dart';
import 'package:version_policy/version_policy.dart';

void main() {
  group('Release', () {
    test('exposes the version and policy it was constructed with', () {
      final release = Release(
        version: AppVersion.parse('1.3.0'),
        policy: UpdatePolicy.required,
      );

      expect(release.version, AppVersion.parse('1.3.0'));
      expect(release.policy, UpdatePolicy.required);
    });

    test('two releases with the same version and policy are equal', () {
      final a = Release(
        version: AppVersion.parse('1.2.0'),
        policy: UpdatePolicy.optional,
      );
      final b = Release(
        version: AppVersion.parse('1.2.0'),
        policy: UpdatePolicy.optional,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test(
      'releases with the same version but different policy are not equal',
      () {
        final a = Release(
          version: AppVersion.parse('1.2.0'),
          policy: UpdatePolicy.optional,
        );
        final b = Release(
          version: AppVersion.parse('1.2.0'),
          policy: UpdatePolicy.required,
        );

        expect(a, isNot(b));
      },
    );

    test(
      'releases with the same policy but different version are not equal',
      () {
        final a = Release(
          version: AppVersion.parse('1.2.0'),
          policy: UpdatePolicy.optional,
        );
        final b = Release(
          version: AppVersion.parse('1.3.0'),
          policy: UpdatePolicy.optional,
        );

        expect(a, isNot(b));
      },
    );

    test('toString includes the version and policy', () {
      final release = Release(
        version: AppVersion.parse('1.2.0'),
        policy: UpdatePolicy.required,
      );

      expect(release.toString(), contains('1.2.0'));
      expect(release.toString(), contains('required'));
    });
  });
}
