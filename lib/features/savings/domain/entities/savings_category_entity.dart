import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsCategoryEntity {
  final String id;
  final String userId;
  final String name;
  final String iconName;
  final String colorHex;

  SavingsCategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });

  factory SavingsCategoryEntity.fromMap(Map<String, dynamic> map, String id) {
    return SavingsCategoryEntity(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      iconName: map['iconName'] ?? 'savings',
      colorHex: map['colorHex'] ?? '0xFF27AE60',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
