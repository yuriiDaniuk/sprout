import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/sprout_theme.dart';
import '../../features/profile/data/avatar_catalog.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.url, this.size = 96});
  final String? url;
  final double size;
  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: SproutColors.softGreen,
      child: Icon(
        Icons.person_outline,
        size: size * .5,
        color: SproutColors.green,
      ),
    );
    final address = url;
    final fallback = address != null && avatarUrls.contains(address)
        ? Image.asset(
            'assets/avatars/${Uri.parse(address).pathSegments.last}',
            fit: BoxFit.cover,
          )
        : placeholder;
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: address == null || address.isEmpty
            ? placeholder
            : Uri.tryParse(address)?.path.endsWith('/svg') == true ||
                  Uri.tryParse(address)?.path.endsWith('.svg') == true
            ? SvgPicture.network(
                address,
                fit: BoxFit.cover,
                placeholderBuilder: (_) => fallback,
                errorBuilder: (_, _, _) => fallback,
              )
            : Image.network(
                address,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}
