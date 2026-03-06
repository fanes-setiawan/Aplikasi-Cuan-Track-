import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class FirestoreTransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;

  FirestoreTransactionRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      final data = transaction.toMap();
      // Date conversion handled implicitly by plugin when passing DateTime
      await _firestore.collection('transactions').add(data);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      if (transaction.id.isEmpty) {
        throw Exception('Cannot update transaction without an ID');
      }
      final data = transaction.toMap();
      // Ensure we don't accidentally write the internal ID into the document payload map
      // if it behaves like that, though fromMap usually handles it.
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final entities = snapshot.docs.map((doc) {
        return TransactionEntity.fromMap(doc.data(), doc.id);
      }).toList();

      entities.sort((a, b) => b.date.compareTo(a.date));
      return entities.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsForMonth(
    String userId,
    DateTime month,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final List<TransactionEntity> entities = [];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final dateObj = data['date'];
        if (dateObj is Timestamp) {
          final date = dateObj.toDate();
          if (date.year == month.year && date.month == month.month) {
            entities.add(TransactionEntity.fromMap(data, doc.id));
          }
        }
      }

      entities.sort((a, b) => b.date.compareTo(a.date));
      return entities;
    } catch (e) {
      throw Exception('Failed to get transactions for month: $e');
    }
  }

  @override
  Future<double> getTotalBalance(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      double balance = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] ?? 'expense';

        if (type == 'income') {
          balance += amount;
        } else {
          balance -= amount;
        }
      }
      return balance;
    } catch (e) {
      throw Exception('Failed to calculate total balance: $e');
    }
  }

  @override
  Future<double> getCurrentMonthExpenses(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      double expenses = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] != 'expense') continue;

        final dateObj = data['date'];
        if (dateObj is Timestamp) {
          final date = dateObj.toDate();
          if (date.isAfter(startOfMonth) ||
              date.isAtSameMomentAs(startOfMonth)) {
            expenses += (data['amount'] ?? 0).toDouble();
          }
        }
      }
      return expenses;
    } catch (e) {
      throw Exception('Failed to calculate current month expenses: $e');
    }
  }

  @override
  Future<double> getCurrentMonthIncome(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      double income = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] != 'income') continue;

        final dateObj = data['date'];
        if (dateObj is Timestamp) {
          final date = dateObj.toDate();
          if (date.isAfter(startOfMonth) ||
              date.isAtSameMomentAs(startOfMonth)) {
            income += (data['amount'] ?? 0).toDouble();
          }
        }
      }
      return income;
    } catch (e) {
      throw Exception('Failed to calculate current month income: $e');
    }
  }

  @override
  Future<Map<String, double>> getCurrentMonthExpenseChart(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, double> expenseData = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['type'] != 'expense') continue;

        final dateObj = data['date'];
        if (dateObj is Timestamp) {
          final date = dateObj.toDate();
          if (date.isAfter(startOfMonth) ||
              date.isAtSameMomentAs(startOfMonth)) {
            final amount = (data['amount'] ?? 0).toDouble();
            final String category = data['categoryName'] ?? 'Lainnya';
            expenseData[category] = (expenseData[category] ?? 0) + amount;
          }
        }
      }
      return expenseData;
    } catch (e) {
      throw Exception('Failed to calculate expense chart: $e');
    }
  }

  @override
  Stream<void> watchTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((_) => null);
  }
}
