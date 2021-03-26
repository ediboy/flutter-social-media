class AuthorModel {
  final String id;
  final String name;
  final String image;

  AuthorModel({this.id, this.name, this.image});

  factory AuthorModel.fromMap(Map data) {
    return AuthorModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
