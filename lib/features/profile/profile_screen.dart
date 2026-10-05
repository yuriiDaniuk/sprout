import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/widgets/demo_message.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_icon.dart';
import '../session/demo_user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onHome,
    required this.onLogout,
    required this.onChangePassword,
  });

  final DemoUser user;
  final VoidCallback onHome;
  final VoidCallback onLogout;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PageHeader(title: 'Profile', onBack: onHome, backLabel: 'Back to Home'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SproutColors.profileBorder,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar-cropped.png',
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        semanticLabel: 'Profile photo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: sproutText(24, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: sproutText(14, color: SproutColors.profileMuted),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: SproutColors.profileSurface,
                      border: Border.all(color: SproutColors.profileBorder),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _SettingsRow(
                          title: 'Edit Profile',
                          icon: 'edit-profile',
                          onPressed: () =>
                              showDemoMessage(context, laterLabMessage),
                        ),
                        const _SettingsLine(),
                        _SettingsRow(
                          title: 'Change Password',
                          icon: 'lock',
                          onPressed: onChangePassword,
                        ),
                        const _SettingsLine(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SproutButton(
                    label: 'Log Out',
                    onPressed: onLogout,
                    destructive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2EB),
              shape: BoxShape.circle,
            ),
            child: SproutIcon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: sproutText(16, weight: FontWeight.w500)),
          ),
          const SproutIcon('chevron-right'),
        ],
      ),
    ),
  );
}

class _SettingsLine extends StatelessWidget {
  const _SettingsLine();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 1,
    width: double.infinity,
    child: FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: 322,
        height: 1,
        child: SproutIcon('settings-line'),
      ),
    ),
  );
}
