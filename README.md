# Sprout

Flutter UI demonstration for laboratory No. 3, targeting iOS 15.0+. The app implements Log In, Sign Up, Forgot Password, Home, Profile and Change Password in English.

## Run

From this project directory, with Flutter and Xcode installed:

```sh
flutter pub get
flutter run
```

Select an available iOS Simulator. Devices used for verification:

```sh
flutter run -d 9FD8F88B-BC61-4A91-A25E-17FD7892CE7D
flutter run -d 25CAE2C0-164D-499B-950F-4019B3F9814A
```

These are the local iPhone 17 Pro and iPhone 17e device identifiers; other machines should use `flutter devices` for their own IDs. Both were inspected on iOS 26.5. Deployment target is 15.0; an iOS 15 runtime was not available for testing.

## Demo behavior

Log In accepts any input and uses the Figma demonstration profile. Sign Up uses the entered name/email, trimming whitespace and applying defaults separately for empty values. Passwords are confined to form controllers.

The Monstera task starts unfinished; tapping its circle toggles completion and the 1/0 watering count. Home/Profile share that state. Logging out discards the session; next login starts fresh. All data is in memory and disappears on restart.

Password reset/save display the approved demo messages and perform no account or email operation. Plant cards, plus and Edit Profile display the later-lab message. No validation, real authentication, Supabase or persistence is implemented.

## Structure

`lib/main.dart` launches `SproutApp` in `lib/app.dart`. Shared theme/widgets live in `lib/core`; screens are grouped under `lib/features/auth`, `home`, and `profile`. `lib/features/session` owns local session identity and task state. Navigation uses Navigator/CupertinoPageRoute; state uses StatefulWidget/setState.

Manrope, photos and SVGs are bundled under `assets`. Provenance and the avatar crop/shadow details are in [assets/README.md](assets/README.md). The app makes no runtime network calls.

Forms resize and scroll with the keyboard. Home preserves photo/card geometry and scrolls when native safe areas leave less room than the Figma mockup. System status bar and bottom indicator are managed by iOS.

## Checks and screenshots

```sh
flutter analyze
flutter test
```

Latest result: no analyzer issues; 13 tests passed. Tests cover routes, password visibility, signup values/defaults, messages, task/tab retention, logout, touch/mouse scrolling, and narrow 320×568 layouts with keyboard insets.

See [screenshot index](artifacts/screenshots/README.md) for both devices and keyboard evidence. [LAB3_PLAN.md](LAB3_PLAN.md) is the maintained ExecPlan; [PLANS.md](PLANS.md) defines its format. Git/GitHub setup and the final lab report are separate pending work.
