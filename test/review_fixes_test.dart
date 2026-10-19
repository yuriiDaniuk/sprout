import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/app.dart';
import 'package:sprout/core/services/analytics_service.dart';
import 'package:sprout/features/auth/data/auth_repository.dart';
import 'package:sprout/features/profile/data/avatar_catalog.dart';
import 'package:sprout/features/profile/edit_profile_screen.dart';
import 'package:sprout/features/profile/change_password_screen.dart';
import 'package:sprout/features/session/app_user.dart';

import 'support/fake_auth_repository.dart';
import 'widget_test.dart' as harness;

class StagedProfileRepository extends FakeAuthRepository {
  Completer<void>? photoRequest;

  @override
  Future<void> updateProfile({
    required String name,
    required String? photoUrl,
  }) async {
    final old = currentUser!;
    publish(AppUser(uid: old.uid, name: name, email: old.email));
    if (photoRequest != null) await photoRequest!.future;
    if (failNext != null) {
      final message = failNext!;
      failNext = null;
      throw AuthFailure(message);
    }
    publish(
      AppUser(uid: old.uid, name: name, email: old.email, photoUrl: photoUrl),
    );
  }
}

class RecordingAnalytics extends AnalyticsService {
  final screens = <String>[];
  @override
  Future<void> screen(String name) async => screens.add(name);
}

