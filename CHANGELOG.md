# Changelog

## 0.1.0-dev

Initial development release. Core domain model and evaluation engine:

- `AppVersion` — a comparable, SemVer-backed version type (wraps `pub_semver`).
- `Release` — a version paired with an `UpdatePolicy`.
- `UpdatePolicy` — `optional` or `required`.
- `UpdateRequirement` — `none`, `optional`, or `required`.
- `UpdateResult` — the outcome of an evaluation, including the
  `triggeringVersion` responsible for the verdict and a `hasUpdate`
  convenience getter.
- `VersionPolicyEngine` — evaluates a current version against a list of
  releases, walking the full upgrade path so that any required release
  between the current and latest version makes the result required.
  Rejects duplicate versions in the release list with `ArgumentError`.
