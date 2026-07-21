import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'features/payment_method/presentation/bloc/payment_method_bloc.dart';
import 'features/category/presentation/bloc/category_bloc.dart';
import 'features/transaction/presentation/bloc/action/transaction_action_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/savings/presentation/bloc/savings_bloc.dart';
import 'features/savings/presentation/bloc/savings_category_bloc.dart';
import 'features/debt/presentation/bloc/debt_bloc.dart';
import 'injection_container.dart' as di;
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/ad_service.dart';
import 'package:intl/date_symbol_data_local.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService().init();
  await AudioService().init();

  await initializeDateFormatting('id_ID', null);
  await di.init();
  await di.sl<AdService>().init();
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
        BlocProvider<PaymentMethodBloc>(
          create: (_) => di.sl<PaymentMethodBloc>(),
        ),
        BlocProvider<CategoryBloc>(create: (_) => di.sl<CategoryBloc>()),
        BlocProvider<TransactionActionBloc>(
          create: (_) => di.sl<TransactionActionBloc>(),
        ),
        BlocProvider<AnalyticsBloc>(create: (_) => di.sl<AnalyticsBloc>()),
        BlocProvider<SavingsBloc>(create: (_) => di.sl<SavingsBloc>()),
        BlocProvider<SavingsCategoryBloc>(
          create: (_) => di.sl<SavingsCategoryBloc>(),
        ),
        BlocProvider<DebtBloc>(create: (_) => di.sl<DebtBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 917),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Cuan Track',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
              useMaterial3: true,
              fontFamily: 'Roboto',
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
