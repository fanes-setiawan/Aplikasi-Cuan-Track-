import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../constants/app_dimens.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightM,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: backgroundColor ?? AppColors.divider),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
              ),
              child: _buildContent(),
            )
          : (gradient != null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: (backgroundColor ?? const Color(0xFF10b981)).withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      ),
                    ),
                    child: _buildContent(),
                  ),
                )
              : ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor ?? AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                  child: _buildContent(),
                )),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: AppDimens.sm)],
        Text(
          text,
          style: AppStyles.buttonText.copyWith(
            color:
                textColor ??
                (isOutlined ? AppColors.textPrimary : Colors.white),
          ),
        ),
      ],
    );
  }
}
