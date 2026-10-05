import 'package:flutter/material.dart';

import '../theme/sprout_theme.dart';
import 'sprout_icon.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.backLabel = 'Back',
  });

  final String title;
  final VoidCallback onBack;
  final String backLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        IconButton(
          tooltip: backLabel,
          onPressed: onBack,
          icon: const SproutIcon('chevron-left'),
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: sproutText(18, weight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 44),
      ],
    ),
  );
}
