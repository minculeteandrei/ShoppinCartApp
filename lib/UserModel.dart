class UserModel{
  String name;
  String surname;
  final uid;
  String email;

  UserModel({
    required this.uid,
    required this.email,
    required this.surname,
    required this.name,
  });

}