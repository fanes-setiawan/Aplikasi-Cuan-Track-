import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final String? categoryName;
  final String? paymentMethodId;
  final DateTime date;
  final String? notes;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.categoryName,
    this.paymentMethodId,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    amount,
    type,
    categoryId,
    categoryName,
    paymentMethodId,
    date,
    notes,
  ];

  factory TransactionEntity.fromMap(Map<String, dynamic> map, String id) {
    return TransactionEntity(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'expense',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'],
      paymentMethodId: map['paymentMethodId'],
      date: map['date'] != null
          ? (map['date'] as dynamic).toDate()
          : DateTime.now(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'paymentMethodId': paymentMethodId,
      'date': date,
      'notes': notes,
    };
  }
}
