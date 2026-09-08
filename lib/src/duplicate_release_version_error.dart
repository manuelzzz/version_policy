import 'app_version.dart';
import 'release.dart';

/// Thrown by `VersionPolicyEngine` when its release list contains more than
/// one [Release] for the same [Release.version] — a single version can only
/// mean one thing, regardless of whether the duplicate entries agree on
/// [Release.policy].
class DuplicateReleaseVersionError extends ArgumentError {
  DuplicateReleaseVersionError(this.version)
    : super('releases contains more than one release for version $version');

  /// The version that appeared more than once.
  final AppVersion version;
}
