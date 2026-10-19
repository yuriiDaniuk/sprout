import 'package:flutter/cupertino.dart';

import '../../core/widgets/auth_links.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';
import 'auth_scope.dart';
import 'auth_action.dart';
import 'validation/auth_validators.dart';
import 'forgot_password_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with AuthAction<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  @override
  String get analyticsScreen => 'signup';
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (busy || !_formKey.currentState!.validate()) return;
    final scope = AuthScope.of(context);
    if (await runAction(
      () => scope.repository.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      ),
    )) {
      await scope.analytics.signup();
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
                label: 'Name',
                controller: _name,
                enabled: !busy,
                validator: AuthValidators.name,
              ),
              const SizedBox(height: 16),
              SproutTextField(
                label: 'Email',
                enabled: !busy,
                validator: AuthValidators.email,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              SproutTextField(
                label: 'Password',
                enabled: !busy,
                validator: AuthValidators.newPassword,
                controller: _password,
                password: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signup(),
              ),
              const SizedBox(height: 16),
              ActionError(actionError),
              SproutButton(label: 'Sign Up', loading: busy, onPressed: _signup),
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
              prompt: 'Already have an account? ',
              action: 'Log In',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
