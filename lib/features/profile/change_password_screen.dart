import 'package:flutter/material.dart';

import '../../core/widgets/demo_message.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() =>
      showDemoMessage(context, 'Demo mode: password was not changed.');

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          PageHeader(
            title: 'Change Password',
            onBack: () => Navigator.of(context).pop(),
            backLabel: 'Back to Profile',
          ),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 416),
                  child: Column(
                    children: [
                      SproutTextField(
                        label: 'Current Password',
                        controller: _current,
                        password: true,
                      ),
                      const SizedBox(height: 16),
                      SproutTextField(
                        label: 'New Password',
                        controller: _new,
                        password: true,
                      ),
                      const SizedBox(height: 16),
                      SproutTextField(
                        label: 'Confirm New Password',
                        controller: _confirm,
                        password: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: 24),
                      SproutButton(label: 'Save Password', onPressed: _save),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
