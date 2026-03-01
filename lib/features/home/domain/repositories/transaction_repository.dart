import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Fetches the recent transactions for a specific user.
  Future<List<TransactionEntity>> getRecentTransactions(
    String userId, {
    int limit = 5,
  });

  /// Fetches all transactions for a specific user within a given month.
  Future<List<TransactionEntity>> getTransactionsForMonth(
    String userId,
    DateTime month,
  );

  /// Adds a new transaction.
  Future<void> addTransaction(TransactionEntity transaction);

  /// Calculates the total balance (income - expense) for a specific user.
  Future<double> getTotalBalance(String userId);

  /// Calculates the total expenses for the current month for a specific user.
  Future<double> getCurrentMonthExpenses(String userId);

  /// Calculates the total income for the current month for a specific user.
  Future<double> getCurrentMonthIncome(String userId);

  /// Calculates the expense breakdown per category for the current month.
  Future<Map<String, double>> getCurrentMonthExpenseChart(String userId);

  /// Watches for any changes in the user's transactions.
  Stream<void> watchTransactions(String userId);
}
