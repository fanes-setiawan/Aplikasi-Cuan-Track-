import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/repositories/transaction_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final TransactionRepository repository;
  StreamSubscription? _transactionSubscription;

  HistoryBloc({required this.repository}) : super(HistoryInitial()) {
    on<ChangeMonthEvent>(_onChangeMonth);
    on<TransactionsUpdated>(_onTransactionsUpdated);
  }

  void _onChangeMonth(
    ChangeMonthEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      _transactionSubscription?.cancel();
      _transactionSubscription = repository
          .watchTransactions(event.userId)
          .listen((_) {
            add(TransactionsUpdated(event));
          });

      await _fetchMonthlyData(event.userId, event.month, emit);
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _fetchMonthlyData(
        event.originalEvent.userId,
        event.originalEvent.month,
        emit,
      );
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _fetchMonthlyData(
    String userId,
    DateTime month,
    Emitter<HistoryState> emit,
  ) async {
    final transactions = await repository.getTransactionsForMonth(
      userId,
      month,
    );

    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    emit(
      HistoryLoaded(
        transactions: transactions,
        totalIncome: income,
        totalExpense: expense,
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
