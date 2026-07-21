import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../domain/entities/debt_entity.dart';
import '../bloc/debt_bloc.dart';
import '../bloc/debt_event.dart';
import '../bloc/debt_state.dart';

class InstallmentDetailScreen extends StatefulWidget {
  final DebtEntity debt;
  final String userId;
  const InstallmentDetailScreen({
    super.key,
    required this.debt,
    required this.userId,
  });

  @override
  State<InstallmentDetailScreen> createState() =>
      _InstallmentDetailScreenState();
}

class _InstallmentDetailScreenState extends State<InstallmentDetailScreen> {
  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];



  void _showToggleStatusDialog(
    BuildContext context,
    DebtEntity debt,
    int index,
    String monthLabel,
    String yearLabel,
    bool currentIsPaid,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius16),
          ),
          title: Text(
            'Ubah Status - $monthLabel $yearLabel',
            style: AppStyles.heading2,
          ),
          content: Text(
            currentIsPaid
                ? 'Bulan ini ($monthLabel $yearLabel) sudah lunas. Apakah Anda ingin menandai bulan ini sebagai BELUM BAYAR?'
                : 'Bulan ini ($monthLabel $yearLabel) belum dibayar. Apakah Anda ingin menandai bulan ini sebagai LUNAS?',
            style: AppStyles.bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: AppStyles.bodyText),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DebtBloc>().add(
                  ToggleInstallmentMonth(
                    userId: widget.userId,
                    debtId: debt.id,
                    monthIndex: index,
                    isPaid: !currentIsPaid,
                    monthlyAmount: debt.monthlyPayment,
                  ),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: currentIsPaid ? Colors.red : Colors.green,
              ),
              child: Text(
                currentIsPaid ? 'Tandai Belum Bayar' : 'Tandai Lunas',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, DebtEntity debt) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Hapus Catatan', style: AppStyles.heading2),
          content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DebtBloc>().add(
                  DeleteDebt(widget.userId, debt.id),
                );
                Navigator.pop(ctx);
                Navigator.pop(context); // Pop detail screen as well
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DebtBloc, DebtState>(
      listener: (context, state) {
        if (state is AddDebtPaymentSuccess) {
          if (state.isPaidOff) {
            AppHelpers.showSnackBar(
              context,
              'Lunas! Hutang/Piutang atas nama ${state.debt.personName} telah lunas.',
            );
          } else {
            AppHelpers.showSnackBar(context, 'Berhasil mencatat pembayaran');
          }
        } else if (state is DebtError) {
          AppHelpers.showSnackBar(context, state.message, isError: true);
        }
      },
      builder: (context, state) {
        DebtEntity debt = widget.debt;
        if (state is DebtLoaded) {
          try {
            debt = state.debts.firstWhere((d) => d.id == widget.debt.id);
          } catch (_) {}
        }

        final percent = debt.totalMonths > 0
            ? (debt.paidMonths / debt.totalMonths)
            : 0.0;
        final progressPercent = (percent * 100).toInt();
        final totalRemaining = debt.amount - debt.paidAmount;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              debt.title.isNotEmpty ? debt.title : 'Cicilan Saya',
              style: AppStyles.heading2,
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                color: Colors.white,
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmDialog(context, debt);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        SizedBox(width: AppSizes.padding8),
                        Text(
                          'Hapus Catatan',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROGRESS PELUNASAN',
                            style: AppStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textHint,
                              letterSpacing: 0.8,
                              fontSize: AppSizes.font10,
                            ),
                          ),
                          Text(
                            '$progressPercent%',
                            style: TextStyle(
                              color: Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.font14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.paddingV8),
                      Text(
                        '${debt.paidMonths} dari ${debt.totalMonths} bulan lunas',
                        style: AppStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radius4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF0D47A1),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV16),
                      const Divider(height: 1),
                      SizedBox(height: AppSizes.paddingV16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOTAL SISA',
                                  style: AppStyles.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textHint,
                                    fontSize: AppSizes.font10,
                                  ),
                                ),
                                SizedBox(height: AppSizes.paddingV4),
                                Text(
                                  AppHelpers.formatCurrencyIdr(totalRemaining),
                                  style: AppStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizes.font16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'JATUH TEMPO',
                                style: AppStyles.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHint,
                                  fontSize: AppSizes.font10,
                                ),
                              ),
                              SizedBox(height: AppSizes.paddingV4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(debt.dueDate),
                                style: TextStyle(
                                  color: Color(0xFFD32F2F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.font14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.paddingV24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rincian Bulanan',
                      style: AppStyles.heading2.copyWith(fontSize: AppSizes.font18),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.padding12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Tahun ${debt.effectiveStartDate.year}',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.font12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.paddingV16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.73,
                  ),
                  itemCount: debt.totalMonths,
                  itemBuilder: (context, index) {
                    final startMonth = debt.effectiveStartDate.month; // 1-based
                    final targetMonthIndex = (startMonth - 1 + index) % 12;
                    final monthLabel = _months[targetMonthIndex];
                    final targetYear = debt.effectiveStartDate.year + (startMonth - 1 + index) ~/ 12;
                    final yearLabel = targetYear.toString();

                    final isPaidMonth = debt.paidInstallmentMonths.contains(index);

                    // Find the first unpaid index from 0 to totalMonths - 1
                    int firstUnpaidIndex = -1;
                    for (int i = 0; i < debt.totalMonths; i++) {
                      if (!debt.paidInstallmentMonths.contains(i)) {
                        firstUnpaidIndex = i;
                        break;
                      }
                    }

                    if (isPaidMonth) {
                      // Paid Month (LUNAS)
                      return _buildMonthCard(
                        monthLabel,
                        yearLabel,
                        debt.monthlyPayment,
                        const Color(0xFFE8F5E9),
                        const Color(0xFF2E7D32),
                        Icons.check,
                        'LUNAS',
                        const Color(0xFF2E7D32),
                        const Color(0xFFE8F5E9),
                        onTap: () => _showToggleStatusDialog(context, debt, index, monthLabel, yearLabel, true),
                      );
                    } else if (index == firstUnpaidIndex) {
                      // Current Due Month (BAYAR)
                      return _buildMonthCard(
                        monthLabel,
                        yearLabel,
                        debt.monthlyPayment,
                        Colors.white,
                        const Color(0xFF0D47A1),
                        Icons.access_time,
                        'BAYAR',
                        Colors.white,
                        const Color(0xFF0D47A1),
                        border: Border.all(
                          color: const Color(0xFF0D47A1),
                          width: 1.5,
                        ),
                        onTap: () => _showToggleStatusDialog(context, debt, index, monthLabel, yearLabel, false),
                      );
                    } else {
                      // Future Month (NANTI)
                      return _buildMonthCard(
                        monthLabel,
                        yearLabel,
                        debt.monthlyPayment,
                        const Color(0xFFF5F5F5),
                        Colors.grey[400]!,
                        Icons.access_time,
                        'NANTI',
                        Colors.grey[700]!,
                        const Color(0xFFE0E0E0),
                        onTap: () => _showToggleStatusDialog(context, debt, index, monthLabel, yearLabel, false),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthCard(
    String title,
    String year,
    double amount,
    Color bgColor,
    Color accentColor,
    IconData icon,
    String badgeText,
    Color badgeTextColor,
    Color badgeBgColor, {
    BoxBorder? border,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV8, horizontal: AppSizes.padding4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSizes.radius12),
          border: border ?? Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizes.font12,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  year,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeBgColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 16),
            ),
            Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppHelpers.formatCurrencyIdr(amount),
                    style: TextStyle(
                      fontSize: AppSizes.font10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.paddingV4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AppSizes.paddingV4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(AppSizes.radius4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
