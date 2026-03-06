import 'package:equatable/equatable.dart';

abstract class TransactionActionState extends Equatable {
  const TransactionActionState();

  @override
  List<Object?> get props => [];
}

class TransactionActionInitial extends TransactionActionState {}

class TransactionActionLoading extends TransactionActionState {}

class TransactionActionSuccess extends TransactionActionState {
  final String message;

  const TransactionActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionActionFailure extends TransactionActionState {
  final String error;

  const TransactionActionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
