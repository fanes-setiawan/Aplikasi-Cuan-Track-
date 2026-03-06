import 'package:equatable/equatable.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {
  final String userId;

  const LoadBudgets(this.userId);

  @override
  List<Object> get props => [userId];
}

class BudgetsUpdated extends BudgetEvent {
  final LoadBudgets originalEvent;

  const BudgetsUpdated(this.originalEvent);

  @override
  List<Object> get props => [originalEvent];
}

class TransactionsUpdated extends BudgetEvent {
  final LoadBudgets originalEvent;

  const TransactionsUpdated(this.originalEvent);

  @override
  List<Object> get props => [originalEvent];
}

class DeleteBudget extends BudgetEvent {
  final String userId;
  final String budgetId;

  const DeleteBudget(this.userId, this.budgetId);

  @override
  List<Object> get props => [userId, budgetId];
}
