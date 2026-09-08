import 'app_version.dart';
import 'duplicate_release_version_error.dart';
import 'release.dart';
import 'update_policy.dart';
import 'update_requirement.dart';
import 'update_result.dart';

/// Determines what update requirement applies to a user's current version,
/// given a set of releases.
///
/// The engine understands the *upgrade path*: any [UpdatePolicy.required]
/// release strictly between a user's current version and the latest
/// available version makes the overall result
/// [UpdateRequirement.required], even if the latest release itself is
/// optional.
class VersionPolicyEngine {
  /// Creates an engine over [releases].
  ///
  /// Throws [DuplicateReleaseVersionError] if [releases] contains two
  /// releases with the same [Release.version] (regardless of policy) — a
  /// single version can only mean one thing.
  VersionPolicyEngine({required List<Release> releases})
    : _sortedReleases = _sortedAndValidated(releases);

  final List<Release> _sortedReleases;

  static List<Release> _sortedAndValidated(List<Release> releases) {
    final sorted = List<Release>.of(releases)
      ..sort((a, b) => a.version.compareTo(b.version));

    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].version == sorted[i - 1].version) {
        throw DuplicateReleaseVersionError(sorted[i].version);
      }
    }

    return sorted;
  }

  /// Evaluates [currentVersion] against the releases this engine was
  /// created with.
  UpdateResult evaluate({required AppVersion currentVersion}) {
    if (_sortedReleases.isEmpty) {
      return UpdateResult(
        currentVersion: currentVersion,
        latestVersion: currentVersion,
        requirement: UpdateRequirement.none,
        triggeringVersion: null,
      );
    }

    final latestVersion = _sortedReleases.last.version;

    // Releases strictly above the current version, closest first, since
    // _sortedReleases is already ascending.
    final releasesAbove = _sortedReleases.where(
      (r) => r.version > currentVersion,
    );

    if (releasesAbove.isEmpty) {
      return UpdateResult(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        requirement: UpdateRequirement.none,
        triggeringVersion: null,
      );
    }

    for (final release in releasesAbove) {
      if (release.policy == UpdatePolicy.required) {
        return UpdateResult(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          requirement: UpdateRequirement.required,
          triggeringVersion: release.version,
        );
      }
    }

    // No required release on the path: latestVersion is always the last
    // (i.e. closest) entry in releasesAbove, since it's the maximum of all
    // releases and releasesAbove is non-empty.
    return UpdateResult(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      requirement: UpdateRequirement.optional,
      triggeringVersion: latestVersion,
    );
  }
}
