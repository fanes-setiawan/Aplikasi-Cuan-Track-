import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  final String userId;
  final DateTime month;

  const LoadAnalyticsEvent(this.userId, this.month);

  @override
  List<Object> get props => [userId, month];
}

class AnalyticsTransactionsUpdated extends AnalyticsEvent {
  final LoadAnalyticsEvent originalEvent;

  const AnalyticsTransactionsUpdated(this.originalEvent);

  @override
  List<Object> get props => [originalEvent];
}
