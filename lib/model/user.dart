class User {
  final dynamic id;
  final String name;
  final String email;
  String? token;

  User({this.token, required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id':id,
      'name':name,
      'email':email,
      'token':token,
    };
  }
}
