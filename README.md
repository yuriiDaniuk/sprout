# Sprout

Plant care assistant built with Flutter for iOS 15.0+. Laboratory No. 4 adds Firebase Authentication, Analytics and Crashlytics to the interface from No. 3. The interface uses bundled Manrope, Figma SVGs, Navigator/CupertinoPageRoute and StatefulWidget/setState.

Public repository: https://github.com/yuriiDaniuk/sprout, branch `main`.

## Run

Install Flutter, Xcode and FlutterFire CLI. The generated Crashlytics build phase uses the FlutterFire executable from the Pub cache.

```sh
flutter pub get
dart pub global activate flutterfire_cli
flutter devices
flutter run -d <your-iOS-simulator-id>
```

On this machine iPhone 17 Pro is `9FD8F88B-BC61-4A91-A25E-17FD7892CE7D`. An iOS 15 runtime was not available; device verification uses iOS 26.5.

## Firebase

Project: `sprout-a6523`. iOS bundle ID: `com.example.sprout`. FlutterFire configuration is in `lib/firebase_options.dart`, `firebase.json`, and `ios/Runner/GoogleService-Info.plist`. These are client configuration files, not administrator credentials. Never add service-account keys, passwords, refresh tokens or reset links to the repository.

If configuring a different project, install the official Firebase CLI (`npm install -g firebase-tools`), sign in with `firebase login`, and run:

```sh
flutterfire configure --project=<your-project-id> --platforms=ios --ios-bundle-id=com.example.sprout
```

Email/Password must be enabled. Password enforcement is Require with a minimum length of 8 and an uppercase character. Other complexity requirements are not enabled. Auth uses the same policy locally when creating a new password. Reset emails open the standard Firebase browser page.

Authentication restores the SDK-managed session. Signup requires a name, valid email and compliant password. Profile editing saves a display name and photo URL. Current-password reauthentication precedes a password change. Sign Out clears the authenticated navigation stack. Failed requests show user-facing errors; in-flight requests block repeated submissions. No email verification gate or social login is required by the accepted scope.

The eight profile avatars are user-selected SHAREit characters extracted from a supplied screenshot, with user-approved PNG publication in commit `5d4edfc2da3409a50ae610e600095021d68af82b`. Their HTTPS URLs are stored in Firebase; bundled copies are a fallback. See `assets/avatars/README.md` for provenance.

Plant data and watering remain local demonstrations. They reset with a new session or restart. Plant cards and Add Plant show the later-lab message. No plant database, media uploads or push notifications are included in No. 4.

## Architecture

`lib/main.dart` initializes Firebase and error reporting, then launches `SproutApp`. `AuthScope` provides an injectable `AuthRepository` and `AnalyticsService`. `AuthGate` selects the signed-out or authenticated navigation stack by user identity. It also handles completing a restored profile without a name.

`FirebaseAuthRepository` is the only class that talks to Firebase Auth. It listens to Firebase user changes and publishes immutable `AppUser` values. Profile changes preserve the same user's task/tab state; a changed uid resets the session. Screens keep only form state and invoke repository methods. Tests inject a local fake repository, without network credentials.

`SessionScreen` listens directly to the repository and passes its current user to both Home and Profile. Saving a name updates the greeting immediately; Home displays the first word of the name.

`lib/core/widgets` contains shared fields, buttons, headers and avatar display; `lib/core/theme` contains visual styles. Authentication forms live in `lib/features/auth`, profile forms in `lib/features/profile`, and the authenticated shell in `lib/features/session`.

## Analytics and Crashlytics

Analytics records successful login/signup and explicit screen views. Page views are tracked on entry and return using RouteObserver/RouteAware. Home/Profile views are also tracked when tabs change, because they use IndexedStack rather than pushed routes. Passwords, email addresses and names are not event parameters.

Crashlytics captures framework and uncaught asynchronous errors. The generated Xcode build phase uploads symbols. A development-only controlled non-fatal error can be sent with:

```sh
flutter run -d <your-iOS-simulator-id> --dart-define=CRASHLYTICS_TEST=true
```

Use a normal run after this check to avoid repeating the intentional error. The test hook is disabled in release builds. Confirm the issue in the Firebase console; local logging alone does not prove delivery.

Debug builds generate dSYM symbols, including Runner.debug.dylib. If the console reports missing symbols for a simulator build, upload the matching `build/ios/Debug-iphonesimulator/Runner.app.dSYM` using the Firebase SDK's `Crashlytics/upload-symbols` script. The controlled non-fatal report was verified with readable Dart source locations; evidence is saved in `artifacts/lab4/crashlytics-readable-stack.png`.

## Validation

```sh
flutter analyze
flutter test
```

Widget tests cover validation, request errors/loading, session routing, profile drafts, avatars, password changes, keyboard layouts and the retained local plant interactions. Profile and password forms block back navigation while saving. Repository unit tests verify partial registration recovery and preserve errors for attempts with another email. Real authentication, reset email delivery, session restoration, Analytics and Crashlytics require the configured Firebase project and a simulator/device. Verification progress and remaining manual checks are recorded in `LAB4_PLAN.md`. `LAB3_PLAN.md` preserves the completed UI-stage history.

On 2026-10-19, analysis passed with no issues and all 30 tests passed. Real registration, password change, reset email, session restoration, profile updates, Analytics DebugView and the controlled Crashlytics report were confirmed. Real device network disconnection has not been manually verified; repository error handling and retries are covered by automated tests.

The No. 4 report is outside the current implementation scope.
