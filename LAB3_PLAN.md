# Implement Sprout’s six laboratory screens

This ExecPlan is maintained according to root `PLANS.md`. Paths are relative to `/Users/urijdanuk/Desktop/KPP/laba3/sprout`. Keep its four living sections current.

## Purpose / Big Picture


Replace the generated counter with Sprout, an English plant care assistant for iOS 15.0+. A user can enter/create a demonstration session, toggle a watering task, view a profile, visit password forms, and log out. All six screens work locally without a backend. Run in iOS Simulator and navigate through the screens to see the result.

## Progress


- [x] (2026-10-05 16:01Z) Read project/rules and retrieve exact Figma contexts and screenshots for four existing designs.
- [x] (2026-10-05 16:16Z) Bundle all 20 Figma assets and Manrope/license; theme/shared widgets implemented.
- [x] (2026-10-05 16:36Z) Log In, Sign Up, Forgot Password implemented and inspected on 17 Pro; signup keyboard/identity and reset message exercised.
- [x] (2026-10-05 16:36Z) Home/task state inspected on 17 Pro; toggle, tab retention, logout reset and lower grid checked.
- [x] (2026-10-05 16:36Z) Profile/Change Password inspected on 17 Pro; avatar corrected, save/back/logout checked.
- [x] (2026-10-05 16:30Z) flutter analyze clean; all 13 interaction/layout/drag tests passed after visual and accessibility fixes.
- [x] (2026-10-05 16:48Z) Inspect all six screens on iPhone 17 Pro and 17e on iOS 26.5; keyboard inspected on signup/change forms and all forms tested at 320×568.
- [x] (2026-10-05 16:48Z) Save 16 screenshots, index them, update README and final evidence;21 Figma asset files verified nonempty.

## Surprises & Discoveries


The workspace is not a Git repository: `git status --short` reports `fatal: not a git repository`. Repository creation/publication details remain pending. This does not prevent UI work; do not invent GitHub settings.

Figma includes decorative status bars/home indicators. The user approved using native iOS system UI, so do not embed their artwork. The Home mockup says three plants while showing one task; accepted behavior deliberately changes this to one, then zero.

flutter_svg reports `unhandled element <filter/>` for the exported plus-button background. Its circle loads; the unsupported Figma shadow filter was supplemented with Flutter's BoxShadow without modifying the SVG. This is a non-fatal renderer warning, not an asset loading failure.

The avatar source image from design context loses Figma's custom fill crop. A focused context/screenshot for 16:358 and export of that individual image layer supply the exact 92×92 crop. Use avatar-cropped.png in Profile and retain the original as evidence. The extra Flutter border padding was removed.

Native safe areas take more height than Figma's decorative bars, so Home retains photo geometry and scrolls the lower row. Automation's drag/wheel did not visibly scroll, but keyboard focus traversal revealed all cards; touch/mouse gesture tests pass. This automation limitation is not a proven app defect.

## Decision Log


Decision (2026-10-05, user): use Navigator, CupertinoPageRoute, StatefulWidget/setState, flutter_svg, English, Manrope, and iOS 15.0+. No routing/state package, validation, real authorization, email sending, password changes, persistence, or backend. Empty signup identity values fall back individually to Figma defaults.

Decision (2026-10-05, implementation): the signed-in shell owns user/task state. Replace the route stack on login/signup/logout so discarded sessions cannot be reopened. Passwords remain only in form controllers, disposed with the screen. Exact approved demo messages appear as in-app messages.

Decision (2026-10-05, visual verification): preserve the exact SVG circle and add its unsupported shadow with Flutter; use the exported avatar image layer to preserve the Figma crop. These correct observed visual differences without changing product requirements.

## Outcomes & Retrospective


The accepted six-screen plan is complete. All six screens are implemented, inspected on iPhone 17 Pro and 17e, and documented with 16 screenshots. Analysis reports no issues and all 13 tests pass, including 320×568 keyboard/layout and touch/mouse drag checks. Signup identity, task retention/reversal, logout reset and exact demo messages work. Fonts/images are local; all 21 Figma asset files were confirmed nonempty. Native safe areas required scrolling on Home, and the avatar crop/SVG shadow required small fidelity corrections.

No product decisions remain for this UI scope. Real authorization, validation, persistence and backend are deliberately absent. Git/GitHub setup and the final laboratory report remain separate future work, as their details were not approved in this request. iOS 15 is the declared deployment minimum; testing used installed iOS 26.5 runtimes rather than an unavailable 15 runtime. iPhone 17 Pro was shut down after its verification to avoid automation switching between device windows; 17e remains running.

## Context and Orientation


At baseline `lib/main.dart` and `test/widget_test.dart` contained the counter. They now launch SproutApp and test its flows. `pubspec.yaml` has Dart `^3.13.2`, Flutter, cupertino_icons, flutter_svg 2.3.0, flutter_test and flutter_lints. iOS files under `ios/` target 15.0. `lib/core` holds shared Sprout widgets/theme and `lib/features` holds screens/session. `AGENTS.md` holds project constraints.

