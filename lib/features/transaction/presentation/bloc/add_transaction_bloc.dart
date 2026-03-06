import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/repositories/transaction_repository.dart';
import 'add_transaction_event.dart';
import 'add_transaction_state.dart';

class AddTransactionBloc
    extends Bloc<AddTransactionEvent, AddTransactionState> {
  final TransactionRepository repository;

  AddTransactionBloc({required this.repository})
    : super(AddTransactionInitial()) {
    on<SubmitTransaction>(_onSubmitTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
  }

  Future<void> _onSubmitTransaction(
    SubmitTransaction event,
    Emitter<AddTransactionState> emit,
  ) async {
    emit(AddTransactionLoading());
    try {
      await repository.addTransaction(event.transaction);
      emit(AddTransactionSuccess());
    } catch (e) {
      emit(AddTransactionFailure(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<AddTransactionState> emit,
  ) async {
    emit(AddTransactionLoading());
    try {
      await repository.updateTransaction(event.transaction);
      emit(AddTransactionSuccess());
    } catch (e) {
      emit(AddTransactionFailure(e.toString()));
    }
  }
}
