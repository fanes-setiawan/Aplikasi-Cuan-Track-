import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/budget_repository.dart';
import 'add_budget_event.dart';
import 'add_budget_state.dart';

class AddBudgetBloc extends Bloc<AddBudgetEvent, AddBudgetState> {
  final BudgetRepository budgetRepository;

  AddBudgetBloc({required this.budgetRepository}) : super(AddBudgetInitial()) {
    on<SaveBudgetEvent>(_onSaveBudget);
  }

  void _onSaveBudget(
    SaveBudgetEvent event,
    Emitter<AddBudgetState> emit,
  ) async {
    emit(AddBudgetLoading());
    try {
      await budgetRepository.addBudget(event.budget);
      emit(AddBudgetSuccess());
    } catch (e) {
      emit(AddBudgetError(e.toString()));
    }
  }
}
