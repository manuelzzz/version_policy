import 'package:test/test.dart';
import 'package:version_policy/version_policy.dart';

void main() {
  group('AppVersion.parse', () {
    test('parses a valid SemVer string', () {
      final version = AppVersion.parse('1.2.3');
      expect(version.toString(), '1.2.3');
    });

    test('parses a version with a pre-release tag', () {
      final version = AppVersion.parse('1.2.3-beta.1');
      expect(version.toString(), '1.2.3-beta.1');
    });

    test('parses a version with build metadata', () {
      final version = AppVersion.parse('1.2.3+001');
      expect(version.toString(), '1.2.3+001');
    });

    test('throws FormatException for invalid input', () {
      expect(() => AppVersion.parse('not-a-version'), throwsFormatException);
    });

    test('throws FormatException for an empty string', () {
      expect(() => AppVersion.parse(''), throwsFormatException);
    });
  });

  group('AppVersion.tryParse', () {
    test('returns a matching AppVersion for valid input', () {
      expect(AppVersion.tryParse('1.2.3'), AppVersion.parse('1.2.3'));
    });

    test('returns null for invalid input', () {
      expect(AppVersion.tryParse('not-a-version'), isNull);
    });

    test('returns null for an empty string', () {
      expect(AppVersion.tryParse(''), isNull);
    });
  });

  group('equality', () {
    test('two versions parsed from the same string are equal', () {
      expect(AppVersion.parse('1.2.3'), AppVersion.parse('1.2.3'));
    });

    test('two versions parsed from different strings are not equal', () {
      expect(AppVersion.parse('1.2.3'), isNot(AppVersion.parse('1.2.4')));
    });

    test('equal versions have equal hashCodes', () {
      expect(
        AppVersion.parse('1.2.3').hashCode,
        AppVersion.parse('1.2.3').hashCode,
      );
    });
  });

  group('ordering', () {
    test('compareTo orders by major, then minor, then patch', () {
      expect(
        AppVersion.parse('1.0.0').compareTo(AppVersion.parse('2.0.0')),
        lessThan(0),
      );
      expect(
        AppVersion.parse('1.1.0').compareTo(AppVersion.parse('1.2.0')),
        lessThan(0),
      );
      expect(
        AppVersion.parse('1.1.1').compareTo(AppVersion.parse('1.1.2')),
        lessThan(0),
      );
      expect(AppVersion.parse('1.2.3').compareTo(AppVersion.parse('1.2.3')), 0);
    });

    test('pre-release versions sort before their stable release', () {
      expect(
        AppVersion.parse('1.0.0-beta.1') < AppVersion.parse('1.0.0'),
        isTrue,
      );
    });

    test('comparison operators are consistent with compareTo', () {
      final lower = AppVersion.parse('1.0.0');
      final higher = AppVersion.parse('1.1.0');

      expect(lower < higher, isTrue);
      expect(lower <= higher, isTrue);
      expect(higher > lower, isTrue);
      expect(higher >= lower, isTrue);
      expect(lower <= AppVersion.parse('1.0.0'), isTrue);
      expect(lower >= AppVersion.parse('1.0.0'), isTrue);
    });

    test('sorting a list orders versions ascending', () {
      final versions = [
        AppVersion.parse('1.3.0'),
        AppVersion.parse('1.1.0'),
        AppVersion.parse('1.2.0'),
      ]..sort();

      expect(versions.map((v) => v.toString()), ['1.1.0', '1.2.0', '1.3.0']);
    });
  });
}
