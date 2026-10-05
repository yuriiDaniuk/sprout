import 'package:flutter/cupertino.dart';

import '../../core/widgets/auth_links.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';
import '../session/demo_user.dart';
import '../session/session_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute<void>(
        builder: (_) => const SessionScreen(user: DemoUser.example),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => AuthPage(
    form: Column(
      children: [
        SproutTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        SproutTextField(
          label: 'Password',
          controller: _password,
          password: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 16),
        SproutButton(label: 'Log In', onPressed: _login),
      ],
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
  );
}
