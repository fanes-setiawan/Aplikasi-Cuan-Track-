import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/repositories/transaction_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final TransactionRepository repository;
  StreamSubscription? _transactionSubscription;

  // A set of colors to use for the pie chart slices.
  final List<Color> _chartColors = const [
    Color(0xFF27AE60), // Green (Primary)
    Color(0xFF2D9CDB), // Blue
    Color(0xFFF2C94C), // Yellow
    Color(0xFFEB5757), // Red
    Color(0xFFBB6BD9), // Purple
    Color(0xFFF2994A), // Orange
    Color(0xFF56CCF2), // Light Blue
    Color(0xFFFF8A65), // Peach
  ];

  AnalyticsBloc({required this.repository}) : super(AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<AnalyticsTransactionsUpdated>(_onTransactionsUpdated);
  }

  void _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      _transactionSubscription?.cancel();
      _transactionSubscription = repository
          .watchTransactions(event.userId)
          .listen((_) {
            add(AnalyticsTransactionsUpdated(event));
          });

      await _fetchAndCalculate(event.userId, event.month, emit);
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  void _onTransactionsUpdated(
    AnalyticsTransactionsUpdated event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      await _fetchAndCalculate(
        event.originalEvent.userId,
        event.originalEvent.month,
        emit,
      );
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _fetchAndCalculate(
    String userId,
    DateTime month,
    Emitter<AnalyticsState> emit,
  ) async {
    final transactions = await repository.getTransactionsForMonth(
      userId,
      month,
    );

    double totalExpense = 0;
    Map<String, double> expenseByCategory = {};

    for (var t in transactions) {
      if (t.type == 'expense') {
        final category = t.categoryName?.isNotEmpty == true
            ? t.categoryName!
            : 'Lainnya';
        totalExpense += t.amount;
        expenseByCategory[category] =
            (expenseByCategory[category] ?? 0) + t.amount;
      }
    }

    final List<CategoryExpenseData> expensesList = [];
    int colorIndex = 0;

    // Sort categories by highest expense
    final sortedCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedCategories) {
      if (entry.value > 0) {
        expensesList.add(
          CategoryExpenseData(
            categoryName: entry.key,
            amount: entry.value,
            percentage: totalExpense > 0
                ? (entry.value / totalExpense) * 100
                : 0,
            color: _chartColors[colorIndex % _chartColors.length],
          ),
        );
        colorIndex++;
      }
    }

    emit(
      AnalyticsLoaded(
        expenses: expensesList,
        totalExpense: totalExpense,
        currentMonth: month,
      ),
    );
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
