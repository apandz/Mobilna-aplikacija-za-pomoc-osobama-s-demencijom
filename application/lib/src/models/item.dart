import 'dart:convert';

class Item {
  final String id;
  final String name;
  final String? quantity;
  final String? size;
  final String? expirationDate;
  final String? notes;

  Item({
    required this.id,
    required this.name,
    this.quantity,
    this.size,
    this.expirationDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'quantity': quantity,
      'size': size,
      'expirationDate': expirationDate,
      'notes': notes,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['_id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] != null ? map['quantity'] as String : null,
      size: map['size'] != null ? map['size'] as String : null,
      expirationDate: map['expirationDate'] != null
          ? map['expirationDate'] as String
          : null,
      notes: map['notes'] != null ? map['notes'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) =>
      Item.fromMap(json.decode(source) as Map<String, dynamic>);
}
