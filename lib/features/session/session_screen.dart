import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/widgets/sprout_icon.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/profile_screen.dart';
import 'demo_user.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.user});

  final DemoUser user;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int _tab = 0;
  bool _watered = false;

  void _logout() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _tab == 0 ? SproutColors.home : Colors.white,
    body: SafeArea(
      bottom: false,
      child: IndexedStack(
        index: _tab,
        children: [
          HomeScreen(
            user: widget.user,
            watered: _watered,
            onToggleWatering: () => setState(() => _watered = !_watered),
          ),
          ProfileScreen(
            user: widget.user,
            onHome: () => setState(() => _tab = 0),
            onLogout: _logout,
            onChangePassword: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => const ChangePasswordScreen(),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: _SproutTabs(
      selected: _tab,
      onSelected: (tab) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        setState(() => _tab = tab);
      },
    ),
  );
}

class _SproutTabs extends StatelessWidget {
  const _SproutTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: SproutColors.border)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          children: [
            for (var tab = 0; tab < 2; tab++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: selected == tab,
                  child: InkWell(
                    key: ValueKey(tab == 0 ? 'tab-home' : 'tab-profile'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelected(tab),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SproutIcon(
                          '${tab == 0 ? 'home' : 'profile'}-'
                          '${selected == tab ? 'active' : 'inactive'}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab == 0 ? 'Home' : 'Profile',
                          style: sproutText(
                            11,
                            weight: selected == tab
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected == tab
                                ? const Color(0xFF143326)
                                : SproutColors.green,
                          ),
                        ),
                      ],
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
