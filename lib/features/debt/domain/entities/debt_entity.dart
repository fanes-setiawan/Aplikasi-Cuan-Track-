import 'package:cloud_firestore/cloud_firestore.dart';

class DebtEntity {
  final String id;
  final String personName;
  final String type;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime? startDate;
  final bool isPaid;
  final String description;
  final String title;
  final bool isInstallment;
  final int totalMonths;
  final List<int> paidInstallmentMonths;
  final double monthlyPayment;

  int get paidMonths => paidInstallmentMonths.length;
  DateTime get effectiveStartDate => startDate ?? dueDate;

  DebtEntity({
    required this.id,
    required this.personName,
    required this.type,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    this.startDate,
    this.isPaid = false,
    this.description = '',
    this.title = '',
    this.isInstallment = false,
    this.totalMonths = 0,
    this.paidInstallmentMonths = const [],
    this.monthlyPayment = 0.0,
  });

  factory DebtEntity.fromMap(Map<String, dynamic> map, String id) {
    final paidMonthsList = map['paidInstallmentMonths'] as List? ?? [];
    final List<int> paidList = paidMonthsList.map((e) => (e as num).toInt()).toList();
    return DebtEntity(
      id: id,
      personName: map['personName'] ?? '',
      type: map['type'] ?? 'hutang',
      amount: (map['amount'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : null,
      isPaid: map['isPaid'] ?? false,
      description: map['description'] ?? '',
      title: map['title'] ?? '',
      isInstallment: map['isInstallment'] ?? false,
      totalMonths: map['installmentMonths'] != null
          ? (map['installmentMonths'] is String
                ? int.tryParse(map['installmentMonths']) ?? 0
                : (map['installmentMonths'] as num).toInt())
          : 0,
      paidInstallmentMonths: paidList,
      monthlyPayment: (map['monthlyAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personName': personName,
      'type': type,
      'amount': amount,
      'paidAmount': paidAmount,
      'dueDate': Timestamp.fromDate(dueDate),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'isPaid': isPaid,
      'description': description,
      'title': title,
      'isInstallment': isInstallment,
      'installmentMonths': totalMonths,
      'monthlyAmount': monthlyPayment,
      'paidInstallmentMonths': paidInstallmentMonths,
    };
  }

  DebtEntity copyWith({
    String? id,
    String? personName,
    String? type,
    double? amount,
    double? paidAmount,
    DateTime? dueDate,
    DateTime? startDate,
    bool? isPaid,
    String? description,
    String? title,
    bool? isInstallment,
    int? totalMonths,
    List<int>? paidInstallmentMonths,
    double? monthlyPayment,
  }) {
    return DebtEntity(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      isPaid: isPaid ?? this.isPaid,
      description: description ?? this.description,
      title: title ?? this.title,
      isInstallment: isInstallment ?? this.isInstallment,
      totalMonths: totalMonths ?? this.totalMonths,
      paidInstallmentMonths: paidInstallmentMonths ?? this.paidInstallmentMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
    );
  }
}
