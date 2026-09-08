# version_policy

A framework-agnostic version policy engine for Dart. Given an application's
current version and a set of releases, `version_policy` determines whether an
update is unnecessary, optional, or required — by walking the **upgrade
path**, not just comparing the current version to the latest one.

Pure Dart. No Flutter, no HTTP, no storage, no UI. It answers one question:

> Given this current version and these releases, what update requirement
> applies?

What you do with the answer — show a dialog, block startup, log a warning —
is up to you.

## Why not just compare current vs. latest?

Because a required update can sit *between* the version a user is on and the
latest release, and comparing only the two endpoints would miss it. Consider:

| Version | Policy   |
| ------- | -------- |
| 1.0.0   | Initial  |
| 1.1.0   | Optional |
| 1.2.0   | Optional |
| 1.3.0   | Required |
| 1.4.0   | Optional |

A user on `1.0.0` has a `1.4.0` release available, and `1.4.0` itself is only
optional. But `1.3.0` is required, and it's on the path between `1.0.0` and
`1.4.0` — so the correct answer for this user is `required`, not `optional`.

> Any required release in the upgrade path makes the resulting update
> requirement required.

## Usage

```dart
import 'package:version_policy/version_policy.dart';

void main() {
  final engine = VersionPolicyEngine(releases: [
    Release(
      version: AppVersion.parse('1.1.0'),
      policy: UpdatePolicy.optional,
    ),
    Release(
      version: AppVersion.parse('1.2.0'),
      policy: UpdatePolicy.optional,
    ),
    Release(
      version: AppVersion.parse('1.3.0'),
      policy: UpdatePolicy.required,
    ),
    Release(
      version: AppVersion.parse('1.4.0'),
      policy: UpdatePolicy.optional,
    ),
  ]);

  final result = engine.evaluate(
    currentVersion: AppVersion.parse('1.0.0'),
  );

  print(result.requirement); // UpdateRequirement.required
  print(result.latestVersion); // 1.4.0
  print(result.triggeringVersion); // 1.3.0 — the closest required release,
                                    // not necessarily the latest one
}
```

See [`example/version_policy_example.dart`](example/version_policy_example.dart)
for the full runnable example.

## Domain model

- **`AppVersion`** — a parsed, comparable SemVer version. `AppVersion.parse('1.2.3')`
  throws on invalid input; `AppVersion.tryParse('1.2.3')` returns `null` instead,
  useful when validating versions from an external source.
- **`Release`** — a version paired with an `UpdatePolicy`.
- **`UpdatePolicy`** — `optional` or `required`: whether updating *to* a
  given release is mandatory.
- **`UpdateRequirement`** — `none`, `optional`, or `required`: the engine's
  overall verdict for a given current version.
- **`UpdateResult`** — the full outcome of an evaluation: `currentVersion`,
  `latestVersion`, `requirement`, `triggeringVersion` (the release
  responsible for the verdict), and a `hasUpdate` convenience getter.
- **`VersionPolicyEngine`** — takes a list of `Release`s and evaluates a
  current version against them via `evaluate(currentVersion: ...)`.

## Behavior and edge cases

- **`triggeringVersion` is the *closest* blocker, not the latest.** When the
  result is `required`, `triggeringVersion` is the first required release
  above the current version — the one actually stopping the user — even if
  later releases exist.
- Releases at or below the current version are ignored; they only establish
  history, not the path forward.
- An empty release list, or a current version already at or ahead of the
  latest known release, resolves to `UpdateRequirement.none`.
- Release order passed to `VersionPolicyEngine` doesn't matter — the engine
  sorts internally, and the result is independent of input order.
- Two releases for the same version (regardless of policy) is invalid input:
  `VersionPolicyEngine`'s constructor throws `DuplicateReleaseVersionError`
  (an `ArgumentError` subtype carrying the offending version).
- Version comparison follows full SemVer precedence, including pre-release
  ordering (e.g. `1.1.0-beta.1 < 1.1.0`), via
  [`package:pub_semver`](https://pub.dev/packages/pub_semver).

## What this package is not

`version_policy` only makes the decision — it doesn't fetch release data and
it doesn't render anything. There's no HTTP client, no app-store integration,
and no UI. It's meant to sit underneath whatever fetches your release list
(a REST endpoint, a remote config service, a static JSON file) and whatever
presents the result to the user (a CLI message, a Flutter dialog, a log
line). A Flutter-specific presentation layer (`version_policy_flutter`) is
planned as a separate package that consumes `UpdateResult`, so this core
package can stay dependency-free.

## License

MIT — see [`LICENSE`](LICENSE).