Figma file `tA5zaOIT7BGhdWOdU7VaTa`: Log In `2:4`, Sign Up `6:2`, Home `9:4`, Profile `16:339`. Fetch context and screenshot via Figma MCP with `skillNames: resource:figma-design-to-code`. React output is a visual reference to translate into Flutter. Download individual returned asset URLs promptly; never use a screen screenshot as app artwork. Forgot Password and Change Password use the accepted description in the same style.

Manrope weights 400/500/600/700/800; green #2d6a4f, text #1a2521, muted #5a6e66, Home #f6faf7, soft green #eaf2ec, input #f9fbf9, border #e2ebe5. Inputs/buttons have height56/radius16, auth horizontal padding32, main content padding24. Values are Flutter logical pixels (display-independent units). Logo circle64 contains tree32; avatar96; profile groups radius20. Native safe areas keep content clear of system UI; scroll forms when the keyboard reduces available height.

Demo identity: Yurii Daniuk, danukura2007@gmail.com. Home uses first name. Cards: Monstera / Monstera Deliciosa / Every 3 days; Snake Plant / Sansevieria / Every 10 days; Fiddle Leaf / Ficus Lyrata / Every 7 days; Pothos / Epipremnum / Every 5 days. Use exact four photos, separate task thumbnail and profile avatar, and exported SVGs.

## Plan of Work


### Milestone 1 — Foundation and Log In


Create `lib/app.dart` with SproutApp; keep main as entry point. Put theme in `lib/core/theme/sprout_theme.dart`. Bundle photos/icons in `assets/images`/`assets/icons`, Manrope and license in `assets/fonts`, declare pubspec entries and asset provenance. Create shared buttons, fields, brand header, page header, messages in `lib/core/widgets`. Password fields provide an accessible show/hide control with autocorrect/suggestions disabled.

Create `lib/features/auth/login_screen.dart`: Sprout logo/name/tagline, Email, Password, Log In, Forgot password?, signup link. Match Figma spacing, scroll for keyboard. Log In enters the shell with the demo user regardless of text. Run on 17 Pro, compare with Figma, confirm counter gone.

### Milestone 2 — Sign Up and Forgot Password


Create `lib/features/auth/signup_screen.dart` with Name, Email, Password, Sign Up and Figma footer. Define immutable DemoUser in `lib/features/session/demo_user.dart` with trimmed signup values and individual empty fallback. Do not include a password member. Sign Up opens shell with that identity.

Create `lib/features/auth/forgot_password_screen.dart`: brand, Forgot Password, Email, Send Reset Link, Back to Log In. Button shows `Demo mode: reset email was not sent.` Return goes to login even when opened from signup. Inspect navigation/keyboard in Simulator.

### Milestone 3 — Home


Create `lib/features/home/home_screen.dart` and stateful `lib/features/session/session_screen.dart`. Show greeting, `You have 1 plant to water today`, Today's Task, Monstera task, My Plants, plus, two rows of two cards. Initially empty checkbox toggles to checked/count0/`Watered today`; second tap restores count1 and `Needs watering today`. Circle remains28 with a larger tap target.

Plus/cards show `This feature will be available in a later lab.` Home/Profile tabs sit above native bottom safe area. Flexible widths and scrolling replace fixed page coordinates. Verify photo crops, both grid rows, task and messages in Simulator.

### Milestone 4 — Profile and Change Password


Create `lib/features/profile/profile_screen.dart`: back/title, Figma avatar, session name/email, Edit Profile, Change Password, Log Out; shell supplies tabs. Back selects Home. Edit Profile shows the later-lab message. Tabs preserve watering state. Log Out replaces all routes with fresh login, discarding user/task.

Create `lib/features/profile/change_password_screen.dart`: back/title, Current Password, New Password, Confirm New Password, Save Password. All three toggle visibility independently. Save shows `Demo mode: password was not changed.` without leaving. Back returns to Profile. Inspect all controls and keyboard on 17 Pro.

### Milestone 5 — Verification/evidence


Replace counter test with login/navigation, password visibility, signup values/fallbacks, reset message, reversible task/tab retention, future-feature messages, save/back, logout/reset tests. Exercise narrow surfaces and keyboard insets for layout exceptions. Run analyze/tests and fix actual failures.

Inspect17e as well as17 Pro. Save six clean PNGs under `artifacts/screenshots/iphone17pro`, smaller-device evidence under `artifacts/screenshots/iphone17e`, and an index. README explains run commands and local demo limits. Record actual evidence here.

## Concrete Steps


Run from `/Users/urijdanuk/Desktop/KPP/laba3/sprout`; Flutter is `/opt/homebrew/bin/flutter`. SDK/cache and CoreSimulator operations may require environment permission.

    flutter pub add flutter_svg
    dart format lib test
    flutter analyze
    flutter test
    flutter run -d 9FD8F88B-BC61-4A91-A25E-17FD7892CE7D

