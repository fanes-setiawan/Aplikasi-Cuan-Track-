import '../entities/savings_category_entity.dart';

abstract class SavingsCategoryRepository {
  Stream<List<SavingsCategoryEntity>> getSavingsCategories(String userId);
  Future<void> addSavingsCategory(SavingsCategoryEntity category);
  Future<void> updateSavingsCategory(SavingsCategoryEntity category);
  Future<void> deleteSavingsCategory(String userId, String categoryId);
}
