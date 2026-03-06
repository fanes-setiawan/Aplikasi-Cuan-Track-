import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/firestore_savings_repository_impl.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final FirestoreSavingsRepositoryImpl repository;
  StreamSubscription? _savingsSubscription;

  SavingsBloc({required this.repository}) : super(SavingsInitial()) {
    on<LoadSavingsGoals>(_onLoadSavingsGoals);
    on<SavingsGoalsUpdated>(_onSavingsGoalsUpdated);
    on<AddSavingsGoal>(_onAddSavingsGoal);
    on<DeleteSavingsGoal>(_onDeleteSavingsGoal);
    on<AddFundsToGoal>(_onAddFundsToGoal);
  }

  void _onLoadSavingsGoals(LoadSavingsGoals event, Emitter<SavingsState> emit) {
    emit(SavingsLoading());
    _savingsSubscription?.cancel();
    _savingsSubscription = repository
        .watchSavingsGoals(event.userId)
        .listen(
          (goals) {
            add(SavingsGoalsUpdated(goals));
          },
          onError: (error) {
            emit(SavingsError(error.toString()));
          },
        );
  }

  void _onSavingsGoalsUpdated(
    SavingsGoalsUpdated event,
    Emitter<SavingsState> emit,
  ) {
    emit(SavingsLoaded(event.goals));
  }

  Future<void> _onAddSavingsGoal(
    AddSavingsGoal event,
    Emitter<SavingsState> emit,
  ) async {
    try {
      await repository.addSavingsGoal(event.userId, event.goal);
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onDeleteSavingsGoal(
    DeleteSavingsGoal event,
    Emitter<SavingsState> emit,
  ) async {
    try {
      await repository.deleteSavingsGoal(event.userId, event.goalId);
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onAddFundsToGoal(
    AddFundsToGoal event,
    Emitter<SavingsState> emit,
  ) async {
    try {
      // Find current goal state to check if we just achieved it
      final currentState = state;
      if (currentState is SavingsLoaded) {
        final goal = currentState.goals.firstWhere((g) => g.id == event.goalId);
        final newTotal = goal.currentAmount + event.amount;
        final justAchieved = !goal.isAchieved && newTotal >= goal.targetAmount;

        await repository.addFundsToGoal(
          event.userId,
          event.goalId,
          event.amount,
        );

        if (justAchieved) {
          emit(AddSavingsFundsSuccess(goal, isAchieved: true));
        }
      } else {
        await repository.addFundsToGoal(
          event.userId,
          event.goalId,
          event.amount,
        );
      }
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _savingsSubscription?.cancel();
    return super.close();
  }
}
