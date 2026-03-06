import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<void> addBudget(BudgetEntity budget);
  Future<void> updateBudget(BudgetEntity budget);
  Future<List<BudgetEntity>> getBudgets(String userId);
  Stream<List<BudgetEntity>> watchBudgets(String userId);
  Future<void> deleteBudget(String userId, String budgetId);
}
