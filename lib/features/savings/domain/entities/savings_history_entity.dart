import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsHistoryEntity {
  final String id;
  final String goalId;
  final String goalTitle;
  final double amount;
  final DateTime date;

  SavingsHistoryEntity({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.amount,
    required this.date,
  });

  factory SavingsHistoryEntity.fromMap(Map<String, dynamic> map, String id) {
    return SavingsHistoryEntity(
      id: id,
      goalId: map['goalId'] ?? '',
      goalTitle: map['goalTitle'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'goalTitle': goalTitle,
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}
