import 'package:flutter/material.dart';
import 'package:cuan_track/core/theme/app_colors.dart';
import 'package:cuan_track/features/splash/presentation/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuan Track',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Roboto', // Change when a custom font is added
      ),
      home: const SplashScreen(),
    );
  }
}
