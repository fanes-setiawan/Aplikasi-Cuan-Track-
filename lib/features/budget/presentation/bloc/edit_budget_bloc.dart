import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/budget_repository.dart';
import 'edit_budget_event.dart';
import 'edit_budget_state.dart';

class EditBudgetBloc extends Bloc<EditBudgetEvent, EditBudgetState> {
  final BudgetRepository budgetRepository;

  EditBudgetBloc({required this.budgetRepository})
    : super(EditBudgetInitial()) {
    on<UpdateBudgetEvent>(_onUpdateBudget);
  }

  void _onUpdateBudget(
    UpdateBudgetEvent event,
    Emitter<EditBudgetState> emit,
  ) async {
    emit(EditBudgetLoading());
    try {
      await budgetRepository.updateBudget(event.budget);
      emit(EditBudgetSuccess());
    } catch (e) {
      emit(EditBudgetError(e.toString()));
    }
  }
}
