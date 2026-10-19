import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../session/app_user.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract class AuthRepository extends ChangeNotifier {
  AppUser? get currentUser;
  bool get initializing;
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> sendPasswordReset({required String email});
  Future<void> updateProfile({required String name, required String? photoUrl});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class FirebaseAuthRepository extends AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance {
    _subscription = _auth.userChanges().listen(
      (user) {
        if (_registering) return;
        _publish(user);
      },
      onError: (Object _) {
        _initializing = false;
        notifyListeners();
      },
    );
  }
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _subscription;
  AppUser? _user;
  bool _initializing = true;
  bool _registering = false;
  String? _incompleteSignupUid;
  @override
  AppUser? get currentUser => _user;
  @override
  bool get initializing => _initializing;

  void _publish(User? user) {
    _initializing = false;
    _user = user == null
        ? null
        : AppUser(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            photoUrl: user.photoURL,
          );
    notifyListeners();
  }

  Future<void> _request(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_message(error.code));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) => _request(() async {
    _registering = true;
    try {
      User? user = _auth.currentUser;
      if (_incompleteSignupUid == null ||
          user?.uid != _incompleteSignupUid ||
          user?.email != email.trim()) {
        user = (await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )).user!;
        _incompleteSignupUid = user.uid;
      }
      try {
        await user!.updateDisplayName(name.trim());
      } on FirebaseAuthException {
        throw const AuthFailure(
          'Your account was created, but your name could not be saved. Tap Sign Up again to finish.',
        );
      }
      _incompleteSignupUid = null;
      _publish(_auth.currentUser);
    } finally {
      _registering = false;
    }
  });

  @override
  Future<void> signIn({required String email, required String password}) =>
      _request(() async {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        _publish(_auth.currentUser);
      });
  @override
  Future<void> signOut() => _request(() async {
    await _auth.signOut();
    _incompleteSignupUid = null;
    _publish(null);
  });
  @override
  Future<void> sendPasswordReset({required String email}) => _request(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found') rethrow;
    }
  });
  @override
  Future<void> updateProfile({
    required String name,
    required String? photoUrl,
  }) => _request(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('Please log in again.');
    try {
      await user.updateDisplayName(name.trim());
      await user.updatePhotoURL(photoUrl);
    } finally {
      _publish(_auth.currentUser);
    }
  });
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _request(() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthFailure('Please log in again.');
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'invalid-credential' ||
          error.code == 'wrong-password') {
        throw const AuthFailure('Your current password is incorrect.');
      }
      rethrow;
    }
    await user.updatePassword(newPassword);
  });

  static String _message(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-login-credentials' =>
      'Unable to log in. Check your email and password.',
    'email-already-in-use' =>
      'This email is already registered. Log in or reset your password.',
    'weak-password' || 'password-does-not-meet-requirements' =>
      'Use at least 8 characters and one uppercase letter (A–Z).',
    'invalid-email' => 'Enter a valid email address.',
    'network-request-failed' => 'Check your internet connection and try again.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'requires-recent-login' ||
    'user-token-expired' ||
    'invalid-user-token' => 'Please log out and log in again, then retry.',
    'user-disabled' => 'This account has been disabled.',
    'operation-not-allowed' =>
      'Email sign-in is not available. Please try again later.',
    _ => 'Unable to complete this request. Please try again.',
  };
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
