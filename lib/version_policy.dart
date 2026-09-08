/// A framework-agnostic version policy engine for determining what kind of
/// update action an application should take based on its current version
/// and a set of available releases.
library;

export 'src/app_version.dart' show AppVersion;
export 'src/duplicate_release_version_error.dart'
    show DuplicateReleaseVersionError;
export 'src/release.dart' show Release;
export 'src/update_policy.dart' show UpdatePolicy;
export 'src/update_requirement.dart' show UpdateRequirement;
export 'src/update_result.dart' show UpdateResult;
export 'src/version_policy_engine.dart' show VersionPolicyEngine;
