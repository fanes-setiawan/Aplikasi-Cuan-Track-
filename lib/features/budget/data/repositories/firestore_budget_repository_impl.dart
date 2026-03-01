import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';

class FirestoreBudgetRepositoryImpl implements BudgetRepository {
  final FirebaseFirestore _firestore;

  FirestoreBudgetRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addBudget(BudgetEntity budget) async {
    final userBudgetsRef = _firestore
        .collection('users')
        .doc(budget.userId)
        .collection('budgets');

    await userBudgetsRef.add(budget.toMap());
  }

  @override
  Future<List<BudgetEntity>> getBudgets(String userId) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs
        .map((doc) => BudgetEntity.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Stream<List<BudgetEntity>> watchBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BudgetEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
