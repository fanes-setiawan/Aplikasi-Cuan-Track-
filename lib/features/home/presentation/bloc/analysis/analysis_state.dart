import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction_entity.dart';

class SubCategoryAnalysis {
  final String name;
  final double totalAmount;
  final double percentage;

  SubCategoryAnalysis({
    required this.name,
    required this.totalAmount,
    required this.percentage,
  });
}

class CategoryAnalysis {
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final bool isTrendingUp;
  final bool isNeutral;
  final String trendText;
  final List<double> weeklyTotals;

  CategoryAnalysis({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.isTrendingUp,
    required this.isNeutral,
    required this.trendText,
    required this.weeklyTotals,
  });
}

abstract class AnalysisState extends Equatable {
  const AnalysisState();

  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {}

class AnalysisLoaded extends AnalysisState {
  final double currentMonthTotal;
  final double previousMonthTotal;
  final double comparisonPercentage;
  final double averagePerDay;
  final List<CategoryAnalysis> topCategories;
  final List<SubCategoryAnalysis> topSubCategories;
  final List<double> currentMonthWeeklyTotals;
  final List<double> previousMonthWeeklyTotals;
  final List<double> currentMonthWeekdayTotals;
  final List<double> previousMonthWeekdayTotals;
  final List<TransactionEntity> topTransactions;
  final String insightText;
  final String insightHighlightText;
  final DateTime currentMonth;

  const AnalysisLoaded({
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.comparisonPercentage,
    required this.averagePerDay,
    required this.topCategories,
    required this.topSubCategories,
    required this.currentMonthWeeklyTotals,
    required this.previousMonthWeeklyTotals,
    required this.currentMonthWeekdayTotals,
    required this.previousMonthWeekdayTotals,
    required this.topTransactions,
    required this.insightText,
    required this.insightHighlightText,
    required this.currentMonth,
  });

  @override
  List<Object?> get props => [
    currentMonthTotal,
    previousMonthTotal,
    comparisonPercentage,
    averagePerDay,
    topCategories,
    topSubCategories,
    currentMonthWeeklyTotals,
    previousMonthWeeklyTotals,
    currentMonthWeekdayTotals,
    previousMonthWeekdayTotals,
    topTransactions,
    insightText,
    insightHighlightText,
    currentMonth,
  ];
}

class AnalysisError extends AnalysisState {
  final String message;

  const AnalysisError(this.message);

  @override
  List<Object?> get props => [message];
}
