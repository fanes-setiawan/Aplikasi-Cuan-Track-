import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class EditBudgetEvent extends Equatable {
  const EditBudgetEvent();

  @override
  List<Object> get props => [];
}

class UpdateBudgetEvent extends EditBudgetEvent {
  final BudgetEntity budget;

  const UpdateBudgetEvent(this.budget);

  @override
  List<Object> get props => [budget];
}
