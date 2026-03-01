import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryName;
  final double amount;
  final String period; // 'Mingguan', 'Bulanan', 'Tahunan'
  final bool remindMe;
  final DateTime createdAt;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.categoryName,
    required this.amount,
    required this.period,
    required this.remindMe,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    categoryName,
    amount,
    period,
    remindMe,
    createdAt,
  ];

  factory BudgetEntity.fromMap(Map<String, dynamic> map, String id) {
    return BudgetEntity(
      id: id,
      userId: map['userId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      period: map['period'] ?? 'Bulanan',
      remindMe: map['remindMe'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryName': categoryName,
      'amount': amount,
      'period': period,
      'remindMe': remindMe,
      'createdAt': createdAt,
    };
  }
}
