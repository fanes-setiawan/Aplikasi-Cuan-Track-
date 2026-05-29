import 'package:equatable/equatable.dart';
import '../../domain/entities/debt_entity.dart';

abstract class DebtEvent extends Equatable {
  const DebtEvent();

  @override
  List<Object> get props => [];
}

class LoadDebts extends DebtEvent {
  final String userId;

  const LoadDebts(this.userId);

  @override
  List<Object> get props => [userId];
}

class DebtsUpdated extends DebtEvent {
  final List<DebtEntity> debts;

  const DebtsUpdated(this.debts);

  @override
  List<Object> get props => [debts];
}

class AddDebt extends DebtEvent {
  final String userId;
  final DebtEntity debt;

  const AddDebt(this.userId, this.debt);

  @override
  List<Object> get props => [userId, debt];
}

class UpdateDebt extends DebtEvent {
  final String userId;
  final DebtEntity debt;

  const UpdateDebt(this.userId, this.debt);

  @override
  List<Object> get props => [userId, debt];
}

class DeleteDebt extends DebtEvent {
  final String userId;
  final String debtId;

  const DeleteDebt(this.userId, this.debtId);

  @override
  List<Object> get props => [userId, debtId];
}

class AddPaymentToDebt extends DebtEvent {
  final String userId;
  final String debtId;
  final double amount;

  const AddPaymentToDebt({
    required this.userId,
    required this.debtId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, debtId, amount];
}

class ToggleInstallmentMonth extends DebtEvent {
  final String userId;
  final String debtId;
  final int monthIndex;
  final bool isPaid;
  final double monthlyAmount;

  const ToggleInstallmentMonth({
    required this.userId,
    required this.debtId,
    required this.monthIndex,
    required this.isPaid,
    required this.monthlyAmount,
  });

  @override
  List<Object> get props => [userId, debtId, monthIndex, isPaid, monthlyAmount];
}
