import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/debt_entity.dart';

abstract class DebtRepository {
  Stream<List<DebtEntity>> watchDebts(String userId);
  Future<void> addDebt(String userId, DebtEntity debt);
  Future<void> updateDebt(String userId, DebtEntity debt);
  Future<void> deleteDebt(String userId, String debtId);
  Future<void> addPaymentToDebt(String userId, String debtId, double amount);
  Future<void> toggleInstallmentMonth(String userId, String debtId, int monthIndex, bool isPaid, double monthlyAmount);
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
      final paidMonthsList = (snapshot.data()?['paidInstallmentMonths'] as List? ?? [])
          .map((e) => (e as num).toInt())
          .toList();

      final newPaidAmount = paidAmount + amount;
      final isPaid = newPaidAmount >= totalAmount;

      final updates = <String, dynamic>{
        'paidAmount': newPaidAmount,
        'isPaid': isPaid,
      };

      if (isInstallment) {
        final startDateVal = snapshot.data()?['startDate'] != null
            ? (snapshot.data()?['startDate'] as Timestamp).toDate()
            : (snapshot.data()?['dueDate'] as Timestamp).toDate();
        final startMonth = startDateVal.month; // 1-based
        int nextUnpaidMonthIndex = (startMonth - 1) % 12;

        for (int i = 0; i < totalMonths; i++) {
          final targetIndex = (startMonth - 1 + i) % 12;
          if (!paidMonthsList.contains(targetIndex)) {
            nextUnpaidMonthIndex = targetIndex;
            break;
          }
        }

        final newPaidMonthsList = List<int>.from(paidMonthsList)..add(nextUnpaidMonthIndex);
        updates['paidInstallmentMonths'] = newPaidMonthsList;

        if (newPaidMonthsList.length >= totalMonths) {
          updates['isPaid'] = true;
        }
      }

      transaction.update(docRef, updates);
    });
  }

  @override
  Future<void> toggleInstallmentMonth(
    String userId,
    String debtId,
    int monthIndex,
    bool isPaid,
    double monthlyAmount,
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
      final totalMonths = (snapshot.data()?['installmentMonths'] ?? 0).toInt();
      final paidMonthsList = (snapshot.data()?['paidInstallmentMonths'] as List? ?? [])
          .map((e) => (e as num).toInt())
          .toList();

      if (isPaid) {
        if (!paidMonthsList.contains(monthIndex)) {
          paidMonthsList.add(monthIndex);
        }
      } else {
        paidMonthsList.remove(monthIndex);
      }

      double newPaidAmount = paidAmount;
      if (isPaid) {
        newPaidAmount += monthlyAmount;
      } else {
        newPaidAmount -= monthlyAmount;
      }
      if (newPaidAmount < 0) newPaidAmount = 0.0;
      if (newPaidAmount > totalAmount) newPaidAmount = totalAmount;

      final isPaidOff = paidMonthsList.length >= totalMonths || newPaidAmount >= totalAmount;

      transaction.update(docRef, {
        'paidInstallmentMonths': paidMonthsList,
        'paidAmount': newPaidAmount,
        'isPaid': isPaidOff,
      });
    });
  }
}
