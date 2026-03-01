import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/login_with_google_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/home/data/repositories/firestore_transaction_repository_impl.dart';
import 'features/home/domain/repositories/transaction_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/transaction/presentation/bloc/add_transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUserUseCase: sl(),
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      loginWithGoogleUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Features - Home
  // Bloc
  sl.registerFactory(() => HomeBloc(repository: sl()));
  sl.registerFactory(() => AddTransactionBloc(repository: sl()));
  sl.registerFactory(() => HistoryBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => FirestoreTransactionRepositoryImpl(firestore: sl()),
  );
}
