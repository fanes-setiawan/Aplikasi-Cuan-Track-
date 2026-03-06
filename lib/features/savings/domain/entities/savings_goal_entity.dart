import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoalEntity {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final bool isAchieved;

  SavingsGoalEntity({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.isAchieved = false,
  });

  factory SavingsGoalEntity.fromMap(Map<String, dynamic> map, String id) {
    return SavingsGoalEntity(
      id: id,
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      deadline: (map['deadline'] as Timestamp).toDate(),
      isAchieved: map['isAchieved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': Timestamp.fromDate(deadline),
      'isAchieved': isAchieved,
    };
  }
}
