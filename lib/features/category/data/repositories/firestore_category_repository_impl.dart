import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';

class FirestoreCategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore firestore;

  FirestoreCategoryRepositoryImpl({required this.firestore});

  @override
  Stream<List<CategoryEntity>> watchCategories(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CategoryEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    final docRef = firestore
        .collection('users')
        .doc(category.userId)
        .collection('categories')
        .doc();
    await docRef.set(category.toMap());
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await firestore
        .collection('users')
        .doc(category.userId)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  @override
  Future<void> seedDefaultCategoriesIfEmpty(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      final defaultCategories = [
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Gaji',
          type: 'income',
          iconName: 'income_salary',
          colorHex: '0xFF27AE60',
        ),
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Bonus',
          type: 'income',
          iconName: 'income_bonus',
          colorHex: '0xFF2ECC71',
        ),
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Investasi',
          type: 'income',
          iconName: 'income_invest',
          colorHex: '0xFFF39C12',
        ),
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Makanan & Minuman',
          type: 'expense',
          iconName: 'expense_food',
          colorHex: '0xFFE74C3C',
        ),
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Transportasi',
          type: 'expense',
          iconName: 'expense_transport',
          colorHex: '0xFF3498DB',
        ),
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Belanja',
          type: 'expense',
          iconName: 'expense_shopping',
          colorHex: '0xFF9B59B6',
        ),
        CategoryEntity(
          id: '',
          userId: userId,
          name: 'Hiburan',
          type: 'expense',
          iconName: 'expense_entertainment',
          colorHex: '0xFFF1C40F',
        ),
      ];

      final batch = firestore.batch();
      for (var cat in defaultCategories) {
        final docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc();
        batch.set(docRef, cat.toMap());
      }
      await batch.commit();
    }
  }
}
