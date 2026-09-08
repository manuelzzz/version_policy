import 'package:test/test.dart';
import 'package:version_policy/version_policy.dart';

void main() {
  group('DuplicateReleaseVersionError', () {
    test('exposes the offending version', () {
      final error = DuplicateReleaseVersionError(AppVersion.parse('1.2.0'));

      expect(error.version, AppVersion.parse('1.2.0'));
    });

    test('is an ArgumentError', () {
      final error = DuplicateReleaseVersionError(AppVersion.parse('1.2.0'));

      expect(error, isArgumentError);
    });

    test('message mentions the offending version', () {
      final error = DuplicateReleaseVersionError(AppVersion.parse('1.2.0'));

      expect(error.message, contains('1.2.0'));
    });
  });
}
