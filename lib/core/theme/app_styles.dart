import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  static TextStyle heading1 = TextStyle(
    fontSize: AppSizes.font24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = TextStyle(
    fontSize: AppSizes.font20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = TextStyle(
    fontSize: AppSizes.font18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyText = TextStyle(
    fontSize: AppSizes.font14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyTextSecondary = TextStyle(
    fontSize: AppSizes.font14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = TextStyle(
    fontSize: AppSizes.font12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle buttonText = TextStyle(
    fontSize: AppSizes.font16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
