import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  final Map<String, double> spentAmounts;
  final double totalBudget;
  final double totalSpent;

  const BudgetLoaded({
    required this.budgets,
    required this.spentAmounts,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  List<Object> get props => [budgets, spentAmounts, totalBudget, totalSpent];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object> get props => [message];
}
