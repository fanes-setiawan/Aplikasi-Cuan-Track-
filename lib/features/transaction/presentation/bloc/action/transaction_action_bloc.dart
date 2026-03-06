import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../home/domain/repositories/transaction_repository.dart';
import 'transaction_action_event.dart';
import 'transaction_action_state.dart';

class TransactionActionBloc
    extends Bloc<TransactionActionEvent, TransactionActionState> {
  final TransactionRepository repository;

  TransactionActionBloc({required this.repository})
    : super(TransactionActionInitial()) {
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionLoading());
    try {
      await repository.deleteTransaction(event.transactionId);
      emit(const TransactionActionSuccess('Transaksi berhasil dihapus'));
    } catch (e) {
      emit(TransactionActionFailure(e.toString()));
    }
  }
}
