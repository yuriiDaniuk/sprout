import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/app.dart';
import 'package:sprout/core/widgets/demo_message.dart';
import 'package:sprout/features/auth/login_screen.dart';

Future<void> start(
  WidgetTester tester, {
  Size size = const Size(402, 874),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = const FakeViewPadding(top: 62, bottom: 34);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const SproutApp());
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.hintText == label,
);

Future<void> login(WidgetTester tester) async =>
    tap(tester, find.text('Log In'));

Future<void> signupPage(WidgetTester tester) async =>
    tap(tester, find.text("Don't have an account? Sign up"));

void main() {
  testWidgets('Home responds to touch and mouse drag to reveal bottom cards', (
    tester,
  ) async {
    await start(tester);
    await login(tester);
    final card = find.byKey(const ValueKey('plant-pothos'));
    final originalTop = tester.getTopLeft(card).dy;
    await tester.dragFrom(const Offset(200, 600), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(originalTop));
    await tester.dragFrom(const Offset(200, 400), const Offset(0, 180));
    await tester.pumpAndSettle();
    final resetTop = tester.getTopLeft(card).dy;
    await tester.dragFrom(
      const Offset(200, 600),
      const Offset(0, -180),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(card).dy, lessThan(resetTop));
  });

  testWidgets('Login accepts demo input and replaces authentication routes', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('Sprout'), findsOneWidget);
    await tester.enterText(field('Email'), 'not-a-real-email');
    await tester.enterText(field('Password'), 'demo-input');
    await login(tester);
    expect(find.text('Hi, Yurii'), findsOneWidget);
    expect(find.text('You have 1 plant to water today'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(
      Navigator.of(tester.element(find.text('Hi, Yurii'))).canPop(),
      isFalse,
    );
    await tap(tester, find.byKey(const ValueKey('tab-profile')));
    expect(find.text('Yurii Daniuk'), findsOneWidget);
    expect(find.text('danukura2007@gmail.com'), findsOneWidget);
  });

  testWidgets('Login and signup passwords can be revealed and hidden', (
    tester,
  ) async {
    await start(tester);
    for (var screen = 0; screen < 2; screen++) {
      await tester.enterText(field('Password'), 'demo-secret');
      expect(tester.widget<TextField>(field('Password')).obscureText, isTrue);
      await tap(tester, find.byTooltip('Show Password'));
      expect(tester.widget<TextField>(field('Password')).obscureText, isFalse);
      expect(
        tester.widget<TextField>(field('Password')).controller!.text,
        'demo-secret',
      );
      await tap(tester, find.byTooltip('Hide Password'));
      expect(tester.widget<TextField>(field('Password')).obscureText, isTrue);
      if (screen == 0) await signupPage(tester);
    }
  });

  testWidgets('Signup passes trimmed name/email to Home and Profile', (
    tester,
  ) async {
    await start(tester);
    await signupPage(tester);
    await tester.enterText(field('Name'), '  Alex Green  ');
    await tester.enterText(field('Email'), '  alex@example.com  ');
    await tester.enterText(field('Password'), 'demo-only');
    await tap(tester, find.text('Sign Up'));
    expect(find.text('Hi, Alex'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('tab-profile')));
    expect(find.text('Alex Green'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('demo-only'), findsNothing);
  });

  for (final values in [
    ('', '', 'Yurii Daniuk', 'danukura2007@gmail.com'),
    ('Alex Green', ' ', 'Alex Green', 'danukura2007@gmail.com'),
    (' ', 'alex@example.com', 'Yurii Daniuk', 'alex@example.com'),
  ]) {
    testWidgets(
      'Signup fallback is independent for name/email: ${values.$1}/${values.$2}',
      (tester) async {
        await start(tester);
        await signupPage(tester);
        await tester.enterText(field('Name'), values.$1);
        await tester.enterText(field('Email'), values.$2);
        await tap(tester, find.text('Sign Up'));
        await tap(tester, find.byKey(const ValueKey('tab-profile')));
        expect(find.text(values.$3), findsOneWidget);
        expect(find.text(values.$4), findsOneWidget);
      },
    );
  }

  testWidgets(
    'Reset form is reachable from both auth screens and returns to Login',
    (tester) async {
      await start(tester);
      await tap(tester, find.text('Forgot password?'));
      expect(find.text('Forgot Password'), findsOneWidget);
      await tester.enterText(field('Email'), 'alex@example.com');
      await tap(tester, find.text('Send Reset Link'));
      expect(find.text('Demo mode: reset email was not sent.'), findsOneWidget);
      await tap(tester, find.text('Back to Log In'));
      expect(find.byType(LoginScreen), findsOneWidget);
      await signupPage(tester);
      await tap(tester, find.text('Forgot password?'));
      await tap(tester, find.text('Back to Log In'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing);
    },
  );

  testWidgets(
    'Watering is reversible and retained through tabs and profile back',
    (tester) async {
      await start(tester);
      await login(tester);
      await tap(tester, find.byKey(const ValueKey('watering-toggle')));
      expect(find.text('You have 0 plants to water today'), findsOneWidget);
      expect(find.text('Watered today'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('tab-profile')));
      await tap(tester, find.byKey(const ValueKey('tab-home')));
      expect(find.text('You have 0 plants to water today'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('tab-profile')));
      await tap(tester, find.byTooltip('Back to Home'));
      expect(find.text('You have 0 plants to water today'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('watering-toggle')));
      expect(find.text('You have 1 plant to water today'), findsOneWidget);
      expect(find.text('Needs watering today'), findsOneWidget);
    },
  );

  testWidgets(
    'Plus, all plant cards and Edit Profile explain the later feature',
    (tester) async {
      await start(tester);
      await login(tester);
      final addPlantButton = find.byKey(const ValueKey('add-plant'));
      expect(tester.getSize(addPlantButton), const Size(44, 44));
      expect(tester.getCenter(find.text('+')), tester.getCenter(addPlantButton));
      for (final key in [
        'add-plant',
        'plant-monstera',
        'plant-snake-plant',
        'plant-fiddle-leaf',
        'plant-pothos',
      ]) {
        await tap(tester, find.byKey(ValueKey(key)));
        expect(find.text(laterLabMessage), findsOneWidget);
      }
      await tap(tester, find.byKey(const ValueKey('tab-profile')));
      await tap(tester, find.text('Edit Profile'));
      expect(find.text(laterLabMessage), findsOneWidget);
    },
  );

  testWidgets(
    'Change Password reveals independently and save stays on the form',
    (tester) async {
      await start(tester);
      await login(tester);
      await tap(tester, find.byKey(const ValueKey('tab-profile')));
      await tap(tester, find.text('Change Password'));
      final labels = [
        'Current Password',
        'New Password',
        'Confirm New Password',
      ];
      for (final label in labels) {
        await tester.enterText(field(label), 'demo-input');
        expect(tester.widget<TextField>(field(label)).obscureText, isTrue);
      }
      for (final label in labels) {
        await tap(tester, find.byTooltip('Show $label'));
        expect(tester.widget<TextField>(field(label)).obscureText, isFalse);
        for (final other in labels.where((item) => item != label)) {
          expect(tester.widget<TextField>(field(other)).obscureText, isTrue);
        }
        await tap(tester, find.byTooltip('Hide $label'));
      }
      await tap(tester, find.text('Save Password'));
      expect(find.text('Demo mode: password was not changed.'), findsOneWidget);
      expect(field('Current Password'), findsOneWidget);
      await tap(tester, find.byTooltip('Back to Profile'));
      expect(find.text('Yurii Daniuk'), findsOneWidget);
    },
  );

  testWidgets(
    'Logout discards custom identity and task; fresh login resets them',
    (tester) async {
      await start(tester);
      await signupPage(tester);
      await tester.enterText(field('Name'), 'Alex Green');
      await tester.enterText(field('Email'), 'alex@example.com');
      await tap(tester, find.text('Sign Up'));
      await tap(tester, find.byKey(const ValueKey('watering-toggle')));
      await tap(tester, find.byKey(const ValueKey('tab-profile')));
      await tap(tester, find.text('Log Out'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(field('Email'), findsOneWidget);
      expect(
        tester.widget<TextField>(field('Email')).controller!.text,
        isEmpty,
      );
      expect(
        Navigator.of(tester.element(find.text('Sprout'))).canPop(),
        isFalse,
      );
      await login(tester);
      expect(find.text('Hi, Yurii'), findsOneWidget);
      expect(find.text('You have 1 plant to water today'), findsOneWidget);
    },
  );

  testWidgets(
    'All screens fit a narrow viewport; forms remain reachable with keyboard',
    (tester) async {
      await start(tester, size: const Size(320, 568));
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.enterText(field('Email'), 'alex@example.com');
      await tester.ensureVisible(find.text('Log In'));
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await signupPage(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.ensureVisible(field('Password'));
      await tester.ensureVisible(find.text('Sign Up'));
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Forgot password?'));
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Send Reset Link'));
      expect(tester.takeException(), isNull);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Back to Log In'));
      await login(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('plant-pothos')));
      await tap(tester, find.byKey(const ValueKey('tab-profile')));
      await tap(tester, find.text('Change Password'));
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save Password'));
      expect(tester.takeException(), isNull);
    },
  );
}
