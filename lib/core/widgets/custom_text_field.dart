import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../constants/app_dimens.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? prefix;
  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? borderColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.fillColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.borderColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: widget.labelColor,
          ),
        ),
        const SizedBox(height: AppDimens.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          style: AppStyles.bodyText.copyWith(color: widget.textColor),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppStyles.bodyTextSecondary.copyWith(
              color: widget.hintColor ?? AppColors.textHint,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  )
                : null,
            prefix: widget.prefix,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: widget.fillColor ?? Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.md,
              vertical: AppDimens.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(color: widget.borderColor ?? AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
