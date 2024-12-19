class User {
  int? id;
  String firstName;
  String lastName;
  String? number;
  String email;
  String password;
  String image;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    this.number,
    required this.email,
    required this.password,
    required this.image,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['ID'],
    firstName: json['FIRST_NAME'],
    lastName: json['LAST_NAME'],
    number: json['NUMBER'],
    email: json['EMAIL'],
    password: json['PASSWORD'],
    image: json['IMAGE'],
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'FIRST_NAME': firstName,
    'LAST_NAME': lastName,
    'NUMBER': number,
    'EMAIL': email,
    'PASSWORD': password,
    'IMAGE': image,
  };
}
