import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/debt_entity.dart';

abstract class DebtRepository {
  Stream<List<DebtEntity>> watchDebts(String userId);
  Future<void> addDebt(String userId, DebtEntity debt);
  Future<void> updateDebt(String userId, DebtEntity debt);
  Future<void> deleteDebt(String userId, String debtId);
  Future<void> addPaymentToDebt(String userId, String debtId, double amount);
}

class FirestoreDebtRepositoryImpl implements DebtRepository {
  final FirebaseFirestore firestore;

  FirestoreDebtRepositoryImpl({required this.firestore});

  @override
  Stream<List<DebtEntity>> watchDebts(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('debts')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DebtEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> addDebt(String userId, DebtEntity debt) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('debts')
        .add(debt.toMap());
  }

  @override
  Future<void> updateDebt(String userId, DebtEntity debt) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('debts')
        .doc(debt.id)
        .update(debt.toMap());
  }

  @override
  Future<void> deleteDebt(String userId, String debtId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('debts')
        .doc(debtId)
        .delete();
  }

  @override
  Future<void> addPaymentToDebt(
    String userId,
    String debtId,
    double amount,
  ) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('debts')
        .doc(debtId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("Debt not found!");

      final paidAmount = (snapshot.data()?['paidAmount'] ?? 0).toDouble();
      final totalAmount = (snapshot.data()?['amount'] ?? 0).toDouble();
      final isInstallment = snapshot.data()?['isInstallment'] ?? false;
      final totalMonths = (snapshot.data()?['installmentMonths'] ?? 0).toInt();
      final paidMonthsList =
          snapshot.data()?['paidInstallmentMonths'] as List? ?? [];
      final paidMonths = paidMonthsList.length;

      final newPaidAmount = paidAmount + amount;
      final isPaid = newPaidAmount >= totalAmount;

      final updates = <String, dynamic>{
        'paidAmount': newPaidAmount,
        'isPaid': isPaid,
      };

      if (isInstallment) {
        final newPaidMonths = paidMonths + 1;
        updates['paidInstallmentMonths'] = List.generate(
          newPaidMonths,
          (i) => i,
        );
        if (newPaidMonths >= totalMonths) {
          updates['isPaid'] = true;
        }
      }

      transaction.update(docRef, updates);
    });
  }
}
