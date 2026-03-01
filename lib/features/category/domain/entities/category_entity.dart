import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' or 'expense'
  final String iconName;
  final String colorHex;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [id, userId, name, type, iconName, colorHex];

  factory CategoryEntity.fromMap(Map<String, dynamic> map, String id) {
    return CategoryEntity(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'expense',
      iconName: map['iconName'] ?? 'category',
      colorHex: map['colorHex'] ?? '0xFF9E9E9E',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'iconName': iconName,
      'colorHex': colorHex,
    };
  }
}
