import 'package:flutter/material.dart';

import '../theme/sprout_theme.dart';
import 'sprout_icon.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          color: SproutColors.softGreen,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const SproutIcon('tree-palm'),
      ),
      const SizedBox(height: 16),
      Text('Sprout', style: sproutText(24, weight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(
        'Plant Care Assistant',
        style: sproutText(14, color: SproutColors.muted),
      ),
    ],
  );
}
