import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  const AnalyticsService([this.client]);
  final FirebaseAnalytics? client;
  Future<void> screen(String name) => _safely(() async {
    await client?.logScreenView(screenName: name);
  });
  Future<void> login() => _safely(() async {
    await client?.logLogin(loginMethod: 'password');
  });
  Future<void> signup() => _safely(() async {
    await client?.logSignUp(signUpMethod: 'password');
  });
  Future<void> _safely(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      /* Telemetry must not block authentication. */
    }
  }
}
