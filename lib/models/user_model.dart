class User {
  final int id;
  final String nome;

  User({required this.id, required this.nome});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], nome: json['nome']);
  }
}
