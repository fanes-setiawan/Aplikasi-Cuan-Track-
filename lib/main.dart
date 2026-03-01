import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cuan_track/core/theme/app_colors.dart';
import 'package:cuan_track/features/splash/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/transaction/presentation/bloc/add_transaction_bloc.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/budget/presentation/bloc/add_budget_bloc.dart';
import 'injection_container.dart' as di;
import 'firebase_options.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
        BlocProvider<HomeBloc>(create: (_) => di.sl<HomeBloc>()),
        BlocProvider<AddTransactionBloc>(
          create: (_) => di.sl<AddTransactionBloc>(),
        ),
        BlocProvider<HistoryBloc>(create: (_) => di.sl<HistoryBloc>()),
        BlocProvider<BudgetBloc>(create: (_) => di.sl<BudgetBloc>()),
        BlocProvider<AddBudgetBloc>(create: (_) => di.sl<AddBudgetBloc>()),
      ],
      child: MaterialApp(
        title: 'Cuan Track',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
