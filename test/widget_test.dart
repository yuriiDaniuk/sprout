import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/app.dart';
import 'package:sprout/features/auth/login_screen.dart';
import 'package:sprout/features/auth/auth_scope.dart';
import 'package:sprout/core/services/analytics_service.dart';
import 'package:sprout/features/session/session_screen.dart';
import 'package:sprout/features/auth/validation/auth_validators.dart';
import 'package:sprout/features/session/app_user.dart';

import 'support/fake_auth_repository.dart';

Finder field(String label) => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == label,
);
Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> start(
  WidgetTester tester,
  FakeAuthRepository auth, {
  Size size = const Size(402, 874),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);
  addTearDown(auth.dispose);
  await tester.pumpWidget(SproutApp(auth: auth));
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester) async {
  await tester.enterText(field('Email'), 'person@example.com');
  await tester.enterText(field('Password'), 'Password1');
  await tap(tester, find.text('Log In'));
}

Future<void> signup(WidgetTester tester) =>
    tap(tester, find.text("Don't have an account? Sign up"));
Future<void> profile(WidgetTester tester) =>
    tap(tester, find.byKey(const ValueKey('tab-profile')));

void main() {
  testWidgets('Session observes profile changes without recreating its route', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    auth.user = auth.testUser;
    addTearDown(auth.dispose);
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AuthScope(
        repository: auth,
        analytics: AnalyticsService(),
        child: const MaterialApp(home: SessionScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const ValueKey('watering-toggle')));
    await profile(tester);
    for (final name in ['Alex Green', 'Olena Green']) {
      await tap(tester, find.text('Edit Profile'));
      await tester.enterText(field('Name'), name);
      await tap(tester, find.text('Save Changes'));
      expect(find.text(name), findsOneWidget);
      expect(
        find.text('Hi, ${name.split(' ').first}', skipOffstage: false),
        findsOneWidget,
      );
    }
    await tap(tester, find.byKey(const ValueKey('tab-home')));
    expect(find.text('Hi, Olena'), findsOneWidget);
    expect(find.text('You have 0 plants to water today'), findsOneWidget);
  });

  test('Validation follows only the accepted password policy', () {
    expect(AuthValidators.name('  '), isNotNull);
    expect(AuthValidators.email('bad'), isNotNull);
    expect(AuthValidators.email(' person@example.com '), isNull);
    expect(AuthValidators.newPassword('Abcdefg'), isNotNull);
    expect(AuthValidators.newPassword('abcdefgh'), isNotNull);
    expect(AuthValidators.newPassword('ABCDEFGH'), isNull);
    expect(AuthValidators.newPassword('Abcdefgh'), isNull);
    expect(AuthValidators.requiredPassword('short'), isNull);
  });

  testWidgets('Empty login validates without sending a request', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await tap(tester, find.text('Log In'));
    expect(auth.calls, 0);
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets(
    'Successful login replaces forms; logout removes the session stack',
    (tester) async {
      final auth = FakeAuthRepository();
      await start(tester, auth);
      await signup(tester);
      await tester.enterText(field('Name'), 'Alex');
      await tester.enterText(field('Email'), 'alex@example.com');
      await tester.enterText(field('Password'), 'Password1');
      await tap(tester, find.text('Sign Up'));
      expect(find.text('Hi, Alex'), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing);
      await profile(tester);
      await tap(tester, find.text('Log Out'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Alex'), findsNothing);
      await login(tester);
      expect(find.text('Hi, Yurii'), findsOneWidget);
    },
  );

  testWidgets(
    'Signup requires name and strong password; passes trimmed values',
    (tester) async {
      final auth = FakeAuthRepository();
      await start(tester, auth);
      await signup(tester);
      await tester.enterText(field('Email'), 'alex@example.com');
      await tester.enterText(field('Password'), 'abcdefgh');
      await tap(tester, find.text('Sign Up'));
      expect(auth.calls, 0);
      expect(find.text('Enter your name.'), findsOneWidget);
      expect(
        find.text('Include at least one uppercase letter (A–Z).'),
        findsOneWidget,
      );
      await tester.enterText(field('Name'), '  Alex Green  ');
      await tester.enterText(field('Password'), 'Abcdefgh');
      await tap(tester, find.text('Sign Up'));
      await profile(tester);
      expect(find.text('Alex Green'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
    },
  );

  testWidgets('Server errors stay on login and allow retry', (tester) async {
    final auth = FakeAuthRepository()
      ..failNext = 'Check your internet connection and try again.';
    await start(tester, auth);
    await login(tester);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );
    expect(find.byType(LoginScreen), findsOneWidget);
    await tap(tester, find.text('Log In'));
    expect(find.text('Hi, Yurii'), findsOneWidget);
  });

  testWidgets('Loading blocks duplicate button and keyboard submissions', (
    tester,
  ) async {
    final auth = FakeAuthRepository()..delay = Completer<void>();
    await start(tester, auth);
    await tester.enterText(field('Email'), 'person@example.com');
    await tester.enterText(field('Password'), 'Password1');
    await tester.tap(find.text('Log In'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    tester.widget<TextField>(field('Password')).onSubmitted?.call('Password1');
    await tester.pump();
    expect(auth.calls, 1);
    expect(tester.widget<TextField>(field('Email')).enabled, isFalse);
    auth.delay!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Hi, Yurii'), findsOneWidget);
  });

  testWidgets(
    'Password visibility preserves input on both authentication forms',
    (tester) async {
      await start(tester, FakeAuthRepository());
      for (var i = 0; i < 2; i++) {
        await tester.enterText(field('Password'), 'Password1');
        expect(tester.widget<TextField>(field('Password')).obscureText, isTrue);
        await tap(tester, find.byTooltip('Show Password'));
        expect(
          tester.widget<TextField>(field('Password')).obscureText,
          isFalse,
        );
        expect(
          tester.widget<TextField>(field('Password')).controller!.text,
          'Password1',
        );
        await tap(tester, find.byTooltip('Hide Password'));
        if (i == 0) await signup(tester);
      }
    },
  );

  testWidgets(
    'Reset validates, calls repository and returns to login from signup',
    (tester) async {
      final auth = FakeAuthRepository();
      await start(tester, auth);
      await signup(tester);
      await tap(tester, find.text('Forgot password?'));
      await tap(tester, find.text('Send Reset Link'));
      expect(auth.resets, 0);
      await tester.enterText(field('Email'), 'person@example.com');
      await tap(tester, find.text('Send Reset Link'));
      expect(auth.resets, 1);
      expect(
        find.text(
          'If an account exists for this email, a password reset link has been sent.',
        ),
        findsOneWidget,
      );
      await tap(tester, find.text('Back to Log In'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing);
    },
  );

  testWidgets('Restored user opens Home without a login action', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    auth.publish(auth.testUser);
    await start(tester, auth);
    expect(find.text('Hi, Yurii'), findsOneWidget);
    expect(auth.calls, 0);
  });

  testWidgets('Watering state survives tabs and same-user profile updates', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await login(tester);
    await tap(tester, find.byKey(const ValueKey('watering-toggle')));
    await profile(tester);
    auth.publish(
      const AppUser(
        uid: 'test-user',
        name: 'New Name',
        email: 'person@example.com',
      ),
    );
    await tester.pumpAndSettle();
    await tap(tester, find.byTooltip('Back to Home'));
    expect(find.text('Hi, New'), findsOneWidget);
    expect(find.text('You have 0 plants to water today'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('watering-toggle')));
    expect(find.text('You have 1 plant to water today'), findsOneWidget);
  });

  testWidgets(
    'New identity resets local task and removes an open profile form',
    (tester) async {
      final auth = FakeAuthRepository();
      await start(tester, auth);
      await login(tester);
      await tap(tester, find.byKey(const ValueKey('watering-toggle')));
      await profile(tester);
      await tap(tester, find.text('Change Password'));
      auth.publish(
        const AppUser(
          uid: 'different',
          name: 'Other',
          email: 'other@example.com',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hi, Other'), findsOneWidget);
      expect(field('Current Password'), findsNothing);
      expect(find.text('You have 1 plant to water today'), findsOneWidget);
    },
  );

  testWidgets('Edit profile cancels draft, saves changes, preserves email', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await login(tester);
    await profile(tester);
    await tap(tester, find.text('Edit Profile'));
    await tester.enterText(field('Name'), 'Cancelled');
    expect(tester.widget<TextField>(field('Email')).readOnly, isTrue);
    await tap(tester, find.byTooltip('Back'));
    expect(find.text('Yurii Daniuk'), findsOneWidget);
    await tap(tester, find.text('Edit Profile'));
    await tester.enterText(field('Name'), '  Alex Green  ');
    await tap(tester, find.text('Save Changes'));
    expect(find.text('Alex Green'), findsOneWidget);
    expect(auth.currentUser!.email, 'danukura2007@gmail.com');
    await tap(tester, find.byKey(const ValueKey('tab-home')));
    expect(find.text('Hi, Alex'), findsOneWidget);
  });

  testWidgets('Profile save failure keeps the draft and can be retried', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await login(tester);
    await profile(tester);
    await tap(tester, find.text('Edit Profile'));
    await tester.enterText(field('Name'), 'Alex');
    auth.failNext = 'Unable to save. Try again.';
    await tap(tester, find.text('Save Changes'));
    expect(find.text('Unable to save. Try again.'), findsOneWidget);
    expect(tester.widget<TextField>(field('Name')).controller!.text, 'Alex');
    await tap(tester, find.text('Save Changes'));
    expect(find.text('Alex'), findsOneWidget);
  });

  testWidgets(
    'Password change validates confirmation and handles reauthentication errors',
    (tester) async {
      final auth = FakeAuthRepository();
      await start(tester, auth);
      await login(tester);
      await profile(tester);
      await tap(tester, find.text('Change Password'));
      await tester.enterText(field('Current Password'), 'OldPassword1');
      await tester.enterText(field('New Password'), 'NewPassword1');
      await tester.enterText(field('Confirm New Password'), 'different');
      await tap(tester, find.text('Save Password'));
      expect(auth.passwordChanges, 0);
      expect(find.text('Passwords do not match.'), findsOneWidget);
      await tester.enterText(field('Confirm New Password'), 'NewPassword1');
      auth.failNext = 'Please log out and log in again, then retry.';
      await tap(tester, find.text('Save Password'));
      expect(
        find.text('Please log out and log in again, then retry.'),
        findsOneWidget,
      );
      for (final label in [
        'Current Password',
        'New Password',
        'Confirm New Password',
      ]) {
        await tap(tester, find.byTooltip('Show $label'));
        expect(tester.widget<TextField>(field(label)).obscureText, isFalse);
        await tap(tester, find.byTooltip('Hide $label'));
      }
      await tap(tester, find.text('Save Password'));
      expect(auth.passwordChanges, 1);
      expect(find.text('Your password has been changed.'), findsOneWidget);
      expect(
        tester.widget<TextField>(field('New Password')).controller!.text,
        isEmpty,
      );
    },
  );

  testWidgets(
    'Plant placeholders and the user-adjusted plus remain functional',
    (tester) async {
      await start(tester, FakeAuthRepository());
      await login(tester);
      final add = find.byKey(const ValueKey('add-plant'));
      expect(tester.getSize(add), const Size(44, 44));
      expect(
        tester.getRect(add).contains(tester.getCenter(find.text('+'))),
        isTrue,
      );
      for (final key in [
        'add-plant',
        'plant-monstera',
        'plant-snake-plant',
        'plant-fiddle-leaf',
        'plant-pothos',
      ]) {
        await tap(tester, find.byKey(ValueKey(key)));
        expect(
          find.text('This feature will be available in a later lab.'),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('Avatar is a draft until Save Changes, and cancel discards it', (
    tester,
  ) async {
    final auth = FakeAuthRepository();
    await start(tester, auth);
    await login(tester);
    await profile(tester);
    await tap(tester, find.text('Edit Profile'));
    await tap(tester, find.text('Change Photo'));
    expect(find.text('Choose Avatar'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('avatar-2')));
    expect(auth.currentUser!.photoUrl, isNull);
    await tap(tester, find.byTooltip('Back'));
    expect(auth.currentUser!.photoUrl, isNull);
    await tap(tester, find.text('Edit Profile'));
    await tap(tester, find.text('Change Photo'));
    await tap(tester, find.byKey(const ValueKey('avatar-2')));
    await tap(tester, find.text('Save Changes'));
    expect(auth.currentUser!.photoUrl, endsWith('/shareit-carrot.png'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home scroll reveals lower cards', (tester) async {
    await start(tester, FakeAuthRepository());
    await login(tester);
    final card = find.byKey(const ValueKey('plant-pothos'));
    final before = tester.getTopLeft(card).dy;
    await tester.dragFrom(const Offset(200, 600), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(before));
  });

  testWidgets('Incomplete restored profile requires completion before Home', (
    tester,
  ) async {
    final auth = FakeAuthRepository(
      user: const AppUser(
        uid: 'incomplete',
        name: '',
        email: 'person@example.com',
      ),
    );
    await start(tester, auth);
    expect(find.text('Complete Your Profile'), findsOneWidget);
    await tester.enterText(field('Name'), 'Finished');
    await tap(tester, find.text('Save Changes'));
    expect(find.text('Hi, Finished'), findsOneWidget);
  });

  testWidgets(
    'Forms and actions remain reachable on a narrow screen with keyboard',
    (tester) async {
      final auth = FakeAuthRepository();
      await start(tester, auth, size: const Size(320, 568));
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.pumpAndSettle();
      await signup(tester);
      await tap(tester, find.text('Sign Up'));
      expect(tester.takeException(), isNull);
      await tester.enterText(field('Name'), 'Alex');
      await tester.enterText(field('Email'), 'alex@example.com');
      await tester.enterText(field('Password'), 'Password1');
      await tap(tester, find.text('Sign Up'));
      await profile(tester);
      await tap(tester, find.text('Edit Profile'));
      await tap(tester, find.text('Save Changes'));
      expect(tester.takeException(), isNull);
    },
  );
}
