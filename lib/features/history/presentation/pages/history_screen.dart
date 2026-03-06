import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

import '../../../transaction/presentation/pages/transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool showBackButton;
  const HistoryScreen({super.key, this.showBackButton = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  String _userId = '';

  final Map<String, IconData> _categoryIconMap = {
    "Gaji": Icons.payments_outlined,
    "Bonus": Icons.stars_outlined,
    "Investasi": Icons.show_chart_outlined,
    "Makanan & Minuman": Icons.restaurant,
    "Makan": Icons.restaurant, // Legacy
    "Transportasi": Icons.directions_car,
    "Transport": Icons.directions_car, // Legacy
    "Belanja": Icons.shopping_bag,
    "Hiburan": Icons.theater_comedy,
  };

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      context.read<HistoryBloc>().add(ChangeMonthEvent(_userId, _selectedDate));
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + offset,
        1,
      );
      if (_userId.isNotEmpty) {
        context.read<HistoryBloc>().add(
          ChangeMonthEvent(_userId, _selectedDate),
        );
      }
    });
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
        centerTitle: true,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text('Riwayat Transaksi', style: AppStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => _showReportPreview(context),
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryInitial || state is HistoryLoading) {
            return Column(
              children: [
                _buildMonthSelector(),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }

          if (state is HistoryError) {
            return Center(child: Text(state.message));
          }

          if (state is HistoryLoaded) {
            return AnimationLimiter(
              child: SingleChildScrollView(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildMonthSelector(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusL,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSummaryItem(
                                  'TOTAL PEMASUKAN',
                                  _formatCurrency(state.totalIncome),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              const SizedBox(width: AppDimens.lg),
                              Expanded(
                                child: _buildSummaryItem(
                                  'TOTAL PENGELUARAN',
                                  _formatCurrency(state.totalExpense),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildTransactionList(state.transactions),
                      const SizedBox(height: AppDimens.xl * 2),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
    return Container(
      margin: const EdgeInsets.all(AppDimens.md),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _changeMonth(-1),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            monthStr,
            style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () => _changeMonth(1),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.xl * 2),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/images/img_emty.svg', width: 200),
              const SizedBox(height: AppDimens.lg),
              Text(
                "Data masih kosong",
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Grouping by date
    final Map<String, List<TransactionEntity>> grouped = {};
    for (var t in transactions) {
      final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(t.date);
      if (grouped.containsKey(dateStr)) {
        grouped[dateStr]!.add(t);
      } else {
        grouped[dateStr] = [t];
      }
    }

    final List<Widget> listWidgets = [];
    grouped.forEach((dateStr, trxs) {
      listWidgets.add(_buildSectionHeader(dateStr));
      for (var t in trxs) {
        listWidgets.add(_buildHistoryItem(t));
      }
    });

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: listWidgets,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.md, 12, AppDimens.md, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date.toUpperCase(),
            style: AppStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TransactionEntity t) {
    final isExpense = t.type == 'expense';
    final amountColor = isExpense
        ? const Color(0xFFE57373)
        : const Color(0xFF66BB6A);
    final amountSign = isExpense ? "-" : "+";
    final timeStr = DateFormat('HH:mm', 'id_ID').format(t.date);

    final icon = _categoryIconMap[t.categoryName] ?? Icons.category;
    final iconBgColor = isExpense
        ? const Color(0xFFFFECE0)
        : const Color(0xFFE8F5E9);
    final iconColor = isExpense
        ? const Color(0xFFFF8A00)
        : const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transaction: t),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.md,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
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
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title.isNotEmpty
                        ? t.title
                        : ((t.notes?.isNotEmpty == true)
                              ? t.notes!
                              : (t.categoryName ?? 'Transasksi')),
                    style: AppStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$timeStr • ${t.categoryName}',
                    style: AppStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountSign${_formatCurrency(t.amount)}',
              style: AppStyles.bodyText.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportPreview(BuildContext context) {
    final state = context.read<HistoryBloc>().state;
    if (state is! HistoryLoaded) return;

    final balance = state.totalIncome - state.totalExpense;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pratinjau Laporan',
                style: AppStyles.heading2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 24),

              // Report Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Keuangan',
                              style: AppStyles.bodyText.copyWith(
                                color: const Color(0xFF27AE60),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMMM yyyy',
                                'id_ID',
                              ).format(state.currentMonth).toUpperCase(),
                              style: AppStyles.caption.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'SALDO AKHIR',
                      style: AppStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(balance),
                      style: AppStyles.heading1.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 24),

                    // Bar Chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PEMASUKAN',
                          style: AppStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF27AE60),
                          ),
                        ),
                        Text(
                          'PENGELUARAN',
                          style: AppStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEB5757),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: state.totalIncome > 0
                                ? (state.totalIncome).toInt()
                                : 1,
                            child: Container(
                              height: 12,
                              color: const Color(0xFF27AE60),
                            ),
                          ),
                          Expanded(
                            flex: state.totalExpense > 0
                                ? (state.totalExpense).toInt()
                                : 1,
                            child: Container(
                              height: 12,
                              color: const Color(0xFFEB5757),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCurrency(state.totalIncome),
                          style: AppStyles.caption.copyWith(fontSize: 10),
                        ),
                        Text(
                          _formatCurrency(state.totalExpense),
                          style: AppStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Unduh Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Trigger actual PDF generation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Unduh PDF',
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
