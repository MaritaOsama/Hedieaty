class Gift {
  String id;
  String name;
  String category;
  bool isPledged;

  Gift({required this.id, required this.name, required this.category, this.isPledged = false});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'isPledged': isPledged,
    };
  }

  factory Gift.fromMap(String id, Map<String, dynamic> map) {
    return Gift(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      isPledged: map['isPledged'] ?? false,
    );
  }
}
