import 'app_version.dart';
import 'update_policy.dart';

/// A single published application release and the policy for updating *to*
/// it.
///
/// [Release] carries no opinion about ordering relative to other releases or
/// about duplicate versions — those are concerns of whatever evaluates a
/// collection of releases (see `VersionPolicyEngine`), not of a single
/// release in isolation.
class Release {
  const Release({required this.version, required this.policy});

  /// The version this release identifies.
  final AppVersion version;

  /// Whether updating to [version] is optional or required.
  final UpdatePolicy policy;

  @override
  bool operator ==(Object other) =>
      other is Release && other.version == version && other.policy == policy;

  @override
  int get hashCode => Object.hash(version, policy);

  @override
  String toString() => 'Release($version, $policy)';
}
