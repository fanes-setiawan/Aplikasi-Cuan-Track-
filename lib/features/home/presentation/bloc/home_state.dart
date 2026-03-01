import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<TransactionEntity> recentTransactions;
  final Map<String, double> expenseChartData;

  const HomeLoaded({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.recentTransactions,
    required this.expenseChartData,
  });

  @override
  List<Object?> get props => [
    totalBalance,
    monthlyIncome,
    monthlyExpenses,
    recentTransactions,
    expenseChartData,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
