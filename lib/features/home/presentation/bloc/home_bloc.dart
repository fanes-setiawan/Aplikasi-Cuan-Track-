import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TransactionRepository repository;
  StreamSubscription<void>? _transactionSubscription;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<StartListeningTransactions>(_onStartListening);
  }

  void _onStartListening(
    StartListeningTransactions event,
    Emitter<HomeState> emit,
  ) {
    _transactionSubscription?.cancel();
    _transactionSubscription = repository
        .watchTransactions(event.userId)
        .listen((_) {
          add(LoadHomeData(event.userId));
        });
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Fetch data concurrently for better performance
      final results = await Future.wait([
        repository.getTotalBalance(event.userId),
        repository.getCurrentMonthIncome(event.userId),
        repository.getCurrentMonthExpenses(event.userId),
        repository.getRecentTransactions(event.userId),
        repository.getCurrentMonthExpenseChart(event.userId),
      ]);

      final totalBalance = results[0] as double;
      final monthlyIncome = results[1] as double;
      final monthlyExpenses = results[2] as double;
      final recentTransactions = results[3] as List;
      final expenseChartData = results[4] as Map<String, double>;

      emit(
        HomeLoaded(
          totalBalance: totalBalance,
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          // ignore: cast_from_type
          recentTransactions: List.from(recentTransactions),
          expenseChartData: expenseChartData,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
