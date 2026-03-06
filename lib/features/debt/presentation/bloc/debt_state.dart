import 'package:equatable/equatable.dart';
import '../../domain/entities/debt_entity.dart';

abstract class DebtState extends Equatable {
  const DebtState();

  @override
  List<Object> get props => [];
}

class DebtInitial extends DebtState {}

class DebtLoading extends DebtState {}

class DebtLoaded extends DebtState {
  final List<DebtEntity> debts;

  const DebtLoaded(this.debts);

  @override
  List<Object> get props => [debts];
}

class DebtError extends DebtState {
  final String message;

  const DebtError(this.message);

  @override
  List<Object> get props => [message];
}

class AddDebtPaymentSuccess extends DebtState {
  final DebtEntity debt;
  final bool isPaidOff;

  const AddDebtPaymentSuccess(this.debt, {this.isPaidOff = false});

  @override
  List<Object> get props => [debt, isPaidOff];
}
