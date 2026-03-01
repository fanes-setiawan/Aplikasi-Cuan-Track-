import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_method_repository.dart';

class FirestorePaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final FirebaseFirestore firestore;

  FirestorePaymentMethodRepositoryImpl({required this.firestore});

  @override
  Stream<List<PaymentMethodEntity>> watchPaymentMethods(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return PaymentMethodEntity.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> addPaymentMethod(PaymentMethodEntity method) async {
    await firestore
        .collection('users')
        .doc(method.userId)
        .collection('payment_methods')
        .add(method.toMap());
  }

  @override
  Future<void> updatePaymentMethod(PaymentMethodEntity method) async {
    await firestore
        .collection('users')
        .doc(method.userId)
        .collection('payment_methods')
        .doc(method.id)
        .update(method.toMap());
  }

  @override
  Future<void> deletePaymentMethod(String userId, String methodId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .doc(methodId)
        .delete();
  }

  @override
  Future<void> seedDefaultMethodsIfEmpty(String userId) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('payment_methods')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      final defaultMethod = PaymentMethodEntity(
        id: '',
        userId: userId,
        name: 'Tunai',
        type: 'Tunai',
        accountNumber: '-',
        balance: 0.0,
        iconPath: 'account_balance_wallet',
      );
      await addPaymentMethod(defaultMethod);
    }
  }
}
