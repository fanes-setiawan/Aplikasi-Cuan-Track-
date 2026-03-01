import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/login_with_google_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/home/domain/repositories/transaction_repository.dart';
import 'features/home/data/repositories/firestore_transaction_repository_impl.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/transaction/presentation/bloc/add_transaction_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';

import 'features/budget/domain/repositories/budget_repository.dart';
import 'features/budget/data/repositories/firestore_budget_repository_impl.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/budget/presentation/bloc/add_budget_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // --- External Dependencies ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // --- Core / Shared ---

  // --- Features: Auth ---
  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      loginWithGoogleUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // --- Features: Transactions / Home Options ---
  sl.registerLazySingleton<TransactionRepository>(
    () => FirestoreTransactionRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(() => HomeBloc(repository: sl()));

  sl.registerFactory(() => AddTransactionBloc(repository: sl()));

  sl.registerFactory(() => HistoryBloc(repository: sl()));

  // --- Features: Budget ---
  sl.registerLazySingleton<BudgetRepository>(
    () => FirestoreBudgetRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(
    () => BudgetBloc(budgetRepository: sl(), transactionRepository: sl()),
  );

  sl.registerFactory(() => AddBudgetBloc(budgetRepository: sl()));
}
