// Run with: dart run example/version_policy_example.dart
import 'package:version_policy/version_policy.dart';

void main() {
  final engine = VersionPolicyEngine(
    releases: [
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
    ],
  );

  final result = engine.evaluate(currentVersion: AppVersion.parse('1.0.0'));

  print('requirement: ${result.requirement}');
  print('latestVersion: ${result.latestVersion}');
  print('triggeringVersion: ${result.triggeringVersion}');
  print('hasUpdate: ${result.hasUpdate}');

  switch (result.requirement) {
    case UpdateRequirement.none:
      print('You are up to date.');
    case UpdateRequirement.optional:
      print('An update is available, but not required.');
    case UpdateRequirement.required:
      print(
        'You must update to at least ${result.triggeringVersion} to '
        'continue.',
      );
  }
}
