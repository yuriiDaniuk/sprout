import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/widgets/auth_links.dart';
import '../../core/widgets/auth_page.dart';
import 'auth_scope.dart';
import 'auth_action.dart';
import 'validation/auth_validators.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with AuthAction<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;
  String _lastEmail = '';
  @override
  String get analyticsScreen => 'forgot_password';

  @override
  void initState() {
    super.initState();
    _email.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    if (_email.text == _lastEmail) return;
    _lastEmail = _email.text;
    _clearConfirmation();
  }

  void _clearConfirmation() {
    if (_sent) setState(() => _sent = false);
  }

  @override
  void dispose() {
    _email.removeListener(_onEmailChanged);
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (busy || !_formKey.currentState!.validate()) return;
    _clearConfirmation();
    final repository = AuthScope.of(context).repository;
    if (await runAction(
          () => repository.sendPasswordReset(email: _email.text),
        ) &&
        mounted) {
      setState(() => _sent = true);
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
              Text(
                'Forgot Password',
                style: sproutText(24, weight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              SproutTextField(
                label: 'Email',
                enabled: !busy,
                validator: AuthValidators.email,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _send(),
              ),
              const SizedBox(height: 16),
              ActionError(actionError),
              if (_sent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      'If an account exists for this email, a password reset link has been sent.',
                      style: sproutText(14, color: SproutColors.green),
                    ),
                  ),
                ),
              SproutButton(
                label: 'Send Reset Link',
                loading: busy,
                onPressed: _send,
              ),
            ],
          ),
        ),
        footer: AuthLink(
          text: 'Back to Log In',
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    ),
  );
}
