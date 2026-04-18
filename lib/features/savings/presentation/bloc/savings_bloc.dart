import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/firestore_savings_repository_impl.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../../domain/entities/savings_history_entity.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final FirestoreSavingsRepositoryImpl repository;
  StreamSubscription? _savingsSubscription;
  StreamSubscription? _historySubscription;

  List<SavingsGoalEntity> _currentGoals = [];
  List<SavingsHistoryEntity> _currentHistory = [];

  SavingsBloc({required this.repository}) : super(SavingsInitial()) {
    on<LoadSavingsGoals>(_onLoadSavingsGoals);
    on<SavingsGoalsUpdated>(_onSavingsGoalsUpdated);
    on<SavingsHistoryUpdated>(_onSavingsHistoryUpdated);
    on<AddSavingsGoal>(_onAddSavingsGoal);
    on<UpdateSavingsGoal>(_onUpdateSavingsGoal);
    on<DeleteSavingsGoal>(_onDeleteSavingsGoal);
    on<AddFundsToGoal>(_onAddFundsToGoal);
    on<SavingsErrorEvent>(_onSavingsErrorEvent);
  }

  void _onSavingsErrorEvent(
    SavingsErrorEvent event,
    Emitter<SavingsState> emit,
  ) {
    emit(SavingsError(event.message));
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
            add(const SavingsErrorEvent('Gagal memuat target tabungan'));
          },
        );

    _historySubscription?.cancel();
    _historySubscription = repository
        .watchSavingsHistory(event.userId)
        .listen(
          (history) {
            add(SavingsHistoryUpdated(history));
          },
          onError: (error) {
            add(const SavingsErrorEvent('Gagal memuat riwayat tabungan'));
          },
        );
  }

  void _onSavingsGoalsUpdated(
    SavingsGoalsUpdated event,
    Emitter<SavingsState> emit,
  ) {
    _currentGoals = event.goals;
    emit(SavingsLoaded(_currentGoals, _currentHistory));
  }

  void _onSavingsHistoryUpdated(
    SavingsHistoryUpdated event,
    Emitter<SavingsState> emit,
  ) {
    _currentHistory = event.history;
    emit(SavingsLoaded(_currentGoals, _currentHistory));
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

  Future<void> _onUpdateSavingsGoal(
    UpdateSavingsGoal event,
    Emitter<SavingsState> emit,
  ) async {
    try {
      await repository.updateSavingsGoal(event.userId, event.goal);
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
    _historySubscription?.cancel();
    return super.close();
  }
}
