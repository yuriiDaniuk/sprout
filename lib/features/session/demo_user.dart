class DemoUser {
  const DemoUser({required this.name, required this.email});

  static const example = DemoUser(
    name: 'Yurii Daniuk',
    email: 'danukura2007@gmail.com',
  );

  factory DemoUser.fromSignup({required String name, required String email}) =>
      DemoUser(
        name: name.trim().isEmpty ? example.name : name.trim(),
        email: email.trim().isEmpty ? example.email : email.trim(),
      );

  final String name;
  final String email;

  String get firstName => name.split(RegExp(r'\s+')).first;
}
