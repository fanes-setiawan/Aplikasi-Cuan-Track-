import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  StreamSubscription? _subscription;

  CategoryBloc({required this.repository}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  void _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await repository.seedDefaultCategoriesIfEmpty(event.userId);

      _subscription?.cancel();
      _subscription = repository.watchCategories(event.userId).listen((
        categories,
      ) {
        add(CategoriesUpdated(categories));
      });
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryState> emit,
  ) {
    emit(CategoryLoaded(event.categories));
  }

  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.addCategory(event.category);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.updateCategory(event.category);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await repository.deleteCategory(event.userId, event.categoryId);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
