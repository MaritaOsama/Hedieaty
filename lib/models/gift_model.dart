class Gift {
  int? id;
  String name;
  String? description;
  String? category;
  double? price;
  String? image;

  Gift({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.price,
    this.image,
  });

  factory Gift.fromMap(Map<String, dynamic> json) => Gift(
    id: json['ID'],
    name: json['NAME'],
    description: json['DESCRIPTION'],
    category: json['CATEGORY'],
    price: json['PRICE'],
    image: json['IMAGE'],
  );

  Map<String, dynamic> toMap() => {
    'ID': id,
    'NAME': name,
    'DESCRIPTION': description,
    'CATEGORY': category,
    'PRICE': price,
    'IMAGE': image,
  };
}
