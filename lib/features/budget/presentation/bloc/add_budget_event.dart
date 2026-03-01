import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class AddBudgetEvent extends Equatable {
  const AddBudgetEvent();

  @override
  List<Object> get props => [];
}

class SaveBudgetEvent extends AddBudgetEvent {
  final BudgetEntity budget;

  const SaveBudgetEvent(this.budget);

  @override
  List<Object> get props => [budget];
}
