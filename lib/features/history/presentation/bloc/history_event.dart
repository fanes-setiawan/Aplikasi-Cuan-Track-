import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class ChangeMonthEvent extends HistoryEvent {
  final String userId;
  final DateTime month;

  const ChangeMonthEvent(this.userId, this.month);

  @override
  List<Object?> get props => [userId, month];
}

class TransactionsUpdated extends HistoryEvent {
  final ChangeMonthEvent originalEvent;

  const TransactionsUpdated(this.originalEvent);

  @override
  List<Object?> get props => [originalEvent];
}
