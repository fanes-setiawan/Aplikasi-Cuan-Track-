import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../bloc/action/transaction_action_bloc.dart';
import '../bloc/action/transaction_action_event.dart';
import '../bloc/action/transaction_action_state.dart';
import 'add_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius16),
          ),
          title: Text('Hapus Transaksi', style: AppStyles.heading2),
          content: Text(
            'Apakah Anda yakin ingin menghapus transaksi ini? Data yang dihapus tidak dapat dikembalikan.',
            style: AppStyles.bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: AppStyles.buttonText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius8),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransactionActionBloc>().add(
                  DeleteTransaction(transaction.id),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? const Color(0xFF27AE60) : AppColors.error;
    final amountPrefix = isIncome ? '+' : '-';
    final formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(transaction.amount);

    return BlocListener<TransactionActionBloc, TransactionActionState>(
      listener: (context, state) {
        if (state is TransactionActionLoading) {
        } else if (state is TransactionActionFailure) {
          AppHelpers.showSnackBar(
            context,
            'Gagal menghapus: ${state.error}',
            isError: true,
          );
        } else if (state is TransactionActionSuccess) {
          AppHelpers.showSnackBar(context, state.message);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF020617),
        appBar: AppBar(
          backgroundColor: const Color(0xFF020617),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Detail Transaksi',
            style: AppStyles.heading2.copyWith(fontSize: AppSizes.font16, color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimens.lg),
              Container(
                padding: EdgeInsets.all(AppSizes.padding16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.download_rounded : Icons.upload_rounded,
                  color: amountColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                '$amountPrefix $formattedAmount',
                style: AppStyles.heading1.copyWith(
                  color: amountColor,
                  fontSize: AppSizes.font32,
                ),
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                transaction.categoryName ?? 'Lainnya',
                style: AppStyles.bodyText.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSizes.paddingV32),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(AppSizes.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppDimens.md),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Jenis Transaksi',
                      isIncome ? 'Pemasukan' : 'Pengeluaran',
                      Icons.swap_horiz_rounded,
                    ),
                    Divider(height: AppSizes.paddingV24, color: const Color(0xFF1E293B)),
                    _buildDetailRow(
                      'Tanggal',
                      DateFormat(
                        'dd MMMM yyyy, HH:mm',
                        'id',
                      ).format(transaction.date),
                      Icons.calendar_today_rounded,
                    ),
                    Divider(height: AppSizes.paddingV24, color: const Color(0xFF1E293B)),
                    _buildDetailRow(
                      'Catatan',
                      transaction.notes?.isNotEmpty == true
                          ? transaction.notes!
                          : '-',
                      Icons.notes_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(
                      isIncome: isIncome,
                      transactionForEdit: transaction,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius12),
                ),
              ),
              child: Text('Edit Transaksi', style: AppStyles.buttonText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 20),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.caption.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppSizes.paddingV4),
              Text(
                value,
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
