/// The update requirement determined by evaluating a user's current version
/// against a set of releases.
enum UpdateRequirement {
  /// The user is already on the latest version, or ahead of it. No update
  /// is available.
  none,

  /// An update is available, but none of the releases between the user's
  /// current version and the latest version are [required].
  optional,

  /// An update is available and at least one release between the user's
  /// current version and the latest version is required.
  required,
}
