import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_bloc.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_event.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_state.dart';
import 'payment_selection_sheet.dart';
import 'add_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<PaymentMethodBloc>().add(LoadPaymentMethods(user.uid));
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
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
        title: Text('Metode Pembayaran', style: AppStyles.heading2),
      ),
      body: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
        builder: (context, state) {
          if (state is PaymentMethodLoading || state is PaymentMethodInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PaymentMethodError) {
            return Center(child: Text("Gagal memuat: ${state.message}"));
          } else if (state is PaymentMethodLoaded) {
            final methods = state.paymentMethods;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.lg),
                  if (methods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppDimens.lg),
                      child: Text("Belum ada metode pembayaran."),
                    )
                  else
                    ...methods.map(
                      (method) => _buildPaymentMethodCard(
                        icon: _getIconForType(method.iconPath),
                        name: method.name,
                        type: method.type,
                        amount: _formatCurrency(method.balance),
                        iconBgColor: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                      ),
                    ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final String? selectedProvider =
                              await showModalBottomSheet<String>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    const PaymentSelectionSheet(),
                              );

                          if (selectedProvider != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPaymentMethodScreen(
                                  providerName: selectedProvider,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF27AE60).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Tambah Metode Baru',
                              style: AppStyles.bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getIconForType(String typeOrPath) {
    if (typeOrPath.contains('wallet')) {
      return Icons.account_balance_wallet_outlined;
    } else if (typeOrPath.contains('bank')) {
      return Icons.account_balance;
    } else if (typeOrPath.contains('credit')) {
      return Icons.credit_card;
    } else {
      return Icons.payments_outlined;
    }
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String name,
    required String type,
    required String amount,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 8),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.more_vert, color: AppColors.textHint, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
