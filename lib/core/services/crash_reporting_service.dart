import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract final class CrashReportingService {
  static void install() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<void> sendTestError() async {
    if (!kDebugMode) return;
    await FirebaseCrashlytics.instance.recordError(
      StateError('Sprout laboratory 4 controlled non-fatal test'),
      StackTrace.current,
      reason: 'Intentional laboratory verification',
      fatal: false,
    );
    await FirebaseCrashlytics.instance.sendUnsentReports();
  }
}
