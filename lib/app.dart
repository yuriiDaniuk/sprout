import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'core/theme/sprout_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/auth/auth_scope.dart';
import 'features/auth/data/auth_repository.dart';
import 'core/services/analytics_service.dart';

class SproutApp extends StatelessWidget {
  const SproutApp({
    super.key,
    required this.auth,
    this.analytics = const AnalyticsService(),
  });
  final AuthRepository auth;
  final AnalyticsService analytics;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: MaterialApp(
      title: 'Sprout',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
        },
      ),
      theme: SproutTheme.light,
      home: AuthScope(
        repository: auth,
        analytics: analytics,
        child: const AuthGate(),
      ),
    ),
  );
}
