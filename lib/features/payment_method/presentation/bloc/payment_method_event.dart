import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_method_entity.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();

  @override
  List<Object> get props => [];
}

class LoadPaymentMethods extends PaymentMethodEvent {
  final String userId;

  const LoadPaymentMethods(this.userId);

  @override
  List<Object> get props => [userId];
}

class PaymentMethodsUpdated extends PaymentMethodEvent {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsUpdated(this.paymentMethods);

  @override
  List<Object> get props => [paymentMethods];
}

class AddPaymentMethod extends PaymentMethodEvent {
  final PaymentMethodEntity paymentMethod;

  const AddPaymentMethod(this.paymentMethod);

  @override
  List<Object> get props => [paymentMethod];
}

class DeletePaymentMethod extends PaymentMethodEvent {
  final String userId;
  final String methodId;

  const DeletePaymentMethod(this.userId, this.methodId);

  @override
  List<Object> get props => [userId, methodId];
}
