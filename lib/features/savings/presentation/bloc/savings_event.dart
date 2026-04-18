import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/entities/savings_history_entity.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSavingsGoals extends SavingsEvent {
  final String userId;

  const LoadSavingsGoals(this.userId);

  @override
  List<Object> get props => [userId];
}

class SavingsGoalsUpdated extends SavingsEvent {
  final List<SavingsGoalEntity> goals;

  const SavingsGoalsUpdated(this.goals);

  @override
  List<Object> get props => [goals];
}

class SavingsHistoryUpdated extends SavingsEvent {
  final List<SavingsHistoryEntity> history;

  const SavingsHistoryUpdated(this.history);

  @override
  List<Object> get props => [history];
}

class AddSavingsGoal extends SavingsEvent {
  final String userId;
  final SavingsGoalEntity goal;

  const AddSavingsGoal(this.userId, this.goal);

  @override
  List<Object> get props => [userId, goal];
}

class DeleteSavingsGoal extends SavingsEvent {
  final String userId;
  final String goalId;

  const DeleteSavingsGoal(this.userId, this.goalId);

  @override
  List<Object> get props => [userId, goalId];
}

class UpdateSavingsGoal extends SavingsEvent {
  final String userId;
  final SavingsGoalEntity goal;

  const UpdateSavingsGoal(this.userId, this.goal);

  @override
  List<Object> get props => [userId, goal];
}

class AddFundsToGoal extends SavingsEvent {
  final String userId;
  final String goalId;
  final double amount;

  const AddFundsToGoal({
    required this.userId,
    required this.goalId,
    required this.amount,
  });

  @override
  List<Object> get props => [userId, goalId, amount];
}

class SavingsErrorEvent extends SavingsEvent {
  final String message;

  const SavingsErrorEvent(this.message);

  @override
  List<Object> get props => [message];
}
