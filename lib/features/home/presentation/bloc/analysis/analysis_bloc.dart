import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/transaction_repository.dart';
import 'analysis_event.dart';
import 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final TransactionRepository transactionRepository;

  AnalysisBloc({required this.transactionRepository})
    : super(AnalysisInitial()) {
    on<FetchAnalysisData>(_onFetchAnalysisData);
  }

  Future<void> _onFetchAnalysisData(
    FetchAnalysisData event,
    Emitter<AnalysisState> emit,
  ) async {
    emit(AnalysisLoading());
    try {
      final currentMonthTransactions = await transactionRepository
          .getTransactionsForMonth(event.userId, event.selectedMonth);

      final previousMonth = DateTime(
        event.selectedMonth.year,
        event.selectedMonth.month - 1,
      );
      final previousMonthTransactions = await transactionRepository
          .getTransactionsForMonth(event.userId, previousMonth);

      double currentTotal = 0;
      final Map<String, double> categoryTotals = {};
      final Map<String, List<double>> categoryWeeklyTotals = {};
      final List<double> currentWeekly = [0.0, 0.0, 0.0, 0.0, 0.0];
      final List<double> currentWeekday = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

      for (var t in currentMonthTransactions) {
        if (t.type == 'expense') {
          currentTotal += t.amount;
          final catName = t.categoryName ?? 'Lainnya';
          categoryTotals[catName] = (categoryTotals[catName] ?? 0) + t.amount;

          final day = t.date.day;
          int weekIdx = (day - 1) ~/ 7;
          if (weekIdx > 4) weekIdx = 4;
          currentWeekly[weekIdx] += t.amount;

          final weekdayIdx = t.date.weekday - 1;
          currentWeekday[weekdayIdx] += t.amount;

          if (!categoryWeeklyTotals.containsKey(catName)) {
            categoryWeeklyTotals[catName] = [0.0, 0.0, 0.0, 0.0, 0.0];
          }
          categoryWeeklyTotals[catName]![weekIdx] += t.amount;
        }
      }

      double previousTotal = 0;
      final List<double> previousWeekly = [0.0, 0.0, 0.0, 0.0, 0.0];
      final List<double> previousWeekday = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

      for (var t in previousMonthTransactions) {
        if (t.type == 'expense') {
          previousTotal += t.amount;

          final day = t.date.day;
          int weekIdx = (day - 1) ~/ 7;
          if (weekIdx > 4) weekIdx = 4;
          previousWeekly[weekIdx] += t.amount;

          final weekdayIdx = t.date.weekday - 1;
          previousWeekday[weekdayIdx] += t.amount;
        }
      }

      double comparison = 0;
      if (previousTotal > 0) {
        comparison = ((currentTotal - previousTotal) / previousTotal) * 100;
      } else if (currentTotal > 0) {
        comparison = 100;
      }

      final now = DateTime.now();
      int daysElapsed;
      if (event.selectedMonth.year == now.year &&
          event.selectedMonth.month == now.month) {
        daysElapsed = now.day;
      } else {
        daysElapsed = DateTime(
          event.selectedMonth.year,
          event.selectedMonth.month + 1,
          0,
        ).day;
      }
      final avgPerDay = daysElapsed > 0 ? (currentTotal / daysElapsed) : 0;

      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final List<CategoryAnalysis> topCategories = [];
      for (var entry in sortedCategories.take(3)) {
        final percentage = currentTotal > 0
            ? ((entry.value / currentTotal) * 100).toDouble()
            : 0.0;

        topCategories.add(
          CategoryAnalysis(
            categoryName: entry.key,
            totalAmount: entry.value,
            percentage: percentage,
            isTrendingUp: false,
            isNeutral: true,
            trendText: '${percentage.toStringAsFixed(0)}% dari total anggaran',
            weeklyTotals:
                categoryWeeklyTotals[entry.key] ?? [0.0, 0.0, 0.0, 0.0, 0.0],
          ),
        );
      }

      final List<SubCategoryAnalysis> topSubCategories = [];
      if (sortedCategories.isNotEmpty) {
        final topCatName = sortedCategories.first.key;
        final topCatTotal = sortedCategories.first.value;

        final topCatTransactions = currentMonthTransactions.where(
          (t) =>
              t.type == 'expense' &&
              (t.categoryName ?? 'Lainnya') == topCatName,
        );

        final Map<String, double> subCategoryTotals = {};
        for (var t in topCatTransactions) {
          final title = t.title.isEmpty ? 'Lain-lain' : t.title;
          subCategoryTotals[title] = (subCategoryTotals[title] ?? 0) + t.amount;
        }

        final sortedSubCategories = subCategoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (var entry in sortedSubCategories.take(5)) {
          final percentage = topCatTotal > 0
              ? (entry.value / topCatTotal)
              : 0.0;
          topSubCategories.add(
            SubCategoryAnalysis(
              name: entry.key,
              totalAmount: entry.value,
              percentage: percentage,
            ),
          );
        }
      }

      final allExpenses = currentMonthTransactions
          .where((t) => t.type == 'expense')
          .toList();
      allExpenses.sort((a, b) => b.amount.compareTo(a.amount));
      final topTransactionsList = allExpenses.take(3).toList();

      int highestWeekIdx = 0;
      double highestWeekVal = currentWeekly[0];
      int lowestWeekIdx = 0;
      double lowestWeekVal = currentWeekly[0];

      for (int i = 1; i < currentWeekly.length; i++) {
        if (currentWeekly[i] > highestWeekVal) {
          highestWeekVal = currentWeekly[i];
          highestWeekIdx = i;
        }
        if (currentWeekly[i] < lowestWeekVal && currentWeekly[i] > 0) {
          lowestWeekVal = currentWeekly[i];
          lowestWeekIdx = i;
        }
      }

      String insightHighlight = '';
      String insight = '';
      if (currentTotal == 0) {
        insightHighlight = 'Ayo catat!';
        insight = 'Belum ada pengeluaran di bulan ini.';
      } else if (comparison > 0) {
        final weekStrings = ['pertama', 'kedua', 'ketiga', 'keempat', 'kelima'];

        insightHighlight = 'Lebih boros ${comparison.toStringAsFixed(1)}%';
        insight =
            'Pengeluaran Anda naik dibanding bulan lalu. Kenaikan terbesar terjadi pada kategori ${topCategories.isNotEmpty ? topCategories.first.categoryName : 'Lainnya'} di minggu ${weekStrings[highestWeekIdx]}.';
      } else if (comparison < 0) {
        insightHighlight =
            'Lebih hemat ${comparison.abs().toStringAsFixed(1)}%';
        insight = 'Bagus! Anda berhasil lebih hemat dari bulan lalu.';
      } else {
        insightHighlight = 'Sama';
        insight = 'Pengeluaran Anda stabil dibanding bulan lalu.';
      }

      emit(
        AnalysisLoaded(
          currentMonthTotal: currentTotal,
          previousMonthTotal: previousTotal,
          comparisonPercentage: comparison,
          averagePerDay: avgPerDay.toDouble(),
          topCategories: topCategories,
          topSubCategories: topSubCategories,
          currentMonthWeeklyTotals: currentWeekly,
          previousMonthWeeklyTotals: previousWeekly,
          currentMonthWeekdayTotals: currentWeekday,
          previousMonthWeekdayTotals: previousWeekday,
          topTransactions: topTransactionsList,
          insightText: insight,
          insightHighlightText: insightHighlight,
          currentMonth: event.selectedMonth,
          highestSpendingWeekIndex: highestWeekIdx,
          highestSpendingWeekAmount: highestWeekVal,
          lowestSpendingWeekIndex: lowestWeekIdx,
          lowestSpendingWeekAmount: lowestWeekVal,
        ),
      );
    } catch (e) {
      emit(AnalysisError(e.toString()));
    }
  }
}
