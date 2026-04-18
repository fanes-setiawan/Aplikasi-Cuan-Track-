import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_category_entity.dart';

abstract class SavingsCategoryState extends Equatable {
  const SavingsCategoryState();

  @override
  List<Object?> get props => [];
}

class SavingsCategoryInitial extends SavingsCategoryState {}

class SavingsCategoryLoading extends SavingsCategoryState {}

class SavingsCategoryLoaded extends SavingsCategoryState {
  final List<SavingsCategoryEntity> categories;
  const SavingsCategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class SavingsCategoryError extends SavingsCategoryState {
  final String message;
  const SavingsCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
