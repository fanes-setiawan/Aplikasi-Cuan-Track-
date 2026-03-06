import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/transaction_entity.dart';

abstract class AddTransactionEvent extends Equatable {
  const AddTransactionEvent();

  @override
  List<Object?> get props => [];
}

class SubmitTransaction extends AddTransactionEvent {
  final TransactionEntity transaction;

  const SubmitTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransaction extends AddTransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
