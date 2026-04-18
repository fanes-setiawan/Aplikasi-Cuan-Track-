import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalEntity {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final bool isAchieved;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIconName;
  final String? categoryColorHex;

  SavingsGoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.isAchieved = false,
    this.categoryId,
    this.categoryName,
    this.categoryIconName,
    this.categoryColorHex,
  });

  factory SavingsGoalEntity.fromMap(Map<String, dynamic> map, String id) {
    return SavingsGoalEntity(
      id: id,
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      isAchieved: map['isAchieved'] ?? false,
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      categoryIconName: map['categoryIconName'],
      categoryColorHex: map['categoryColorHex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'isAchieved': isAchieved,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconName': categoryIconName,
      'categoryColorHex': categoryColorHex,
    };
  }
}
