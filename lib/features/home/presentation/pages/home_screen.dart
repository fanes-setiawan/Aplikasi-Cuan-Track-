import 'package:cuan_track/features/analytics/presentation/pages/financial_health_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../notification/presentation/pages/notification_screen.dart';
import '../../../transaction/presentation/pages/add_transaction_screen.dart';
import 'expense_analysis_screen.dart';
import '../../../main/presentation/pages/main_screen.dart';
import '../../../savings/presentation/pages/savings_screen.dart';
import '../../../savings/presentation/bloc/savings_bloc.dart';
import '../../../savings/presentation/bloc/savings_state.dart';
import '../../../debt/presentation/pages/debt_screen.dart';
import '../../../debt/presentation/bloc/debt_bloc.dart';
import '../../../debt/presentation/bloc/debt_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../../../transaction/presentation/pages/transaction_detail_screen.dart';
import '../bloc/home_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/cuan_banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userName = user.displayName ?? user.email?.split('@').first ?? 'User';
      context.read<HomeBloc>().add(StartListeningTransactions(user.uid));
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            double totalBalance = 0;
            double monthlyIncome = 0;
            double monthlyExpenses = 0;
            List recentTrx = [];
            Map<String, double> expenseData = {};
            bool isLoading = state is HomeLoading || state is HomeInitial;

            if (state is HomeLoaded) {
              totalBalance = state.totalBalance;
              monthlyIncome = state.monthlyIncome;
              monthlyExpenses = state.monthlyExpenses;
              recentTrx = state.recentTransactions;
              expenseData = state.expenseChartData;
            }

            if (isLoading) {
              return _buildHomeShimmer();
            }

            return AnimationLimiter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 375),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppDimens.lg),
                      _buildBalanceCard(
                        totalBalance,
                        monthlyIncome,
                        monthlyExpenses,
                        showTrend: recentTrx.isNotEmpty,
                      ),
                      const SizedBox(height: AppDimens.lg),
                      _buildActionButtons(context),
                      const SizedBox(height: AppDimens.lg),
                      _buildFinancialHealthCard(
                        context,
                        monthlyIncome,
                        monthlyExpenses,
                      ),
                      const SizedBox(height: AppDimens.lg),

                      if (expenseData.isNotEmpty) ...[
                        _buildExpenseAnalysis(expenseData),
                        const SizedBox(height: AppDimens.lg),
                      ],

                      _buildSummaryCards(
                        context,
                        isDataEmpty: recentTrx.isEmpty,
                      ),
                      const SizedBox(height: AppDimens.lg),

                      if (recentTrx.isEmpty)
                        EmptyState(
                          title: 'Belum ada transaksi',
                          subtitle:
                              'Mulai catat transaksi pertamamu untuk melihat ringkasan keuanganmu di sini!',
                          imageWidth: 140,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimens.md,
                          ),
                          onAction: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddTransactionScreen(),
                              ),
                            );
                          },
                          actionLabel: 'Tambah Transaksi',
                        )
                      else
                        _buildRecentTransactions(context, recentTrx),
                      const CuanBannerAdWidget(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.md),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppShimmer.circular(radius: 24),
                const SizedBox(width: AppDimens.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer.rectangular(width: 80, height: 12),
                    const SizedBox(height: 4),
                    AppShimmer.rectangular(width: 120, height: 18),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            AppShimmer.rectangular(
              height: 180,
              borderRadius: AppDimens.radiusL,
            ),
            const SizedBox(height: AppDimens.lg),
            Row(
              children: [
                Expanded(
                  child: AppShimmer.rectangular(
                    height: 55,
                    borderRadius: AppDimens.radiusM,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: AppShimmer.rectangular(
                    height: 55,
                    borderRadius: AppDimens.radiusM,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),
            AppShimmer.rectangular(width: 150, height: 24),
            const SizedBox(height: AppDimens.md),
            AppShimmer.rectangular(
              height: 150,
              borderRadius: AppDimens.radiusL,
            ),
            const SizedBox(height: AppDimens.xl),
            Row(
              children: [
                Expanded(
                  child: AppShimmer.rectangular(
                    height: 120,
                    borderRadius: AppDimens.radiusL,
                  ),
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: AppShimmer.rectangular(
                    height: 120,
                    borderRadius: AppDimens.radiusL,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.xl),
            AppShimmer.rectangular(width: 150, height: 24),
            const SizedBox(height: AppDimens.md),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: AppShimmer.rectangular(
                  height: 70,
                  borderRadius: AppDimens.radiusM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.orange.withOpacity(0.2),
          child: const Icon(Icons.receipt_long, color: Colors.orange),
        ),
        const SizedBox(width: AppDimens.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: AppStyles.bodyTextSecondary.copyWith(fontSize: 12),
            ),
            Text(
              'Halo, $_userName!',
              style: AppStyles.heading2.copyWith(fontSize: 18),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    double totalBalance,
    double income,
    double expense, {
    bool showTrend = true,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL SALDO',
                        style: AppStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (showTrend)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(
                              AppDimens.round,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+ 2.5%',
                                style: AppStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatCurrency(totalBalance),
                        style: AppStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBalanceStat(
                            'PEMASUKAN',
                            _formatCurrency(income),
                            const Color(0xFFA7FFEB),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.white.withOpacity(0.3),
                          thickness: 1,
                          width: 32,
                          indent: 4,
                          endIndent: 4,
                        ),
                        Expanded(
                          child: _buildBalanceStat(
                            'PENGELUARAN',
                            _formatCurrency(expense),
                            const Color(0xFFFFE0B2),
                          ),
                        ),
                      ],
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

  Widget _buildBalanceStat(String label, String value, Color bulletColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            child: _buildActionButton(
              'Tambah',
              Icons.add_circle_outline,
              AppColors.primary.withOpacity(0.2),
              AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AddTransactionScreen(isIncome: false),
                ),
              );
            },
            child: _buildActionButton(
              'Catat',
              Icons.receipt_long,
              Colors.white,
              AppColors.primary,
              isOutlined: true,
              borderColor: AppColors.primary.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color bgColor,
    Color textColor, {
    bool isOutlined = false,
    Color? borderColor,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: isOutlined
            ? Border.all(
                color: borderColor ?? AppColors.primary.withOpacity(0.2),
                width: 1.5,
              )
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.bodyText.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, {bool isDataEmpty = false}) {
    return Row(
      children: [
        Expanded(
          child: _buildSavingsSummaryCard(context, showTrend: !isDataEmpty),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(child: _buildDebtSummaryCard(context)),
      ],
    );
  }

  Widget _buildSavingsSummaryCard(
    BuildContext context, {
    bool showTrend = true,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SavingsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: const Icon(
                Icons.savings,
                color: Color(0xFF00838F),
                size: 24,
              ),
            ),
            const SizedBox(height: AppDimens.md),
            Text(
              'TABUNGAN',
              style: AppStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<SavingsBloc, SavingsState>(
              builder: (context, state) {
                double totalSavings = 0;
                if (state is SavingsLoaded) {
                  totalSavings = state.goals.fold(
                    0.0,
                    (sum, goal) => sum + goal.currentAmount,
                  );
                }
                return Text(
                  _formatCurrencyCompact(totalSavings),
                  style: AppStyles.heading3.copyWith(
                    color: const Color(0xFF1B5E20),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimens.sm),
            if (showTrend)
              Row(
                children: [
                  const Icon(
                    Icons.keyboard_double_arrow_up,
                    color: Color(0xFF1B5E20),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+12% bln ini',
                    style: AppStyles.caption.copyWith(
                      color: const Color(0xFF1B5E20),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtSummaryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DebtScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(AppDimens.radiusS),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Color(0xFFE65100),
                size: 24,
              ),
            ),
            const SizedBox(height: AppDimens.md),
            Text(
              'HUTANG/PIUTANG',
              style: AppStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<DebtBloc, DebtState>(
              builder: (context, state) {
                double totalHutang = 0;
                double totalPiutang = 0;
                if (state is DebtLoaded) {
                  for (var debt in state.debts) {
                    final remaining = debt.amount - debt.paidAmount;
                    if (remaining > 0) {
                      if (debt.type == 'hutang') {
                        totalHutang += remaining;
                      } else if (debt.type == 'piutang') {
                        totalPiutang += remaining;
                      }
                    }
                  }
                }
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hutang:',
                          style: AppStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                        Text(
                          _formatCurrencyCompact(totalHutang),
                          style: AppStyles.caption.copyWith(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Piutang:',
                          style: AppStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                        Text(
                          _formatCurrencyCompact(totalPiutang),
                          style: AppStyles.caption.copyWith(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrencyCompact(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      if (amount % 1000000 == 0) {
        return 'Rp ${(amount / 1000000).toStringAsFixed(0)}jt';
      }
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  Widget _buildExpenseAnalysis(Map<String, double> expenseData) {
    if (expenseData.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalExpense = expenseData.values.fold(0.0, (sum, val) => sum + val);

    final sortedEntries = expenseData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, double>> displayEntries = [];
    if (sortedEntries.length > 5) {
      displayEntries = sortedEntries.sublist(0, 4);
      double othersSum = 0;
      for (int i = 4; i < sortedEntries.length; i++) {
        othersSum += sortedEntries[i].value;
      }
      displayEntries.add(MapEntry('Lainnya', othersSum));
    } else {
      displayEntries = sortedEntries;
    }

    final List<Color> chartColors = [
      const Color(0xFF1B5E20),
      const Color(0xFF2ECC71),
      const Color(0xFFA5D6A7),
      const Color(0xFF81C784),
      const Color(0xFFC8E6C9),
    ];

    List<double> ratios = [];
    List<Color> itemColors = [];
    List<Widget> legendItems = [];

    int colorIndex = 0;
    for (var entry in displayEntries) {
      final percentage = entry.value / totalExpense;
      final percentStr = '${(percentage * 100).toStringAsFixed(0)}%';
      final color = chartColors[colorIndex % chartColors.length];

      ratios.add(percentage);
      itemColors.add(color);
      legendItems.add(_buildLegendItem(entry.key, percentStr, color));

      colorIndex++;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Analisis Pengeluaran',
              style: AppStyles.heading2.copyWith(
                fontSize: 18,
                color: const Color(0xFF1B5E20),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExpenseAnalysisScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Lihat',
                style: AppStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        Container(
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              _buildDonutChart(ratios, itemColors),
              const SizedBox(width: AppDimens.xl),
              Expanded(child: Column(children: legendItems)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart(List<double> ratios, List<Color> colors) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(120, 120),
            painter: DonutChartPainter(ratios: ratios, colors: colors),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOTAL', style: AppStyles.caption.copyWith(fontSize: 10)),
                Text('100%', style: AppStyles.heading2.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percent, Color color) {
    IconData iconData = Icons.shopping_bag;
    if (label.toLowerCase().contains("makan") ||
        label.toLowerCase().contains("food")) {
      iconData = Icons.restaurant;
    } else if (label.toLowerCase().contains("transport")) {
      iconData = Icons.directions_car;
    } else if (label.toLowerCase().contains("belanja") ||
        label.toLowerCase().contains("shopping")) {
      iconData = Icons.shopping_bag;
    } else if (label.toLowerCase().contains("tagihan")) {
      iconData = Icons.receipt;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppStyles.bodyTextSecondary,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            percent,
            style: AppStyles.bodyText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List transactions) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transaksi Terakhir', style: AppStyles.heading2),
            GestureDetector(
              onTap: () {
                MainScreen.switchTab(1);
              },
              child: Text(
                'Lihat Semua',
                style: AppStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        if (transactions.isEmpty)
          const SizedBox.shrink()
        else
          ...transactions.asMap().entries.map((entry) {
            final idx = entry.key;
            final trx = entry.value;
            final isIncome = trx.type == 'income';
            final amountStr = _formatCurrency(trx.amount);
            final finalAmountStr = isIncome ? '+$amountStr' : '-$amountStr';
            final bgColor = isIncome ? Colors.green[100]! : Colors.orange[100]!;
            final iconColor = isIncome
                ? Colors.green[900]!
                : Colors.orange[900]!;
            final icon = isIncome
                ? Icons.account_balance_wallet
                : Icons.shopping_bag;

            final dateStr = DateFormat('dd MMM yyyy • HH:mm').format(trx.date);

            return AnimationConfiguration.staggeredList(
              position: idx,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TransactionDetailScreen(transaction: trx),
                        ),
                      );
                    },
                    child: _buildTransactionItem(
                      trx.title.isNotEmpty
                          ? trx.title
                          : (trx.notes?.isNotEmpty == true
                                ? trx.notes!
                                : (trx.categoryName ?? 'Transaksi')),
                      '$dateStr • ${trx.categoryName?.toUpperCase() ?? 'LAINNYA'}',
                      finalAmountStr,
                      bgColor,
                      iconColor,
                      icon,
                      isIncome,
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String amount,
    Color bgColor,
    Color iconColor,
    IconData icon,
    bool isIncome,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.sm + 2),
            decoration: BoxDecoration(
              color: bgColor,
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
                  title,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Text(
            amount,
            style: AppStyles.bodyText.copyWith(
              color: isIncome ? Colors.green[600] : Colors.red[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthCard(
    BuildContext context,
    double monthlyIncome,
    double monthlyExpenses,
  ) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, savingsState) {
        return BlocBuilder<DebtBloc, DebtState>(
          builder: (context, debtState) {
            double savings = 0;
            double debt = 0;

            if (savingsState is SavingsLoaded) {
              savings = savingsState.goals.fold(
                0.0,
                (sum, goal) => sum + goal.currentAmount,
              );
            }

            if (debtState is DebtLoaded) {
              for (var d in debtState.debts) {
                final remaining = d.amount - d.paidAmount;
                if (remaining > 0 && d.type == 'hutang') {
                  debt += remaining;
                }
              }
            }

            // Hitung Rasio
            double denomIncome = monthlyIncome <= 0 ? 1.0 : monthlyIncome;
            double savingRatio = savings / denomIncome;
            double debtRatio = debt / denomIncome;
            double emergencyFundRatio = monthlyExpenses > 0
                ? (savings / monthlyExpenses)
                : 0;

            // Hitung Skor
            double savingScore = savingRatio >= 0.20
                ? 100
                : (savingRatio / 0.20) * 100;
            double debtScore = debtRatio <= 0.35
                ? 100
                : (debtRatio >= 1.0
                      ? 0
                      : (1.0 - (debtRatio - 0.35) / 0.65) * 100);
            double emergencyScore = emergencyFundRatio >= 3.0
                ? 100
                : (emergencyFundRatio / 3.0) * 100;

            double score = (savingScore + debtScore + emergencyScore) / 3;
            if (score < 0) score = 0;
            if (score > 100) score = 100;

            String status = 'Bahaya';
            Color statusColor = const Color(0xFFE53935);
            if (score > 70) {
              status = 'Sehat';
              statusColor = const Color(0xFF4CAF50);
            } else if (score > 35) {
              status = 'Cukup Sehat';
              statusColor = Colors.orange[800]!;
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinancialHealthScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFF1B5E20),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KESEHATAN KEUANGAN',
                            style: AppStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Skor: ${score.toStringAsFixed(0)}/100',
                                style: AppStyles.bodyText.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '($status)',
                                style: AppStyles.caption.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> ratios;
  final List<Color> colors;

  DonutChartPainter({required this.ratios, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 25;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    double startAngle = -1.5708;

    for (int i = 0; i < ratios.length; i++) {
      final double sweepAngle = ratios[i] * 2 * 3.14159;
      final Paint paint = Paint()
        ..color = colors[i]
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
