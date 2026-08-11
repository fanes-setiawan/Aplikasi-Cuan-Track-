// ignore_for_file: use_build_context_synchronously

import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:cuan_track/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_styles.dart';
import 'package:cuan_track/features/onboarding/presentation/widgets/animations/scene_1_receipt_anim.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../../../core/utils/pdf_report_generator.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';

import '../../../transaction/presentation/pages/transaction_detail_screen.dart';
import 'all_time_report_screen.dart';

class HistoryScreen extends StatefulWidget {
  final bool showBackButton;
  const HistoryScreen({super.key, this.showBackButton = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  String _userId = '';
  String _selectedCategoryFilter = 'Semua';

  final Map<String, IconData> _categoryIconMap = {
    "Gaji": Icons.payments_outlined,
    "Bonus": Icons.stars_outlined,
    "Investasi": Icons.show_chart_outlined,
    "Makanan & Minuman": Icons.restaurant,
    "Makan": Icons.restaurant,
    "Transportasi": Icons.directions_car,
    "Transport": Icons.directions_car,
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
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        centerTitle: true,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Riwayat Transaksi',
          style: AppStyles.heading2.copyWith(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllTimeReportScreen(),
                ),
              ).then((_) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  context.read<HistoryBloc>().add(
                    ChangeMonthEvent(user.uid, _selectedDate),
                  );
                }
              });
            },
            child: SvgPicture.asset(
              AppAssets.iconDocument,
              width: AppSizes.padding24,
              height: AppSizes.paddingV24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF34D399),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          GestureDetector(
            onTap: () => _showReportPreview(context),
            child: SvgPicture.asset(
              AppAssets.iconDownload,
              width: AppSizes.padding24,
              height: AppSizes.paddingV24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF34D399),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryInitial || state is HistoryLoading) {
            return _buildHistoryShimmer();
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
                      _buildCategoryFilters(state.transactions),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
                          vertical: AppDimens.md,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.lg),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF10B981), Color(0xFF2DD4BF)],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusL,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
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
                                color: Colors.white.withValues(alpha: 0.2),
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
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.paddingV12,
        horizontal: AppSizes.padding16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
            child: const Icon(Icons.chevron_left, color: Color(0xFF94A3B8)),
          ),
          Text(
            monthStr,
            style: AppStyles.bodyText.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => _changeMonth(1),
            child: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(List<TransactionEntity> transactions) {
    final categories = <String>{};
    for (var t in transactions) {
      if (t.categoryName?.isNotEmpty == true) {
        categories.add(t.categoryName!);
      }
    }

    final categoryList = ['Semua', ...categories.toList()..sort()];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        scrollDirection: Axis.horizontal,
        itemCount: categoryList.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: AppSizes.padding8),
        itemBuilder: (context, index) {
          final category = categoryList[index];
          final isSelected = category == _selectedCategoryFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryFilter = category;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.padding16,
                vertical: AppSizes.paddingV8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1E293B),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (category == 'Semua')
                    Icon(
                      Icons.grid_view,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    )
                  else if (_categoryIconMap.containsKey(category))
                    Icon(
                      _categoryIconMap[category],
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    ),
                  if (category == 'Semua' ||
                      _categoryIconMap.containsKey(category))
                    const SizedBox(width: 6),
                  Text(
                    category,
                    style: AppStyles.bodyText.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: AppSizes.font14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.paddingV4),
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
    final displayedTransactions = _selectedCategoryFilter == 'Semua'
        ? transactions
        : transactions
              .where((t) => t.categoryName == _selectedCategoryFilter)
              .toList();

    if (transactions.isEmpty || displayedTransactions.isEmpty) {
      return const EmptyState(
        title: 'Data Masih Kosong',
        subtitle: 'Belum ada transaksi di bulan ini atau untuk kategori ini.',
        customAnimation: Scene1ReceiptAnim(),
      );
    }

    final Map<String, List<TransactionEntity>> grouped = {};
    for (var t in displayedTransactions) {
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
              color: const Color(0xFF94A3B8),
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
        ? const Color(0xFFF87171)
        : const Color(0xFF34D399);
    final amountSign = isExpense ? "-" : "+";
    final timeStr = DateFormat('HH:mm', 'id_ID').format(t.date);

    final icon = _categoryIconMap[t.categoryName] ?? Icons.category;
    final iconBgColor = isExpense
        ? const Color(0xFF450A0A)
        : const Color(0xFF022C22);
    final iconColor = isExpense
        ? const Color(0xFFF87171)
        : const Color(0xFF34D399);

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
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.padding12),
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV4),
                  Text(
                    '$timeStr • ${t.categoryName}',
                    style: AppStyles.caption.copyWith(
                      fontSize: AppSizes.font10,
                      color: const Color(0xFF94A3B8),
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
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radius32),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSizes.paddingV12),
              Container(
                width: 40,
                height: AppSizes.paddingV4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSizes.paddingV24),
              Text(
                'Pratinjau Laporan',
                style: AppStyles.heading2.copyWith(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: AppSizes.paddingV24),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.padding20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(AppSizes.radius24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF1E293B)),
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
                                color: const Color(0xFF34D399),
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
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.paddingV32),
                    Text(
                      'SALDO AKHIR',
                      style: AppStyles.caption.copyWith(
                        fontSize: AppSizes.font10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV4),
                    Text(
                      _formatCurrency(balance),
                      style: AppStyles.heading1.copyWith(
                        fontSize: AppSizes.font32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PEMASUKAN',
                          style: AppStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF34D399),
                          ),
                        ),
                        Text(
                          'PENGELUARAN',
                          style: AppStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF87171),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.paddingV8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radius8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: state.totalIncome > 0
                                ? (state.totalIncome).toInt()
                                : 1,
                            child: Container(
                              height: AppSizes.paddingV12,
                              color: const Color(0xFF34D399),
                            ),
                          ),
                          Expanded(
                            flex: state.totalExpense > 0
                                ? (state.totalExpense).toInt()
                                : 1,
                            child: Container(
                              height: AppSizes.paddingV12,
                              color: const Color(0xFFF87171),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCurrency(state.totalIncome),
                          style: AppStyles.caption.copyWith(
                            fontSize: AppSizes.font10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          _formatCurrency(state.totalExpense),
                          style: AppStyles.caption.copyWith(
                            fontSize: AppSizes.font10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.paddingV32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    PdfReportGenerator.generateAndDownloadReport(state);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius16),
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
                      SizedBox(width: AppSizes.padding12),
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
              SizedBox(height: AppSizes.paddingV32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryShimmer() {
    return SingleChildScrollView(
      child: AppShimmer(
        child: Column(
          children: [
            _buildMonthSelector(),
            SizedBox(height: AppSizes.paddingV8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    SizedBox(width: AppSizes.padding8),
                itemBuilder: (context, index) => AppShimmer.rectangular(
                  width: 80,
                  height: AppSizes.paddingV32,
                  borderRadius: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.md),
              child: AppShimmer.rectangular(
                height: 80,
                borderRadius: AppDimens.radiusL,
              ),
            ),
            ...List.generate(
              5,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppDimens.md, 12, 0, 8),
                    child: AppShimmer.rectangular(width: 100, height: 14),
                  ),
                  ...List.generate(
                    2,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md,
                        vertical: 6,
                      ),
                      child: AppShimmer.rectangular(
                        height: 70,
                        borderRadius: AppDimens.radiusM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
