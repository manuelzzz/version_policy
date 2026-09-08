import 'package:pub_semver/pub_semver.dart' as pub_semver;

/// A parsed, comparable application version.
///
/// Wraps [package:pub_semver](https://pub.dev/packages/pub_semver) so
/// `version_policy` benefits from correct SemVer parsing and ordering
/// (including pre-release precedence) without exposing a third-party type
/// on its own public API.
class AppVersion implements Comparable<AppVersion> {
  AppVersion._(this._version);

  final pub_semver.Version _version;

  /// Parses [input] as a SemVer version string (e.g. `'1.2.3'`,
  /// `'1.2.3-beta.1'`).
  ///
  /// Throws a [FormatException] if [input] is not a valid SemVer version.
  /// Use [tryParse] instead if [input] comes from an untrusted source and a
  /// `null` result is preferable to an exception.
  factory AppVersion.parse(String input) {
    return AppVersion._(pub_semver.Version.parse(input));
  }

  /// Parses [input] as a SemVer version string, returning `null` instead of
  /// throwing if [input] is not a valid SemVer version.
  static AppVersion? tryParse(String input) {
    try {
      return AppVersion.parse(input);
    } on FormatException {
      return null;
    }
  }

  @override
  int compareTo(AppVersion other) => _version.compareTo(other._version);

  bool operator <(AppVersion other) => _version < other._version;

  bool operator <=(AppVersion other) => _version <= other._version;

  bool operator >(AppVersion other) => _version > other._version;

  bool operator >=(AppVersion other) => _version >= other._version;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && _version == other._version;

  @override
  int get hashCode => _version.hashCode;

  @override
  String toString() => _version.toString();
}
