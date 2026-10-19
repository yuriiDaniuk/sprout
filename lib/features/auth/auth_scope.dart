import 'package:flutter/widgets.dart';

import '../../core/services/analytics_service.dart';
import 'data/auth_repository.dart';

class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.repository,
    required this.analytics,
    required super.child,
  });
  final AuthRepository repository;
  final AnalyticsService analytics;
  static AuthScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!;
  @override
  bool updateShouldNotify(AuthScope oldWidget) =>
      repository != oldWidget.repository || analytics != oldWidget.analytics;
}
