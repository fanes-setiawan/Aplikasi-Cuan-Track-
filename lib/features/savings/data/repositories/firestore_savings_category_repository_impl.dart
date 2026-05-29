import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/savings_category_entity.dart';
import '../../domain/repositories/savings_category_repository.dart';

class FirestoreSavingsCategoryRepositoryImpl
    implements SavingsCategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<SavingsCategoryEntity>> getSavingsCategories(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savings_categories')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SavingsCategoryEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> addSavingsCategory(SavingsCategoryEntity category) async {
    await _firestore
        .collection('users')
        .doc(category.userId)
        .collection('savings_categories')
        .add(category.toMap());
  }

  @override
  Future<void> updateSavingsCategory(SavingsCategoryEntity category) async {
    await _firestore
        .collection('users')
        .doc(category.userId)
        .collection('savings_categories')
        .doc(category.id)
        .update(category.toMap());
  }

  @override
  Future<void> deleteSavingsCategory(String userId, String categoryId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('savings_categories')
        .doc(categoryId)
        .delete();
  }
}
