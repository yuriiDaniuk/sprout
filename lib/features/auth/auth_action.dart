import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/services/screen_tracking_scope.dart';
import 'data/auth_repository.dart';
import 'auth_scope.dart';

mixin AuthAction<T extends StatefulWidget> on State<T> implements RouteAware {
  String? get analyticsScreen => null;
  bool _screenTracked = false;
  RouteObserver<PageRoute<dynamic>>? _observer;
  PageRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = ScreenTrackingScope.maybeOf(context);
    final route = ModalRoute.of(context);
    if (observer != _observer || route != _route) {
      _observer?.unsubscribe(this);
      _observer = observer;
      _route = route is PageRoute<dynamic> ? route : null;
      if (observer != null && _route != null) {
        observer.subscribe(this, _route!);
        return;
      }
    }
    if (observer == null && !_screenTracked) {
      _screenTracked = true;
      _trackScreen();
    }
  }

  void _trackScreen() {
    final name = analyticsScreen;
    if (name != null) {
      AuthScope.of(context).analytics.screen(name);
    }
  }

  @override
  void didPush() => _trackScreen();

  @override
  void didPopNext() => _trackScreen();

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void dispose() {
    _observer?.unsubscribe(this);
    super.dispose();
  }

  bool busy = false;
  String? actionError;
  Future<bool> runAction(Future<void> Function() action) async {
    if (busy) return false;
    FocusScope.of(context).unfocus();
    setState(() {
      busy = true;
      actionError = null;
    });
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      if (mounted) setState(() => actionError = e.message);
      return false;
    } catch (_) {
      if (mounted) {
        setState(() => actionError = 'Something went wrong. Please try again.');
      }
      return false;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class ActionError extends StatelessWidget {
  const ActionError(this.message, {super.key});
  final String? message;
  @override
  Widget build(BuildContext context) => message == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            liveRegion: true,
            child: Text(
              message!,
              style: sproutText(14, color: const Color(0xFFB3261E)),
            ),
          ),
        );
}
