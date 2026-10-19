import 'package:flutter/material.dart';

import '../../core/widgets/demo_message.dart';
import '../auth/auth_scope.dart';
import '../auth/auth_action.dart';
import '../auth/validation/auth_validators.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with AuthAction<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  String get analyticsScreen => 'change_password';

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (busy || !_formKey.currentState!.validate()) return;
    final repository = AuthScope.of(context).repository;
    if (await runAction(
          () => repository.changePassword(
            currentPassword: _current.text,
            newPassword: _new.text,
          ),
        ) &&
        mounted) {
      _current.clear();
      _new.clear();
      _confirm.clear();
      _formKey.currentState!.reset();
      showDemoMessage(context, 'Your password has been changed.');
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(
              title: 'Change Password',
              onBack: () => Navigator.of(context).pop(),
              backLabel: 'Back to Profile',
              backEnabled: !busy,
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 416),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SproutTextField(
                            label: 'Current Password',
                            enabled: !busy,
                            validator: AuthValidators.requiredPassword,
                            controller: _current,
                            password: true,
                          ),
                          const SizedBox(height: 16),
                          SproutTextField(
                            label: 'New Password',
                            enabled: !busy,
                            validator: AuthValidators.newPassword,
                            controller: _new,
                            password: true,
                          ),
                          const SizedBox(height: 16),
                          SproutTextField(
                            label: 'Confirm New Password',
                            enabled: !busy,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Confirm your new password.'
                                : value != _new.text
                                ? 'Passwords do not match.'
                                : null,
                            controller: _confirm,
                            password: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _save(),
                          ),
                          const SizedBox(height: 24),
                          ActionError(actionError),
                          SproutButton(
                            label: 'Save Password',
                            loading: busy,
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
