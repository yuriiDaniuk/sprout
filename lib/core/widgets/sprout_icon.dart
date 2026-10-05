import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Uses each exported SVG's original width and height.
class SproutIcon extends StatelessWidget {
  const SproutIcon(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/icons/$name.svg', excludeFromSemantics: true);
}
