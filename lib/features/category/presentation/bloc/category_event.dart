import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String userId;

  const LoadCategories(this.userId);

  @override
  List<Object> get props => [userId];
}

class CategoriesUpdated extends CategoryEvent {
  final List<CategoryEntity> categories;

  const CategoriesUpdated(this.categories);

  @override
  List<Object> get props => [categories];
}

class AddCategory extends CategoryEvent {
  final CategoryEntity category;

  const AddCategory(this.category);

  @override
  List<Object> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryEntity category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String userId;
  final String categoryId;

  const DeleteCategory({required this.userId, required this.categoryId});

  @override
  List<Object> get props => [userId, categoryId];
}
