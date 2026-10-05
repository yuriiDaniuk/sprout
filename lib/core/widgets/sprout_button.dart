import 'package:flutter/material.dart';

import '../theme/sprout_theme.dart';

class SproutButton extends StatelessWidget {
  const SproutButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(destructive ? 20 : 16),
      boxShadow: destructive
          ? null
          : const [
              BoxShadow(
                color: Color(0x1F2D6A4F),
                offset: Offset(0, 8),
                blurRadius: 16,
              ),
            ],
    ),
    child: SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: destructive
              ? const Color(0xFFFFF5F5)
              : SproutColors.green,
          foregroundColor: destructive ? const Color(0xFFD32F2F) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(destructive ? 20 : 16),
            side: destructive
                ? const BorderSide(color: Color(0xFFFFE3E3))
                : BorderSide.none,
          ),
          textStyle: sproutText(16, weight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    ),
  );
}
