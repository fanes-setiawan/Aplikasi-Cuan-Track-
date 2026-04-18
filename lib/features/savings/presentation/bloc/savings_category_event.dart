import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_category_entity.dart';

abstract class SavingsCategoryEvent extends Equatable {
  const SavingsCategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavingsCategories extends SavingsCategoryEvent {
  final String userId;
  const LoadSavingsCategories(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddSavingsCategory extends SavingsCategoryEvent {
  final SavingsCategoryEntity category;
  const AddSavingsCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateSavingsCategory extends SavingsCategoryEvent {
  final SavingsCategoryEntity category;
  const UpdateSavingsCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteSavingsCategory extends SavingsCategoryEvent {
  final String userId;
  final String categoryId;
  const DeleteSavingsCategory(this.userId, this.categoryId);

  @override
  List<Object?> get props => [userId, categoryId];
}

class SavingsCategoriesUpdated extends SavingsCategoryEvent {
  final List<SavingsCategoryEntity> categories;
  const SavingsCategoriesUpdated(this.categories);

  @override
  List<Object?> get props => [categories];
}
