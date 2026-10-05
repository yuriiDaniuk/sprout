import 'package:flutter/cupertino.dart';

import '../../core/widgets/auth_links.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';
import '../session/demo_user.dart';
import '../session/session_screen.dart';
import 'forgot_password_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signup() {
    FocusScope.of(context).unfocus();
    final user = DemoUser.fromSignup(name: _name.text, email: _email.text);
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute<void>(builder: (_) => SessionScreen(user: user)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => AuthPage(
    form: Column(
      children: [
        SproutTextField(label: 'Name', controller: _name),
        const SizedBox(height: 16),
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
          onSubmitted: (_) => _signup(),
        ),
        const SizedBox(height: 16),
        SproutButton(label: 'Sign Up', onPressed: _signup),
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
          prompt: 'Already have an account? ',
          action: 'Log In',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
