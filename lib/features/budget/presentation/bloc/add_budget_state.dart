import 'package:equatable/equatable.dart';

abstract class AddBudgetState extends Equatable {
  const AddBudgetState();

  @override
  List<Object> get props => [];
}

class AddBudgetInitial extends AddBudgetState {}

class AddBudgetLoading extends AddBudgetState {}

class AddBudgetSuccess extends AddBudgetState {}

class AddBudgetError extends AddBudgetState {
  final String message;

  const AddBudgetError(this.message);

  @override
  List<Object> get props => [message];
}
