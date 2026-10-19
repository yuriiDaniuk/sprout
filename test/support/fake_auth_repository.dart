import 'dart:async';

import 'package:sprout/features/auth/data/auth_repository.dart';
import 'package:sprout/features/session/app_user.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.user, this.initializing = false});
  AppUser? user;
  @override
  AppUser? get currentUser => user;
  @override
  bool initializing;
  String? failNext;
  Completer<void>? delay;
  int calls = 0;
  int resets = 0;
  int passwordChanges = 0;
  final testUser = const AppUser(
    uid: 'test-user',
    name: 'Yurii Daniuk',
    email: 'danukura2007@gmail.com',
  );
  Future<void> _request() async {
    calls++;
    if (delay != null) await delay!.future;
    final error = failNext;
    failNext = null;
    if (error != null) throw AuthFailure(error);
  }

  void publish(AppUser? user) {
    this.user = user;
    initializing = false;
    notifyListeners();
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _request();
    publish(testUser);
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _request();
    publish(AppUser(uid: 'new-user', name: name.trim(), email: email.trim()));
  }

  @override
  Future<void> signOut() async {
    await _request();
    publish(null);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await _request();
    resets++;
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String? photoUrl,
  }) async {
    await _request();
    publish(
      AppUser(
        uid: currentUser!.uid,
        name: name.trim(),
        email: currentUser!.email,
        photoUrl: photoUrl,
      ),
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _request();
    passwordChanges++;
  }
}
