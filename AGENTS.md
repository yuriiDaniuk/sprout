# ExecPlans

When writing complex features or significant refactors, use an ExecPlan (as described in PLANS.md) from design to implementation.

# Project Stack

- Application: Sprout, a plant care assistant.
- Framework: Flutter.
- Language: Dart; SDK constraint `^3.13.2` in `pubspec.yaml`.
- Target platform: iOS 15.0+.
- UI: Flutter widgets, with Material and Cupertino components available. Follow the user-provided Figma designs.
- Icons: local Figma SVGs via `flutter_svg`, and `cupertino_icons` for password visibility controls.
- Typography: locally bundled Manrope.
- Testing: `flutter_test`.
- Static analysis: `flutter analyze`, using `flutter_lints`.
- iOS tooling: Xcode and the iOS Simulator.
- Design source: Figma file `tA5zaOIT7BGhdWOdU7VaTa`; access is connected.
- Version control: Git; public repository https://github.com/yuriiDaniuk/sprout, default branch `main`.
- Laboratory No. 4 backend: Firebase Authentication, Analytics, and Crashlytics; project `sprout-a6523`. User approved Firebase in place of the Supabase proposal from laboratory No. 2. Plant database/storage work is deferred.

For laboratory work No. 3, implement UI, navigation, and demonstration state locally without backend integration. Use Navigator/CupertinoPageRoute and StatefulWidget/setState; do not add routing or state-management packages. Follow the accepted scope and progress in LAB3_PLAN.md. Ask the user about missing design or product requirements rather than inventing them.

For laboratory work No. 4, follow LAB4_PLAN.md. Use Firebase Auth through AuthRepository, Form validation, and the accepted Edit Profile design. Keep plant data local until the later laboratory stage. The user-approved eight SHAREit PNG avatars are hosted in the public repository; do not publish other new changes without authorization.
