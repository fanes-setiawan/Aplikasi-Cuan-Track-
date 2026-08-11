import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import 'package:cuan_track/features/payment_method/domain/entities/payment_method_entity.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_bloc.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_event.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  final String providerName;

  const AddPaymentMethodScreen({super.key, required this.providerName});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Detail Metode', style: AppStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.padding16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSizes.padding16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Penyedia Terpilih', style: AppStyles.caption),
                        Text(
                          widget.providerName,
                          style: AppStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Ubah',
                      style: AppStyles.bodyTextSecondary.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingV32),
            Text(
              'Informasi Akun',
              style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSizes.paddingV16),
            CustomTextField(
              label: 'Nama Akun',
              hintText: 'Contoh: Tabungan Utama, GoPay Pribadi',
              controller: _nameController,
            ),
            SizedBox(height: AppSizes.paddingV16),
            CustomTextField(
              label: 'Nomor Rekening / ID (Opsional)',
              hintText: 'Nomor rekening atau ID akun Anda',
              controller: _numberController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSizes.paddingV16),
            CustomTextField(
              label: 'Saldo Awal',
              hintText: '0',
              controller: _balanceController,
              keyboardType: TextInputType.number,
              prefix: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  'Rp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.paddingV24),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.padding16,
                vertical: AppSizes.paddingV8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radius16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadikan Metode Utama',
                        style: AppStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gunakan otomatis saat mencatat transaksi',
                        style: AppStyles.caption,
                      ),
                    ],
                  ),
                  Switch(
                    value: _isDefault,
                    onChanged: (val) {
                      setState(() {
                        _isDefault = val;
                      });
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Simpan Metode Pembayaran',
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  AppHelpers.showSnackBar(
                    context,
                    'Anda belum login',
                    isError: true,
                  );
                  return;
                }

                if (_nameController.text.isEmpty) {
                  AppHelpers.showSnackBar(
                    context,
                    'Nama akun harus diisi',
                    isError: true,
                  );
                  return;
                }

                String type = 'Tunai';
                String iconPath = 'payments_outlined';
                if (widget.providerName.toLowerCase().contains('bank')) {
                  type = 'Bank';
                  iconPath = 'account_balance';
                } else if (widget.providerName.toLowerCase().contains(
                      'gopay',
                    ) ||
                    widget.providerName.toLowerCase().contains('ovo') ||
                    widget.providerName.toLowerCase().contains('dana')) {
                  type = 'Dompet Digital';
                  iconPath = 'account_balance_wallet_outlined';
                }

                final newMethod = PaymentMethodEntity(
                  id: '',
                  userId: user.uid,
                  name: _nameController.text.trim(),
                  type: type,
                  accountNumber: _numberController.text.trim().isEmpty
                      ? '-'
                      : _numberController.text.trim(),
                  balance:
                      double.tryParse(_balanceController.text.trim()) ?? 0.0,
                  iconPath: iconPath,
                );

                context.read<PaymentMethodBloc>().add(
                  AddPaymentMethod(newMethod),
                );

                Navigator.pop(context);
                Navigator.pop(context);
                AppHelpers.showSnackBar(
                  context,
                  '${_nameController.text} berhasil ditambahkan',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
