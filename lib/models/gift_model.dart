class Gift {
  int? id;
  String name;
  String? description;
  String? category;
  double? price;
  String? image;
  bool isPledged;

  Gift({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.price,
    this.image,
    required this.isPledged,
  });

  factory Gift.fromMap(Map<String, dynamic> json) => Gift(
    id: json['ID'],
    name: json['NAME'],
    description: json['DESCRIPTION'],
    category: json['CATEGORY'],
    price: json['PRICE'],
    image: json['IMAGE'],
    isPledged: json['ISPLEDGED']
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'NAME': name,
    'DESCRIPTION': description,
    'CATEGORY': category,
    'PRICE': price,
    'IMAGE': image,
    'ISPLEDGED': isPledged,
  };
}
