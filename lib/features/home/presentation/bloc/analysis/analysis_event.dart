import 'package:equatable/equatable.dart';

abstract class AnalysisEvent extends Equatable {
  const AnalysisEvent();

  @override
  List<Object?> get props => [];
}

class FetchAnalysisData extends AnalysisEvent {
  final String userId;
  final DateTime selectedMonth;

  const FetchAnalysisData(this.userId, this.selectedMonth);

  @override
  List<Object?> get props => [userId, selectedMonth];
}
