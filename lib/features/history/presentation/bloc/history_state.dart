import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/transaction_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;
  final DateTime currentMonth;

  const HistoryLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.currentMonth,
  });

  @override
  List<Object?> get props => [
    transactions,
    totalIncome,
    totalExpense,
    currentMonth,
  ];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class AllTimeHistoryLoaded extends HistoryState {
  final List<TransactionEntity> transactions;
  final double totalIncome;
  final double totalExpense;

  const AllTimeHistoryLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense];
}
