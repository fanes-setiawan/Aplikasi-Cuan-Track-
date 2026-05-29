import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../home/domain/repositories/transaction_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;
  final TransactionRepository transactionRepository;

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _transactionSubscription;

  BudgetBloc({
    required this.budgetRepository,
    required this.transactionRepository,
  }) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<BudgetsUpdated>(_onBudgetsUpdated);
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<DeleteBudget>(_onDeleteBudget);
  }

  void _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      _budgetSubscription?.cancel();
      _transactionSubscription?.cancel();

      _budgetSubscription = budgetRepository.watchBudgets(event.userId).listen((
        _,
      ) {
        add(BudgetsUpdated(event));
      });

      _transactionSubscription = transactionRepository
          .watchTransactions(event.userId)
          .listen((_) {
            add(TransactionsUpdated(event));
          });

      await _fetchAndCalculate(event.userId, emit);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onBudgetsUpdated(
    BudgetsUpdated event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _fetchAndCalculate(event.originalEvent.userId, emit);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await _fetchAndCalculate(event.originalEvent.userId, emit);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onDeleteBudget(DeleteBudget event, Emitter<BudgetState> emit) async {
    try {
      await budgetRepository.deleteBudget(event.userId, event.budgetId);
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _fetchAndCalculate(
    String userId,
    Emitter<BudgetState> emit,
  ) async {
    final budgets = await budgetRepository.getBudgets(userId);

    final now = DateTime.now();
    final transactions = await transactionRepository.getTransactionsForMonth(
      userId,
      now,
    );

    Map<String, double> spentAmounts = {};
    double totalBudget = 0;
    double totalSpent = 0;

    for (var b in budgets) {
      totalBudget += b.amount;
      spentAmounts[b.id] = 0.0;
    }

    for (var t in transactions) {
      if (t.type == 'expense') {
        for (var b in budgets) {
          if (b.categoryName == t.categoryName) {
            spentAmounts[b.id] = (spentAmounts[b.id] ?? 0.0) + t.amount;
            totalSpent += t.amount;
            break;
          }
        }
      }
    }

    emit(
      BudgetLoaded(
        budgets: budgets,
        spentAmounts: spentAmounts,
        totalBudget: totalBudget,
        totalSpent: totalSpent,
      ),
    );
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _transactionSubscription?.cancel();
    return super.close();
  }
}
