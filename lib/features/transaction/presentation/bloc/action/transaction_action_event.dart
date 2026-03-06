import 'package:equatable/equatable.dart';

abstract class TransactionActionEvent extends Equatable {
  const TransactionActionEvent();

  @override
  List<Object?> get props => [];
}

class DeleteTransaction extends TransactionActionEvent {
  final String transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}
