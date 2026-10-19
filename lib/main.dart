import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crash_reporting_service.dart';
import 'core/theme/sprout_theme.dart';
import 'features/auth/data/auth_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SproutBootstrap());
}

class SproutBootstrap extends StatefulWidget {
  const SproutBootstrap({super.key});
  @override
  State<SproutBootstrap> createState() => _SproutBootstrapState();
}

class _SproutBootstrapState extends State<SproutBootstrap> {
  late Future<FirebaseAuthRepository> _startup;
  FirebaseAuthRepository? _repository;
  @override
  void initState() {
    super.initState();
    _startup = _initialize();
  }

  Future<FirebaseAuthRepository> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    CrashReportingService.install();
    if (const bool.fromEnvironment('CRASHLYTICS_TEST')) {
      await CrashReportingService.sendTestError();
    }
    return _repository = FirebaseAuthRepository();
  }

  @override
  void dispose() {
    _repository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseAuthRepository>(
    future: _startup,
    builder: (context, snapshot) {
      final repository = snapshot.data;
      if (repository != null) {
        return SproutApp(
          auth: repository,
          analytics: AnalyticsService(FirebaseAnalytics.instance),
        );
      }
      return MaterialApp(
        theme: SproutTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Unable to start Sprout. Please try again.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () =>
                                setState(() => _startup = _initialize()),
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
}
