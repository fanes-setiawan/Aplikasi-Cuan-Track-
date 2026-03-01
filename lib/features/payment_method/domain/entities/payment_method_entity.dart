import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String type; // 'Bank', 'E-Wallet', 'Tunai'
  final String accountNumber;
  final double balance;
  final String
  iconPath; // This could represent a basic shape/icon name or string

  const PaymentMethodEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.balance,
    required this.iconPath,
  });

  factory PaymentMethodEntity.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentMethodEntity(
      id: docId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'Tunai',
      accountNumber: map['accountNumber'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      iconPath: map['iconPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'accountNumber': accountNumber,
      'balance': balance,
      'iconPath': iconPath,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    type,
    accountNumber,
    balance,
    iconPath,
  ];
}
