import 'package:flutter/cupertino.dart';

import '../../core/widgets/auth_links.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';
import 'auth_scope.dart';
import 'auth_action.dart';
import 'validation/auth_validators.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AuthAction<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  @override
  String get analyticsScreen => 'login';
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (busy || !_formKey.currentState!.validate()) return;
    final scope = AuthScope.of(context);
    if (await runAction(
      () =>
          scope.repository.signIn(email: _email.text, password: _password.text),
    )) {
      await scope.analytics.login();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AbsorbPointer(
      absorbing: busy,
      child: AuthPage(
        form: Form(
          key: _formKey,
          child: Column(
            children: [
              SproutTextField(
                enabled: !busy,
                label: 'Email',
                validator: AuthValidators.email,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SproutTextField(
                enabled: !busy,
                label: 'Password',
                validator: AuthValidators.requiredPassword,
                controller: _password,
                password: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 16),
              ActionError(actionError),
              SproutButton(label: 'Log In', loading: busy, onPressed: _login),
            ],
          ),
        ),
        footer: Column(
          children: [
            AuthLink(
              text: 'Forgot password?',
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              ),
            ),
            AccountLink(
              prompt: "Don't have an account? ",
              action: 'Sign up',
              onPressed: () => Navigator.of(context).push(
                CupertinoPageRoute<void>(builder: (_) => const SignupScreen()),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
