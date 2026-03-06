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

      // Listen to budgets
      _budgetSubscription = budgetRepository.watchBudgets(event.userId).listen((
        _,
      ) {
        add(BudgetsUpdated(event));
      });

      // Listen to transactions
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
      // We don't need to explicitly update the state here because the
      // Firestore snapshot listener (watchBudgets) will automatically
      // trigger a BudgetsUpdated event when it detects the deletion.
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _fetchAndCalculate(
    String userId,
    Emitter<BudgetState> emit,
  ) async {
    final budgets = await budgetRepository.getBudgets(userId);

    // Simplification: We fetch transactions for the current month.
    // In a fully dynamic app with different dates, we'd query all transactions matching periods.
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

    // Accumulate expenses to budget IDs based on category matching
    for (var t in transactions) {
      if (t.type == 'expense') {
        // Find if this transaction's category matches any budget category
        for (var b in budgets) {
          if (b.categoryName == t.categoryName) {
            spentAmounts[b.id] = (spentAmounts[b.id] ?? 0.0) + t.amount;
            totalSpent += t.amount;
            break; // Assuming a transaction only maps to one budget category
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
