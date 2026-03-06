import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/entities/savings_history_entity.dart';

abstract class SavingsRepository {
  Stream<List<SavingsGoalEntity>> watchSavingsGoals(String userId);
  Stream<List<SavingsHistoryEntity>> watchSavingsHistory(String userId);
  Future<void> addSavingsGoal(String userId, SavingsGoalEntity goal);
  Future<void> updateSavingsGoal(String userId, SavingsGoalEntity goal);
  Future<void> deleteSavingsGoal(String userId, String goalId);
  Future<void> addFundsToGoal(String userId, String goalId, double amount);
}

class FirestoreSavingsRepositoryImpl implements SavingsRepository {
  final FirebaseFirestore firestore;

  FirestoreSavingsRepositoryImpl({required this.firestore});

  @override
  Stream<List<SavingsGoalEntity>> watchSavingsGoals(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SavingsGoalEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Stream<List<SavingsHistoryEntity>> watchSavingsHistory(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('savings_history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SavingsHistoryEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> addSavingsGoal(String userId, SavingsGoalEntity goal) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .add(goal.toMap());
  }

  @override
  Future<void> updateSavingsGoal(String userId, SavingsGoalEntity goal) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goal.id)
        .update(goal.toMap());
  }

  @override
  Future<void> deleteSavingsGoal(String userId, String goalId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goalId)
        .delete();
  }

  @override
  Future<void> addFundsToGoal(
    String userId,
    String goalId,
    double amount,
  ) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .doc(goalId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Goal not found!");

      final currentAmount = (snapshot.data()?['currentAmount'] ?? 0).toDouble();
      final targetAmount = (snapshot.data()?['targetAmount'] ?? 0).toDouble();
      final newAmount = currentAmount + amount;

      final isAchieved = newAmount >= targetAmount;
      final goalTitle = snapshot.data()?['title'] ?? 'Tabungan';

      transaction.update(docRef, {
        'currentAmount': newAmount,
        'isAchieved': isAchieved,
      });

      final historyRef = firestore
          .collection('users')
          .doc(userId)
          .collection('savings_history')
          .doc();

      transaction.set(historyRef, {
        'goalId': goalId,
        'goalTitle': goalTitle,
        'amount': amount,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }
}
