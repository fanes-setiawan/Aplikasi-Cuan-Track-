import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchCategories(String userId);
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String userId, String categoryId);
  Future<void> seedDefaultCategoriesIfEmpty(String userId);
}
