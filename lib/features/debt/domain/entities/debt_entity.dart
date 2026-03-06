import 'package:cloud_firestore/cloud_firestore.dart';

class DebtEntity {
  final String id;
  final String personName;
  final String type;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final bool isPaid;
  final String description;

  DebtEntity({
    required this.id,
    required this.personName,
    required this.type,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    this.isPaid = false,
    this.description = '',
  });

  factory DebtEntity.fromMap(Map<String, dynamic> map, String id) {
    return DebtEntity(
      id: id,
      personName: map['personName'] ?? '',
      type: map['type'] ?? 'hutang',
      amount: (map['amount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      isPaid: map['isPaid'] ?? false,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'type': type,
      'amount': amount,
      'paidAmount': paidAmount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'description': description,
    };
  }
}
