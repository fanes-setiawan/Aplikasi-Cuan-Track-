import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';
import 'weekly_trend_analysis_screen.dart';
import 'comparative_analysis_screen.dart';
import '../../../../core/widgets/cuan_banner_ad_widget.dart';

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
                padding: EdgeInsets.all(AppSizes.padding8),
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
              fontSize: AppSizes.font18,
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
                padding: EdgeInsets.all(AppSizes.padding8),
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
                  padding: EdgeInsets.all(AppSizes.padding24),
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
                                  SizedBox(height: AppSizes.paddingV4),
                                  Text(
                                    AppHelpers.formatCurrencyIdr(
                                      state.currentMonthTotal,
                                    ),
                                    style: AppStyles.heading1.copyWith(
                                      fontSize: AppSizes.font24,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                  ),
                                  SizedBox(height: AppSizes.paddingV4),
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
                        SizedBox(height: AppSizes.paddingV32),

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
                                fontSize: AppSizes.font18,
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
                        SizedBox(height: AppSizes.paddingV16),
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
                            SizedBox(width: AppSizes.padding16),
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
                        SizedBox(height: AppSizes.paddingV16),
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
                          padding: EdgeInsets.all(AppSizes.padding20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSizes.padding8),
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
                              SizedBox(width: AppSizes.padding16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Insight Keuangan',
                                      style: AppStyles.heading2.copyWith(
                                        color: const Color(0xFF1B5E20),
                                        fontSize: AppSizes.font14,
                                      ),
                                    ),
                                    SizedBox(height: AppSizes.paddingV8),
                                    RichText(
                                      text: TextSpan(
                                        style: AppStyles.bodyText.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: AppSizes.font12,
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
                                              fontSize: AppSizes.font12,
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
                              fontSize: AppSizes.font16,
                            ),
                          ),
                          SizedBox(height: AppSizes.paddingV16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radius24),
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
                        const CuanBannerAdWidget(),
                        const SizedBox(height: 48),
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
      padding: EdgeInsets.all(AppSizes.padding24),
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
          SizedBox(height: AppSizes.paddingV32),
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
          SizedBox(height: AppSizes.paddingV16),
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
              SizedBox(width: AppSizes.padding16),
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
      padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16, vertical: AppSizes.paddingV8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.padding8,
            height: AppSizes.paddingV8,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSizes.padding8),
          Text(
            text,
            style: AppStyles.bodyText.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF1B5E20),
              fontSize: AppSizes.font12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryItem(String title, String amount, double progress) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.padding20),
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
              Text(amount, style: AppStyles.heading2.copyWith(fontSize: AppSizes.font14)),
            ],
          ),
          SizedBox(height: AppSizes.paddingV12),
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
              SizedBox(width: AppSizes.padding12),
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
      padding: EdgeInsets.all(AppSizes.padding16),
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
          SizedBox(height: AppSizes.paddingV12),
          Text(
            amount,
            style: AppStyles.heading2.copyWith(
              fontSize: AppSizes.font14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
