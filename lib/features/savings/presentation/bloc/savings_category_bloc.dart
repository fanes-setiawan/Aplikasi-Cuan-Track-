import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/savings_category_repository.dart';
import 'savings_category_event.dart';
import 'savings_category_state.dart';

class SavingsCategoryBloc extends Bloc<SavingsCategoryEvent, SavingsCategoryState> {
  final SavingsCategoryRepository _repository;
  StreamSubscription? _subscription;

  SavingsCategoryBloc(this._repository) : super(SavingsCategoryInitial()) {
    on<LoadSavingsCategories>(_onLoadSavingsCategories);
    on<AddSavingsCategory>(_onAddSavingsCategory);
    on<UpdateSavingsCategory>(_onUpdateSavingsCategory);
    on<DeleteSavingsCategory>(_onDeleteSavingsCategory);
    on<SavingsCategoriesUpdated>(_onSavingsCategoriesUpdated);
  }

  Future<void> _onLoadSavingsCategories(
    LoadSavingsCategories event,
    Emitter<SavingsCategoryState> emit,
  ) async {
    emit(SavingsCategoryLoading());
    await _subscription?.cancel();
    _subscription = _repository.getSavingsCategories(event.userId).listen((categories) {
      add(SavingsCategoriesUpdated(categories));
    });
  }

  void _onSavingsCategoriesUpdated(
    SavingsCategoriesUpdated event,
    Emitter<SavingsCategoryState> emit,
  ) {
    emit(SavingsCategoryLoaded(event.categories));
  }

  Future<void> _onAddSavingsCategory(
    AddSavingsCategory event,
    Emitter<SavingsCategoryState> emit,
  ) async {
    try {
      await _repository.addSavingsCategory(event.category);
    } catch (e) {
      emit(SavingsCategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateSavingsCategory(
    UpdateSavingsCategory event,
    Emitter<SavingsCategoryState> emit,
  ) async {
    try {
      await _repository.updateSavingsCategory(event.category);
    } catch (e) {
      emit(SavingsCategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteSavingsCategory(
    DeleteSavingsCategory event,
    Emitter<SavingsCategoryState> emit,
  ) async {
    try {
      await _repository.deleteSavingsCategory(event.userId, event.categoryId);
    } catch (e) {
      emit(SavingsCategoryError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
