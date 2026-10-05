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
- Version control: Git, with a new GitHub repository planned; repository details are pending.
- Planned backend for later laboratory work: Supabase Auth, Database, and Storage. Supabase is not connected in the current project.

For laboratory work No. 3, implement UI, navigation, and demonstration state locally without backend integration. Use Navigator/CupertinoPageRoute and StatefulWidget/setState; do not add routing or state-management packages. Follow the accepted scope and progress in LAB3_PLAN.md. Ask the user about missing design or product requirements rather than inventing them.
