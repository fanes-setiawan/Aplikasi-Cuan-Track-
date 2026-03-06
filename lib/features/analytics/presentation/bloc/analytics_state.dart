import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class CategoryExpenseData extends Equatable {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;

  const CategoryExpenseData({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object> get props => [categoryName, amount, percentage, color];
}

class AnalyticsLoaded extends AnalyticsState {
  final List<CategoryExpenseData> expenses;
  final double totalExpense;
  final DateTime currentMonth;

  const AnalyticsLoaded({
    required this.expenses,
    required this.totalExpense,
    required this.currentMonth,
  });

  @override
  List<Object> get props => [expenses, totalExpense, currentMonth];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
