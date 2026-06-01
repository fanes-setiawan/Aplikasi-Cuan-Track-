import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getRecentTransactions(
    String userId, {
    int limit = 5,
  });

  Future<List<TransactionEntity>> getTransactionsForMonth(
    String userId,
    DateTime month,
  );

  Future<void> addTransaction(TransactionEntity transaction);

  Future<void> updateTransaction(TransactionEntity transaction);

  Future<void> deleteTransaction(String id);

  Future<double> getTotalBalance(String userId);

  Future<double> getCurrentMonthExpenses(String userId);

  Future<double> getCurrentMonthIncome(String userId);

  Future<Map<String, double>> getCurrentMonthExpenseChart(String userId);

  Future<List<TransactionEntity>> getAllTransactions(String userId);

  Stream<void> watchTransactions(String userId);
}