Future<void> start(
  WidgetTester tester,
  FakeAuthRepository auth, {
  AnalyticsService analytics = const AnalyticsService(),
  double textScale = 1,
  bool keyboard = false,
}) async {
  addTearDown(auth.dispose);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(402, 874);
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  if (keyboard) tester.view.viewInsets = const FakeViewPadding(bottom: 336);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData.fromView(tester.view)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: SproutApp(auth: auth, analytics: analytics),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final failSave in [false, true]) {
    testWidgets(
      'Busy profile blocks back and unlocks after ${failSave ? 'failure' : 'success'}',
      (tester) async {
        final auth = FakeAuthRepository();
        await start(tester, auth);
        await harness.login(tester);
        await harness.profile(tester);
        await harness.tap(tester, find.text('Edit Profile'));
        await tester.enterText(harness.field('Name'), 'Saved Name');
        auth.delay = Completer<void>();
        if (failSave) auth.failNext = 'Unable to save.';
        await tester.ensureVisible(find.text('Save Changes'));
        await tester.tap(find.text('Save Changes'));
        await tester.pump();
        final back = find.byWidgetPredicate(
          (w) => w is IconButton && w.tooltip == 'Back',
        );
        expect(tester.widget<IconButton>(back).onPressed, isNull);
        final context = tester.element(find.byType(EditProfileScreen));
        await Navigator.of(context).maybePop();
        await tester.pump();
        await tester.dragFrom(const Offset(1, 400), const Offset(350, 0));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(EditProfileScreen), findsOneWidget);
        expect(auth.calls, 2); // Login and exactly one save.
        auth.delay!.complete();
        await tester.pumpAndSettle();
        if (failSave) {
          expect(find.text('Unable to save.'), findsOneWidget);
          expect(tester.widget<IconButton>(back).onPressed, isNotNull);
          await harness.tap(tester, back);
        } else {
          expect(find.text('Saved Name'), findsOneWidget);
          await harness.tap(tester, find.text('Edit Profile'));
          await harness.tap(tester, find.byTooltip('Back'));
        }
        expect(find.byType(EditProfileScreen), findsNothing);
      },
    );
  }

  testWidgets('Busy password change blocks back until the request finishes', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await harness.login(tester);
    await harness.profile(tester);
    await harness.tap(tester, find.text('Change Password'));
    await tester.enterText(harness.field('Current Password'), 'OldPassword1');
    await tester.enterText(harness.field('New Password'), 'NewPassword1');
    await tester.enterText(
      harness.field('Confirm New Password'),
      'NewPassword1',
    );
    auth.delay = Completer<void>();
    auth.failNext = 'Your current password is incorrect.';
    await tester.ensureVisible(find.text('Save Password'));
    await tester.tap(find.text('Save Password'));
    await tester.pump();
    final back = find.byWidgetPredicate(
      (w) => w is IconButton && w.tooltip == 'Back to Profile',
    );
    expect(tester.widget<IconButton>(back).onPressed, isNull);
    await Navigator.of(tester.element(find.byType(ChangePasswordScreen)))
        .maybePop();
    await tester.pump();
    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    auth.delay!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Your current password is incorrect.'), findsOneWidget);
    await harness.tap(tester, back);
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('Profile completion waits for photo, shows errors and retries', (
    tester,
  ) async {
    final auth = StagedProfileRepository()
      ..user = const AppUser(
        uid: 'partial',
        name: '',
        email: 'person@example.com',
      )
      ..photoRequest = Completer<void>()
      ..failNext = 'Avatar save failed.';
    await start(tester, auth);
    await tester.enterText(harness.field('Name'), 'Alex');
    await harness.tap(tester, find.text('Change Photo'));
    await harness.tap(tester, find.byKey(const ValueKey('avatar-0')));
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pump();
    expect(find.text('Complete Your Profile'), findsOneWidget);
    expect(find.text('Hi, Alex'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    auth.photoRequest!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Avatar save failed.'), findsOneWidget);
    expect(find.text('Complete Your Profile'), findsOneWidget);
    expect(
      tester.widget<TextField>(harness.field('Name')).controller!.text,
      'Alex',
    );
    auth.photoRequest = null;
    await harness.tap(tester, find.text('Save Changes'));
    expect(find.text('Hi, Alex'), findsOneWidget);
    expect(auth.currentUser!.photoUrl, avatarUrls.first);
  });

  testWidgets('Reset confirmation clears on email edits and failed retries', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await harness.tap(tester, find.text('Forgot password?'));
    await tester.enterText(harness.field('Email'), 'first@example.com');
    final confirmation = find.text(
      'If an account exists for this email, a password reset link has been sent.',
    );
    await harness.tap(tester, find.text('Send Reset Link'));
    expect(confirmation, findsOneWidget);
    tester.widget<TextField>(harness.field('Email')).controller!.selection =
        const TextSelection.collapsed(offset: 3);
    await tester.pump();
    expect(confirmation, findsOneWidget);
    await tester.enterText(harness.field('Email'), 'second@example.com');
    await tester.pump();
    expect(confirmation, findsNothing);
    await harness.tap(tester, find.text('Send Reset Link'));
    expect(confirmation, findsOneWidget);
    auth.delay = Completer<void>();
    auth.failNext = 'Check your internet connection and try again.';
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump();
    expect(confirmation, findsNothing);
    auth.delay!.complete();
    await tester.pumpAndSettle();
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
    expect(confirmation, findsNothing);
  });

  testWidgets('Login and signup fit enlarged text with the keyboard open', (
    tester,
  ) async {
    await start(tester, FakeAuthRepository(), textScale: 2, keyboard: true);
    expect(tester.takeException(), isNull);
    await harness.signup(tester);
    expect(tester.takeException(), isNull);
    await tester.enterText(harness.field('Name'), 'Alex');
    await tester.enterText(harness.field('Email'), 'alex@example.com');
    await tester.enterText(harness.field('Password'), 'Password1');
    await tester.ensureVisible(find.text('Sign Up'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Analytics records returning routes and tabs without rebuild duplicates',
    (tester) async {
      final auth = FakeAuthRepository();
      final analytics = RecordingAnalytics();
      await start(tester, auth, analytics: analytics);
      expect(analytics.screens, ['login']);
      await harness.signup(tester);
      expect(analytics.screens, ['login', 'signup']);
      await harness.tap(tester, find.text('Already have an account? Log In'));
      expect(analytics.screens, ['login', 'signup', 'login']);
      await harness.tap(tester, find.text('Forgot password?'));
      await harness.tap(tester, find.text('Back to Log In'));
      expect(analytics.screens.sublist(3), ['forgot_password', 'login']);
      await harness.login(tester);
      await harness.profile(tester);
      expect(analytics.screens.last, 'profile');
      await harness.tap(tester, find.text('Edit Profile'));
      await harness.tap(tester, find.byTooltip('Back'));
      expect(analytics.screens.sublist(analytics.screens.length - 2), [
        'edit_profile',
        'profile',
      ]);
      await harness.tap(tester, find.text('Change Password'));
      await harness.tap(tester, find.byTooltip('Back to Profile'));
      expect(analytics.screens.sublist(analytics.screens.length - 2), [
        'change_password',
        'profile',
      ]);
      final beforeRebuild = List<String>.of(analytics.screens);
      final old = auth.currentUser!;
      auth.publish(AppUser(uid: old.uid, name: 'Updated', email: old.email));
      await tester.pumpAndSettle();
      expect(analytics.screens, beforeRebuild);
      await harness.tap(tester, find.byKey(const ValueKey('tab-home')));
      expect(analytics.screens.last, 'home');
    },
  );
}