The first device is iPhone 17 Pro on iOS 26.5. Smaller17e uses `flutter run -d 25CAE2C0-164D-499B-950F-4019B3F9814A` after boot via Simulator/simctl. Running flutter accepts r (reload), R (restart), q (stop this session). Added assets/dependencies can need a rebuild.

Use computer-use tools for taps/typing/scrolling/visual checks. Capture current screen with:

    xcrun simctl io 9FD8F88B-BC61-4A91-A25E-17FD7892CE7D screenshot artifacts/screenshots/iphone17pro/01-login.png

Repeat after visiting signup, forgot, home, profile, change, naming02–06. Do not invoke backend or send messages.

## Validation and Acceptance


Analyze must report no issues; tests must pass. Before change Sprout tests fail because only counter exists. Launch: login visible, local assets load, no counter. Empty login opens Home/Yurii/count1. Checkbox → Profile → Home keeps count0. Second checkbox tap restores1. Each plus/card shows exact later-lab message.

Signup with Alex Green/alex@example.com shows Hi, Alex and full profile values. Empty signup uses defaults. Logout returns login; next login restores Yurii/unfinished task. Password/reset actions display exact demo text; save stays open. Reveal works independently on each password field. Both device sizes permit scrolling to actions with keyboard open; no overflow, image loading, or runtime exceptions.

## Idempotence and Recovery


Dependency resolution, format, analysis/tests, launch are repeatable. Do not regenerate the project or overwrite design files. Retry failed assets from refreshed Figma URLs, checking nonempty files. No migrations, runtime API keys, persistence, or external writes. Stop only Flutter sessions started for this work when rebuilding. Do not destroy simulators. Keep screenshot evidence for later report.

## Artifacts and Notes


`assets/README.md` records sources/layers; `assets/figma-manifest.json` maps 21 local Figma files. `artifacts/screenshots/README.md` indexes16 PNGs: six primary screens per device, extra lower-grid views on each, and signup/change keyboard evidence on 17e. Primary paths are01-login.png through06-change-password.png inside iphone17pro/iphone17e subdirectories.

Actual verification output:

    flutter analyze
    No issues found! (ran in 1.8s)
    flutter test
    00:03 +13: All tests passed!
    21 nonempty Figma asset files; 16 saved screenshots

Simulator builds completed successfully:17 Pro11.4s,17e89.5s during first boot. Neither run reported layout or asset-loading exceptions; the documented unsupported SVG filter warning remained harmless after adding its Flutter shadow.

## Interfaces and Dependencies


SproutApp is root MaterialApp, iOS ThemeData/Manrope. DemoUser contains name/email/firstName, no password. SessionScreen accepts DemoUser, owns tab and watering boolean, gives HomeScreen/ProfileScreen callbacks. Logout uses Navigator.pushAndRemoveUntil to LoginScreen. Screens dispose controllers. SproutTextField accepts label/controller/type/password toggle; SproutButton supplies shared primary action; shared message helper displays exact demo text. Use Flutter/Cupertino, flutter_svg, cupertino_icons, flutter_test/flutter_lints; bundle open font license. No Supabase/runtime network calls.

Revision note (2026-10-05): replace old planning draft with accepted six-screen behavior, verified Figma/Simulator references and executable checks.

Revision note (2026-10-05 16:16Z): record completed local implementation/assets, clean analysis and12 passing tests; retain simulator work as incomplete and document the SVG shadow limitation for inspection.

Revision note (2026-10-05): document visual fixes for avatar crop/border and SVG shadow found on 17 Pro; add accessible semantics to task, cards and tabs.

Revision note (2026-10-05 16:38Z): record completed17 Pro inspection, screenshots and 13 passing tests; 17e is running for the remaining smaller-screen checks. Document safe-area scrolling and automation observations.

Revision note (2026-10-05 16:48Z): mark the accepted UI plan complete after both-device inspection, keyboard verification and 16 screenshots; record actual results and distinguish declared iOS 15 support from tested iOS 26.5.

Revision note (2026-10-05, plus-button correction): after user visual feedback, position the plus glyph inside the same32×32 region at(6,6) as the SVG circle/shadow. Centering against the entire gesture area caused an upward offset under the surrounding row's constraints. Verified the corrected glyph on iPhone17e, ran flutter analyze with no issues, and refreshed iphone17e/04-home.png. Existing13 behavior tests remain the earlier full-suite evidence; no product behavior changed.

Revision note (2026-10-05, GitHub publication): initialized Git with branch `main`, committed the existing laboratory implementation, and published it to the user-selected public repository https://github.com/yuriiDaniuk/sprout. `origin/main` is configured as the upstream. Generated builds, local IDE state, and environment credentials are ignored. Earlier references to pending Git/GitHub setup describe the implementation-stage baseline; repository setup is now complete. The laboratory report remains pending.
