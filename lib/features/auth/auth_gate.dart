import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/services/screen_tracking_scope.dart';
import '../profile/edit_profile_screen.dart';
import '../session/session_screen.dart';
import 'auth_scope.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final repository = AuthScope.of(context).repository;
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        if (repository.initializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = repository.currentUser;
        // Changing identity replaces the entire nested route stack, including pushed forms.
        return _AuthNavigator(key: ValueKey(user?.uid ?? 'signed-out'));
      },
    );
  }
}

class _AuthNavigator extends StatefulWidget {
  const _AuthNavigator({super.key});

  @override
  State<_AuthNavigator> createState() => _AuthNavigatorState();
}

class _AuthNavigatorState extends State<_AuthNavigator> {
  final _observer = RouteObserver<PageRoute<dynamic>>();

  @override
  Widget build(BuildContext context) => ScreenTrackingScope(
    observer: _observer,
    child: Navigator(
      observers: [_observer],
      onGenerateRoute: (_) =>
          CupertinoPageRoute<void>(builder: (_) => const _AuthLanding()),
    ),
  );
}

class _AuthLanding extends StatefulWidget {
  const _AuthLanding();

  @override
  State<_AuthLanding> createState() => _AuthLandingState();
}

class _AuthLandingState extends State<_AuthLanding> {
  bool? _needsCompletion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _needsCompletion ??=
        AuthScope.of(context).repository.currentUser?.name.trim().isEmpty ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final repository = AuthScope.of(context).repository;
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final user = repository.currentUser;
        if (user == null) return const LoginScreen();
        // Firebase can publish the name before the photo request completes.
        if (_needsCompletion! || user.name.trim().isEmpty) {
          return EditProfileScreen(
            completeSignup: true,
            onCompleted: () => setState(() => _needsCompletion = false),
          );
        }
        return SessionScreen(key: ValueKey(user.uid));
      },
    );
  }
}
