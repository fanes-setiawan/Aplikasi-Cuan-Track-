import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../constants/app_dimens.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? assetPath;
  final VoidCallback? onAction;
  final String? actionLabel;
  final double? imageWidth;
  final EdgeInsetsGeometry? padding;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.assetPath,
    this.onAction,
    this.actionLabel,
    this.imageWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimens.lg,
              vertical: AppDimens.sm,
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              assetPath ?? 'assets/images/img_emty.svg',
              width: imageWidth ?? 120,
            ),
            const SizedBox(height: AppDimens.md),
            Text(title, style: AppStyles.heading3, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: AppStyles.bodyTextSecondary,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppDimens.lg),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.xl,
                    vertical: AppDimens.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  elevation: 0,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
