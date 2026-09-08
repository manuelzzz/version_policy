/// The update policy attached to a [Release], describing whether updating
/// to that release is optional or required.
enum UpdatePolicy {
  /// The user may update to this release, but is not required to.
  optional,

  /// The user must update to this release. Any [required] release on the
  /// upgrade path between a user's current version and the latest available
  /// version makes the overall update requirement `required`.
  required,
}
