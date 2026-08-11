// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/payment_method_repository.dart';
import 'payment_method_event.dart';
import 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final PaymentMethodRepository repository;
  StreamSubscription? _subscription;

  PaymentMethodBloc({required this.repository})
    : super(PaymentMethodInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<PaymentMethodsUpdated>(_onPaymentMethodsUpdated);
    on<AddPaymentMethod>(_onAddPaymentMethod);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
  }

  void _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    try {
      await repository.seedDefaultMethodsIfEmpty(event.userId);

      _subscription?.cancel();
      _subscription = repository.watchPaymentMethods(event.userId).listen((
        paymentMethods,
      ) {
        add(PaymentMethodsUpdated(paymentMethods));
      });
    } catch (e) {
      emit(PaymentMethodError(e.toString()));
    }
  }

  void _onPaymentMethodsUpdated(
    PaymentMethodsUpdated event,
    Emitter<PaymentMethodState> emit,
  ) {
    emit(PaymentMethodLoaded(event.paymentMethods));
  }

  Future<void> _onAddPaymentMethod(
    AddPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    try {
      await repository.addPaymentMethod(event.paymentMethod);
    } catch (e) {}
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    try {
      await repository.deletePaymentMethod(event.userId, event.methodId);
    } catch (e) {}
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
