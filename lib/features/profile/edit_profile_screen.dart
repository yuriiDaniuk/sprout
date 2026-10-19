import 'package:flutter/material.dart';

import '../../core/theme/sprout_theme.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/sprout_button.dart';
import '../../core/widgets/sprout_text_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../auth/auth_action.dart';
import '../auth/auth_scope.dart';
import '../auth/validation/auth_validators.dart';
import 'data/avatar_catalog.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    this.completeSignup = false,
    this.onCompleted,
  });
  final bool completeSignup;
  final VoidCallback? onCompleted;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with AuthAction<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  String? _photo;
  bool _initialized = false;
  @override
  String get analyticsScreen => 'edit_profile';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final scope = AuthScope.of(context);
    final user = scope.repository.currentUser!;
    _name = TextEditingController(text: user.name);
    _email = TextEditingController(text: user.email);
    _photo = user.photoUrl;
    _initialized = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (busy || !_form.currentState!.validate()) return;
    final repository = AuthScope.of(context).repository;
    final saved = await runAction(
      () => repository.updateProfile(name: _name.text, photoUrl: _photo),
    );
    if (!saved || !mounted) return;
    if (widget.completeSignup) {
      widget.onCompleted?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _choose() async {
    FocusScope.of(context).unfocus();
    final url = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Avatar',
                style: sproutText(22, weight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: (MediaQuery.sizeOf(context).width - 48).clamp(
                  0.0,
                  MediaQuery.sizeOf(context).height * .6,
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: avatarUrls.length,
                  itemBuilder: (context, i) => Semantics(
                    button: true,
                    selected: _photo == avatarUrls[i],
                    label: 'Avatar ${i + 1}',
                    child: InkWell(
                      key: ValueKey('avatar-$i'),
                      onTap: () => Navigator.of(context).pop(avatarUrls[i]),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _photo == avatarUrls[i]
                                ? SproutColors.green
                                : SproutColors.border,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: UserAvatar(url: avatarUrls[i]),
                            ),
                            if (_photo == avatarUrls[i])
                              const Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.check_circle,
                                  color: SproutColors.green,
                                ),
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
    if (url != null && mounted) setState(() => _photo = url);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.completeSignup)
              PageHeader(
                title: 'Edit Profile',
                onBack: () => Navigator.of(context).pop(),
                backEnabled: !busy,
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Complete Your Profile',
                  style: sproutText(22, weight: FontWeight.w700),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 416),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          UserAvatar(url: _photo),
                          TextButton(
                            onPressed: busy ? null : _choose,
                            child: Text(
                              'Change Photo',
                              style: sproutText(
                                14,
                                color: SproutColors.green,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SproutTextField(
                            label: 'Name',
                            controller: _name,
                            validator: AuthValidators.name,
                            enabled: !busy,
                          ),
                          const SizedBox(height: 16),
                          SproutTextField(
                            label: 'Email',
                            controller: _email,
                            readOnly: true,
                          ),
                          const SizedBox(height: 24),
                          ActionError(actionError),
                          SproutButton(
                            label: 'Save Changes',
                            onPressed: _save,
                            loading: busy,
                          ),
                          if (widget.completeSignup)
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () => runAction(
                                      AuthScope.of(context).repository.signOut,
                                    ),
                              child: const Text('Log Out'),
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
