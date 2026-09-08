import 'app_version.dart';
import 'update_requirement.dart';

/// The outcome of evaluating a user's current version against a set of
/// releases: a fact about what update requirement applies, with no opinion
/// about how that fact should be presented to a user.
class UpdateResult {
  const UpdateResult({
    required this.currentVersion,
    required this.latestVersion,
    required this.requirement,
    required this.triggeringVersion,
  });

  /// The version the user is currently running.
  final AppVersion currentVersion;

  /// The latest version among the releases that were evaluated.
  final AppVersion latestVersion;

  /// Whether an update is unnecessary, optional, or required.
  final UpdateRequirement requirement;

  /// The version of the release responsible for [requirement].
  ///
  /// When [requirement] is [UpdateRequirement.required], this is the
  /// closest required release above [currentVersion] — the first blocker
  /// the user would hit — which is not necessarily [latestVersion].
  ///
  /// When [requirement] is [UpdateRequirement.optional], this is the
  /// release that set that verdict.
  ///
  /// `null` when [requirement] is [UpdateRequirement.none].
  final AppVersion? triggeringVersion;

  /// Whether any update is available at all, regardless of whether it's
  /// optional or required.
  bool get hasUpdate => requirement != UpdateRequirement.none;

  @override
  bool operator ==(Object other) =>
      other is UpdateResult &&
      other.currentVersion == currentVersion &&
      other.latestVersion == latestVersion &&
      other.requirement == requirement &&
      other.triggeringVersion == triggeringVersion;

  @override
  int get hashCode => Object.hash(
    currentVersion,
    latestVersion,
    requirement,
    triggeringVersion,
  );

  @override
  String toString() =>
      'UpdateResult('
      'currentVersion: $currentVersion, '
      'latestVersion: $latestVersion, '
      'requirement: $requirement, '
      'triggeringVersion: $triggeringVersion)';
}
