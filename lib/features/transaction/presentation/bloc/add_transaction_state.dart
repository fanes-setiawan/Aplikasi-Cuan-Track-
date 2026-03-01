import 'package:equatable/equatable.dart';

abstract class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object?> get props => [];
}

class AddTransactionInitial extends AddTransactionState {}

class AddTransactionLoading extends AddTransactionState {}

class AddTransactionSuccess extends AddTransactionState {}

class AddTransactionFailure extends AddTransactionState {
  final String message;

  const AddTransactionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
