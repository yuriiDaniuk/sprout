class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  String get firstName =>
      name.trim().isEmpty ? 'there' : name.trim().split(RegExp(r'\s+')).first;
}
