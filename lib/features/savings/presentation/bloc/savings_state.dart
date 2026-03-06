import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_goal_entity.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsLoaded extends SavingsState {
  final List<SavingsGoalEntity> goals;

  const SavingsLoaded(this.goals);

  @override
  List<Object> get props => [goals];
}

class SavingsError extends SavingsState {
  final String message;

  const SavingsError(this.message);

  @override
  List<Object> get props => [message];
}

class AddSavingsFundsSuccess extends SavingsState {
  final bool isAchieved;
  final SavingsGoalEntity goal;

  const AddSavingsFundsSuccess(this.goal, {this.isAchieved = false});

  @override
  List<Object> get props => [goal, isAchieved];
}
