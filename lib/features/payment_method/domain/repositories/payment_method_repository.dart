import '../entities/payment_method_entity.dart';

abstract class PaymentMethodRepository {
  Stream<List<PaymentMethodEntity>> watchPaymentMethods(String userId);
  Future<void> addPaymentMethod(PaymentMethodEntity method);
  Future<void> updatePaymentMethod(PaymentMethodEntity method);
  Future<void> deletePaymentMethod(String userId, String methodId);
  Future<void> seedDefaultMethodsIfEmpty(String userId);
}
