import 'package:flutter/material.dart';

import '../theme/sprout_theme.dart';

class AuthLink extends StatelessWidget {
  const AuthLink({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: SproutColors.muted,
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: sproutText(14, weight: FontWeight.w500),
    ),
    child: Text(text, textAlign: TextAlign.center),
  );
}

class AccountLink extends StatelessWidget {
  const AccountLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size(44, 44),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    ),
    child: Text.rich(
      TextSpan(
        text: prompt,
        style: sproutText(14, color: SproutColors.muted),
        children: [
          TextSpan(
            text: action,
            style: sproutText(
              14,
              weight: FontWeight.w600,
              color: SproutColors.green,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    ),
  );
}
