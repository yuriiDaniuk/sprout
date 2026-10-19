import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprout/features/auth/data/auth_repository.dart';

class SignupUser extends Fake implements User {
  bool failName = true;
  String? name;
  @override
  String get uid => 'partial-user';
  @override
  String? get email => 'first@example.com';
  @override
  String? get displayName => name;
  @override
  String? get photoURL => null;
  @override
  Future<void> updateDisplayName(String? value) async {
    if (failName) throw FirebaseAuthException(code: 'network-request-failed');
    name = value;
  }
}

class SignupCredential extends Fake implements UserCredential {
  SignupCredential(this.user);
  @override
  final User user;
}

class SignupAuth extends Fake implements FirebaseAuth {
  final signupUser = SignupUser();
  String? creationError;
  int creationCalls = 0;
  @override
  User? currentUser;
  @override
  Stream<User?> userChanges() => const Stream.empty();
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    creationCalls++;
    if (creationError != null) {
      throw FirebaseAuthException(code: creationError!);
    }
    currentUser = signupUser;
    return SignupCredential(signupUser);
  }
}

const partialMessage =
    'Your account was created, but your name could not be saved. Tap Sign Up again to finish.';

Future<void> createPartial(FirebaseAuthRepository repository) => expectLater(
  repository.signUp(
    name: 'First',
    email: 'first@example.com',
    password: 'Password1',
  ),
  throwsA(
    isA<AuthFailure>().having((e) => e.message, 'message', partialMessage),
  ),
);

void main() {
  for (final entry in {
    'email-already-in-use':
        'This email is already registered. Log in or reset your password.',
    'network-request-failed': 'Check your internet connection and try again.',
  }.entries) {
    test('Partial signup preserves the next ${entry.key} creation error', () async {
      final auth = SignupAuth();
      final repository = FirebaseAuthRepository(auth: auth);
      addTearDown(repository.dispose);
      await createPartial(repository);
      auth.creationError = entry.key;
      await expectLater(
        repository.signUp(
          name: 'Second',
          email: 'second@example.com',
          password: 'Password1',
        ),
        throwsA(
          isA<AuthFailure>().having((e) => e.message, 'message', entry.value),
        ),
      );
      expect(auth.creationCalls, 2);
      expect(repository.currentUser, isNull);
      // The first account can still be completed after a failed second address.
      auth.signupUser.failName = false;
      await repository.signUp(
        name: 'Finished',
        email: 'first@example.com',
        password: 'Password1',
      );
      expect(auth.creationCalls, 2);
      expect(repository.currentUser!.name, 'Finished');
    });
  }

  test(
    'Partial signup retries the name without creating another account',
    () async {
      final auth = SignupAuth();
      final repository = FirebaseAuthRepository(auth: auth);
      addTearDown(repository.dispose);
      await createPartial(repository);
      await createPartial(repository);
      expect(auth.creationCalls, 1);
      auth.signupUser.failName = false;
      await repository.signUp(
        name: 'Finished',
        email: 'first@example.com',
        password: 'Password1',
      );
      expect(auth.creationCalls, 1);
      expect(repository.currentUser!.uid, 'partial-user');
      expect(repository.currentUser!.name, 'Finished');
    },
  );
}
