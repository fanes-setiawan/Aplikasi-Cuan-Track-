import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/firestore_debt_repository_impl.dart';
import 'debt_event.dart';
import 'debt_state.dart';

class DebtBloc extends Bloc<DebtEvent, DebtState> {
  final FirestoreDebtRepositoryImpl repository;
  StreamSubscription? _debtSubscription;

  DebtBloc({required this.repository}) : super(DebtInitial()) {
    on<LoadDebts>(_onLoadDebts);
    on<DebtsUpdated>(_onDebtsUpdated);
    on<AddDebt>(_onAddDebt);
    on<UpdateDebt>(_onUpdateDebt);
    on<DeleteDebt>(_onDeleteDebt);
    on<AddPaymentToDebt>(_onAddPaymentToDebt);
  }

  void _onLoadDebts(LoadDebts event, Emitter<DebtState> emit) {
    emit(DebtLoading());
    _debtSubscription?.cancel();
    _debtSubscription = repository
        .watchDebts(event.userId)
        .listen(
          (debts) {
            add(DebtsUpdated(debts));
          },
          onError: (error) {
            emit(DebtError(error.toString()));
          },
        );
  }

  void _onDebtsUpdated(DebtsUpdated event, Emitter<DebtState> emit) {
    emit(DebtLoaded(event.debts));
  }

  Future<void> _onAddDebt(AddDebt event, Emitter<DebtState> emit) async {
    try {
      await repository.addDebt(event.userId, event.debt);
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  Future<void> _onUpdateDebt(UpdateDebt event, Emitter<DebtState> emit) async {
    try {
      await repository.updateDebt(event.userId, event.debt);
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  Future<void> _onDeleteDebt(DeleteDebt event, Emitter<DebtState> emit) async {
    try {
      await repository.deleteDebt(event.userId, event.debtId);
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  Future<void> _onAddPaymentToDebt(
    AddPaymentToDebt event,
    Emitter<DebtState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is DebtLoaded) {
        final debt = currentState.debts.firstWhere((d) => d.id == event.debtId);
        final newTotal = debt.paidAmount + event.amount;
        final justPaidOff = !debt.isPaid && newTotal >= debt.amount;

        await repository.addPaymentToDebt(
          event.userId,
          event.debtId,
          event.amount,
        );

        if (justPaidOff) {
          emit(AddDebtPaymentSuccess(debt, isPaidOff: true));
        }
      } else {
        await repository.addPaymentToDebt(
          event.userId,
          event.debtId,
          event.amount,
        );
      }
    } catch (e) {
      emit(DebtError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debtSubscription?.cancel();
    return super.close();
  }
}
