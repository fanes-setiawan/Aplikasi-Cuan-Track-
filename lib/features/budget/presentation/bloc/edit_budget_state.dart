import 'package:equatable/equatable.dart';

abstract class EditBudgetState extends Equatable {
  const EditBudgetState();

  @override
  List<Object> get props => [];
}

class EditBudgetInitial extends EditBudgetState {}

class EditBudgetLoading extends EditBudgetState {}

class EditBudgetSuccess extends EditBudgetState {}

class EditBudgetError extends EditBudgetState {
  final String message;

  const EditBudgetError(this.message);

  @override
  List<Object> get props => [message];
}
