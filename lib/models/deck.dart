class Deck {
  int? id;
  String name;

  Deck({
    this.id,
    required this.name,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  Deck copy({int? id, String? name}) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
