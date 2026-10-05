import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/widgets/auth_links.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/demo_message.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _send() =>
      showDemoMessage(context, 'Demo mode: reset email was not sent.');

  @override
  Widget build(BuildContext context) => AuthPage(
    form: Column(
      children: [
        Text('Forgot Password', style: sproutText(24, weight: FontWeight.w700)),
        const SizedBox(height: 24),
        SproutTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _send(),
        ),
        const SizedBox(height: 16),
        SproutButton(label: 'Send Reset Link', onPressed: _send),
      ],
    ),
    footer: AuthLink(
      text: 'Back to Log In',
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    ),
  );
}
