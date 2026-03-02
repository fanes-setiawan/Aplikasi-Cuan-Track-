import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';
import 'weekly_trend_analysis_screen.dart';
import 'comparative_analysis_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/analysis/analysis_bloc.dart';
import '../bloc/analysis/analysis_event.dart';
import '../bloc/analysis/analysis_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class ExpenseAnalysisScreen extends StatefulWidget {
  const ExpenseAnalysisScreen({super.key});

  @override
  State<ExpenseAnalysisScreen> createState() => _ExpenseAnalysisScreenState();
}

class _ExpenseAnalysisScreenState extends State<ExpenseAnalysisScreen> {
  DateTime _selectedMonth = DateTime.now();
  late AnalysisBloc _analysisBloc;

  @override
  void initState() {
    super.initState();
    _analysisBloc = di.sl<AnalysisBloc>();
    _fetchData();
  }

  void _fetchData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _analysisBloc.add(FetchAnalysisData(user.uid, _selectedMonth));
    }
  }

  @override
  void dispose() {
    _analysisBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _analysisBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFB),
          elevation: 0,
          leadingWidth: 80,
          leading: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          title: Text(
            'Analisis Pengeluaran',
            style: AppStyles.heading2.copyWith(
              fontSize: 18,
              color: const Color(0xFF1B5E20),
            ),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _selectedMonth,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selected != null) {
                  setState(() {
                    _selectedMonth = selected;
                  });
                  _fetchData();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.divider, width: 1.5),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AnalysisBloc, AnalysisState>(
          builder: (context, state) {
            if (state is AnalysisLoading) {
              return _buildLoading();
            } else if (state is AnalysisError) {
              return Center(child: Text(state.message));
            } else if (state is AnalysisLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Donut Chart Mockup Placeholder
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1B5E20),
                            width: 30,
                          ),
                          // Mockup colors for different segments can be built properly later,
                          // for now, simulating the donut chart outer ring
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TOTAL PENGELUARAN',
                                style: AppStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppHelpers.formatCurrencyIdr(
                                  state.currentMonthTotal,
                                ),
                                style: AppStyles.heading1.copyWith(
                                  fontSize: 24,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'MMMM yyyy',
                                  'id_ID',
                                ).format(state.currentMonth),
                                style: AppStyles.caption.copyWith(
                                  color: const Color(0xFF27AE60),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (state.topCategories.isNotEmpty)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: state.topCategories.asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key;
                          final cat = entry.value;
                          final colors = [
                            const Color(0xFF1B5E20),
                            const Color(0xFF27AE60),
                            const Color(0xFF2ECC71),
                            const Color(0xFFA8E6CF),
                            const Color(0xFFDCEDC1),
                          ];
                          final color = colors[idx % colors.length];
                          return _buildLegendPill(
                            '${cat.categoryName}: ${cat.percentage.toStringAsFixed(0)}%',
                            color,
                            idx == 0,
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 48),

                    // Monthly Trend & Comparative Analysis
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Analisis Tren',
                          style: AppStyles.heading2.copyWith(
                            color: const Color(0xFF1B5E20),
                            fontSize: 18,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: _analysisBloc,
                                      child: const ComparativeAnalysisScreen(),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Banding',
                                style: AppStyles.bodyText.copyWith(
                                  color: const Color(0xFF27AE60),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: _analysisBloc,
                                      child: const WeeklyTrendAnalysisScreen(),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Mingguan',
                                style: AppStyles.bodyText.copyWith(
                                  color: const Color(0xFF27AE60),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnalysisGridCard(
                            title: 'Bulan Ini',
                            amount: AppHelpers.formatCurrencyIdr(
                              state.currentMonthTotal,
                            ),
                            icon: Icons.trending_up,
                            iconColor: const Color(0xFFE74C3C),
                            bgColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnalysisGridCard(
                            title: 'Bulan Lalu',
                            amount: AppHelpers.formatCurrencyIdr(
                              state.previousMonthTotal,
                            ),
                            icon: Icons.analytics_outlined,
                            iconColor: const Color(0xFF27AE60),
                            bgColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnalysisGridCard(
                            title: 'Perbandingan',
                            amount:
                                '${state.comparisonPercentage > 0 ? '+' : ''}${state.comparisonPercentage.toStringAsFixed(1)}%',
                            subtitle: state.comparisonPercentage > 0
                                ? 'Lebih boros'
                                : state.comparisonPercentage < 0
                                ? 'Lebih hemat'
                                : 'Sama',
                            icon: Icons.compare_arrows,
                            iconColor: const Color(0xFFF39C12),
                            bgColor: const Color(0xFFFFF3E0),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnalysisGridCard(
                            title: 'Rata-rata/Hari',
                            amount: AppHelpers.formatCurrencyIdr(
                              state.averagePerDay,
                            ),
                            subtitle: 'Bulan ini',
                            icon: Icons.today,
                            iconColor: const Color(0xFF3498DB),
                            bgColor: const Color(0xFFE3F2FD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Category Analysis Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Analisis Kategori',
                          style: AppStyles.heading2.copyWith(
                            color: const Color(0xFF1B5E20),
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Filter',
                          style: AppStyles.bodyText.copyWith(
                            color: const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Cards
                    if (state.topCategories.isEmpty)
                      const Center(
                        child: Text("Belum ada kategori pengeluaran."),
                      )
                    else
                      ...state.topCategories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCategoryCard(
                            icon: Icons
                                .category, // You could map specific icons if needed
                            title: category.categoryName,
                            amount: AppHelpers.formatCurrencyIdr(
                              category.totalAmount,
                            ),
                            percentage: category.trendText,
                            trend:
                                '', // Not enough historical data per category, keep it simple
                            isTrendingUp: category.isTrendingUp,
                            isNeutral: category.isNeutral,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Insight Box
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B5E20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lightbulb,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Insight Keuangan',
                                  style: AppStyles.heading2.copyWith(
                                    color: const Color(0xFF1B5E20),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: AppStyles.bodyText.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(text: '${state.insightText} '),
                                      TextSpan(
                                        text: state.insightHighlightText,
                                        style: AppStyles.bodyText.copyWith(
                                          color: const Color(0xFF27AE60),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
                    const SizedBox(height: 48),

                    // Detail Sub-Category Section
                    if (state.topSubCategories.isNotEmpty &&
                        state.topCategories.isNotEmpty) ...[
                      Text(
                        'Detail Transaksi (${state.topCategories.first.categoryName})',
                        style: AppStyles.heading2.copyWith(
                          color: const Color(0xFF1B5E20),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: state.topSubCategories.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final subcat = entry.value;
                            final isLast =
                                index == state.topSubCategories.length - 1;
                            return Column(
                              children: [
                                _buildSubCategoryItem(
                                  subcat.name,
                                  AppHelpers.formatCurrencyIdr(
                                    subcat.totalAmount,
                                  ),
                                  subcat.percentage,
                                ),
                                if (!isLast) const Divider(height: 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLegendPill(String text, Color dotColor, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppStyles.bodyText.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF1B5E20),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String amount,
    required String percentage,
    required String trend,
    required bool isTrendingUp,
    bool isNeutral = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF1B5E20), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppStyles.heading2.copyWith(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      amount,
                      style: AppStyles.heading2.copyWith(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  percentage,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isNeutral
                          ? Icons.remove
                          : isTrendingUp
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: isNeutral
                          ? AppColors.textSecondary
                          : isTrendingUp
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF27AE60),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: AppStyles.caption.copyWith(
                        color: isNeutral
                            ? AppColors.textSecondary
                            : isTrendingUp
                            ? const Color(0xFFE74C3C)
                            : const Color(0xFF27AE60),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryItem(String title, String amount, double progress) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(amount, style: AppStyles.heading2.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisGridCard({
    required String title,
    required String amount,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: AppStyles.heading2.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!, width: 30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 24, width: 120, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 24, width: 180, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
