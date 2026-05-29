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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
              return AnimationLimiter(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
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
                          Builder(
                            builder: (context) {
                              final categories = state.topCategories;
                              List<Widget> pills = [];
                              final colors = [
                                const Color(0xFF27AE60),
                                const Color(0xFF2ECC71),
                                const Color(0xFFF1C40F),
                                const Color(0xFFE67E22),
                                const Color(0xFFE74C3C),
                              ];

                              if (categories.length > 5) {
                                for (int i = 0; i < 4; i++) {
                                  final cat = categories[i];
                                  pills.add(
                                    _buildLegendPill(
                                      '${cat.categoryName}: ${cat.percentage.toStringAsFixed(0)}%',
                                      colors[i % colors.length],
                                      i == 0,
                                    ),
                                  );
                                }
                                double othersPercent = 0;
                                for (int i = 4; i < categories.length; i++) {
                                  othersPercent += categories[i].percentage;
                                }
                                pills.add(
                                  _buildLegendPill(
                                    'Lainnya: ${othersPercent.toStringAsFixed(0)}%',
                                    const Color(0xFF95A5A6),
                                    false,
                                  ),
                                );
                              } else {
                                pills = categories.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final cat = entry.value;
                                  return _buildLegendPill(
                                    '${cat.categoryName}: ${cat.percentage.toStringAsFixed(0)}%',
                                    colors[idx % colors.length],
                                    idx == 0,
                                  );
                                }).toList();
                              }

                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: pills,
                              );
                            },
                          ),
                        const SizedBox(height: 48),

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
                                          child:
                                              const ComparativeAnalysisScreen(),
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
                                          child:
                                              const WeeklyTrendAnalysisScreen(),
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
                                icon: state.comparisonPercentage > 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                iconColor: state.comparisonPercentage > 0
                                    ? const Color(0xFFE74C3C)
                                    : const Color(0xFF27AE60),
                                bgColor: state.comparisonPercentage > 0
                                    ? const Color(0xFFFDEDEC)
                                    : const Color(0xFFE8F5E9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

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
                                          TextSpan(
                                            text: '${state.insightText} ',
                                          ),
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
                              children: state.topSubCategories
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final subcat = entry.value;
                                    final isLast =
                                        index ==
                                        state.topSubCategories.length - 1;
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
                                  })
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 120,
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
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                    widthFactor: progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${progress.toStringAsFixed(0)}%",
                style: AppStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
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
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('makan') || name.contains('kuliner'))
      return Icons.restaurant;
    if (name.contains('transport')) return Icons.directions_car;
    if (name.contains('belanja')) return Icons.shopping_bag;
    if (name.contains('sekolah') || name.contains('pendidikan'))
      return Icons.school;
    if (name.contains('kesehatan')) return Icons.medical_services;
    if (name.contains('hiburan')) return Icons.sports_esports;
    if (name.contains('tagihan')) return Icons.receipt;
    return Icons.category;
  }
}
