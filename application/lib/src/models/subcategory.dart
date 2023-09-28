import 'dart:convert';

import '../utils/global_variables.dart';

class Subcategory {
  final String id;
  final String name;
  final String color;
  final DefaultSubcategory defaultSubcategory;

  Subcategory({
    required this.id,
    required this.name,
    required this.color,
    required this.defaultSubcategory,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'color': color,
      'defaultSubcategory': defaultSubcategory.index,
    };
  }

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      id: map['_id'] as String,
      name: map['name'] as String,
      color: map['color'] as String,
      defaultSubcategory:
          DefaultSubcategory.values.elementAt(map['defaultSubcategory']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Subcategory.fromJson(String source) =>
      Subcategory.fromMap(json.decode(source) as Map<String, dynamic>);
}
