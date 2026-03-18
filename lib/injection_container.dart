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
import 'features/ai_chat/data/repositories/ai_chat_repository.dart';
import 'features/ai_chat/presentation/bloc/ai_chat_bloc.dart';

import 'features/home/domain/repositories/transaction_repository.dart';
import 'features/home/data/repositories/firestore_transaction_repository_impl.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/home/presentation/bloc/analysis/analysis_bloc.dart';
import 'features/transaction/presentation/bloc/add_transaction_bloc.dart';
import 'features/transaction/presentation/bloc/action/transaction_action_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/savings/data/repositories/firestore_savings_repository_impl.dart';
import 'features/savings/presentation/bloc/savings_bloc.dart';
import 'features/debt/data/repositories/firestore_debt_repository_impl.dart';
import 'features/debt/presentation/bloc/debt_bloc.dart';

import 'features/budget/domain/repositories/budget_repository.dart';
import 'features/budget/data/repositories/firestore_budget_repository_impl.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/budget/presentation/bloc/add_budget_bloc.dart';
import 'features/budget/presentation/bloc/edit_budget_bloc.dart';

import 'features/payment_method/domain/repositories/payment_method_repository.dart';
import 'features/payment_method/data/repositories/firestore_payment_method_repository_impl.dart';
import 'features/payment_method/presentation/bloc/payment_method_bloc.dart';

import 'features/category/domain/repositories/category_repository.dart';
import 'features/category/data/repositories/firestore_category_repository_impl.dart';
import 'features/category/presentation/bloc/category_bloc.dart';

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
      authRepository: sl(),
    ),
  );

  // --- Features: Transactions / Home Options ---
  sl.registerLazySingleton<TransactionRepository>(
    () => FirestoreTransactionRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(() => HomeBloc(repository: sl()));

  sl.registerFactory(() => AnalysisBloc(transactionRepository: sl()));

  sl.registerFactory(() => AddTransactionBloc(repository: sl()));

  sl.registerFactory(() => TransactionActionBloc(repository: sl()));

  sl.registerFactory(() => HistoryBloc(repository: sl()));

  // Blocs - Analytics
  sl.registerFactory(() => AnalyticsBloc(repository: sl()));

  // --- Features: Savings Goal ---
  sl.registerLazySingleton<FirestoreSavingsRepositoryImpl>(
    () => FirestoreSavingsRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(() => SavingsBloc(repository: sl()));

  // --- Features: Debt Tracking ---
  sl.registerLazySingleton<FirestoreDebtRepositoryImpl>(
    () => FirestoreDebtRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(() => DebtBloc(repository: sl()));

  // --- Features: Budget ---
  sl.registerLazySingleton<BudgetRepository>(
    () => FirestoreBudgetRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(
    () => BudgetBloc(budgetRepository: sl(), transactionRepository: sl()),
  );

  sl.registerFactory(() => AddBudgetBloc(budgetRepository: sl()));
  sl.registerFactory(() => EditBudgetBloc(budgetRepository: sl()));

  // --- Features: Payment Methods ---
  sl.registerLazySingleton<PaymentMethodRepository>(
    () => FirestorePaymentMethodRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(() => PaymentMethodBloc(repository: sl()));

  // --- Features: Custom Categories ---
  sl.registerLazySingleton<CategoryRepository>(
    () => FirestoreCategoryRepositoryImpl(firestore: sl()),
  );

  sl.registerFactory(() => CategoryBloc(repository: sl()));

  // --- Features: AI Chatbot ---
  sl.registerLazySingleton(() => AIChatRepository(firestore: sl()));
  sl.registerFactory(() => AIChatBloc(repository: sl(), authRepository: sl()));
}
