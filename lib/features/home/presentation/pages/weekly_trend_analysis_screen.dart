import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';
import '../bloc/analysis/analysis_bloc.dart';
import '../bloc/analysis/analysis_state.dart';

class WeeklyTrendAnalysisScreen extends StatelessWidget {
  const WeeklyTrendAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      builder: (context, state) {
        if (state is AnalysisLoading || state is AnalysisInitial) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFB),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF8FAFB),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: _buildLoading(),
          );
        } else if (state is AnalysisLoaded) {
          return Scaffold(
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
                'Analisis Tren\nHari ke Hari',
                textAlign: TextAlign.center,
                style: AppStyles.heading2.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF1B5E20),
                  height: 1.2,
                ),
              ),
              centerTitle: true,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM yyyy', 'id').format(state.currentMonth),
                        textAlign: TextAlign.center,
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrendChart(state),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: state.comparisonPercentage > 0
                          ? const Color(0xFFFDEDEC)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.comparisonPercentage > 0
                            ? const Color(0xFFFADBD8)
                            : const Color(0xFFC8E6C9),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: state.comparisonPercentage > 0
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF27AE60),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.comparisonPercentage > 0
                                ? Icons.trending_up
                                : (state.comparisonPercentage < 0
                                      ? Icons.trending_down
                                      : Icons.horizontal_rule),
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
                                'Bulan Ini vs Lalu',
                                style: AppStyles.heading2.copyWith(
                                  color: const Color(0xFF1B5E20),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  style: AppStyles.bodyText.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Pengeluaran Anda '),
                                    TextSpan(
                                      text:
                                          '${state.comparisonPercentage.abs().toStringAsFixed(1)}% ',
                                      style: AppStyles.bodyText.copyWith(
                                        color: state.comparisonPercentage > 0
                                            ? const Color(0xFFE74C3C)
                                            : const Color(0xFF27AE60),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: state.comparisonPercentage > 0
                                          ? 'lebih tinggi'
                                          : 'lebih rendah',
                                      style: AppStyles.bodyText.copyWith(
                                        color: state.comparisonPercentage > 0
                                            ? const Color(0xFFE74C3C)
                                            : const Color(0xFF27AE60),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' dari bulan lalu.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tren Kategori
                  Text(
                    'Tren Kategori (Bulan Ini)',
                    style: AppStyles.heading2.copyWith(
                      color: const Color(0xFF1B5E20),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.topCategories.isEmpty)
                    Center(
                      child: Text(
                        'Belum ada data',
                        style: AppStyles.bodyTextSecondary,
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.topCategories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final cat = state.topCategories[index];

                          IconData icon = Icons.category;
                          final lowerName = cat.categoryName.toLowerCase();
                          if (lowerName.contains('food') ||
                              lowerName.contains('makan'))
                            icon = Icons.restaurant;
                          else if (lowerName.contains('transport'))
                            icon = Icons.directions_car;
                          else if (lowerName.contains('shop') ||
                              lowerName.contains('belanj'))
                            icon = Icons.shopping_bag;
                          else if (lowerName.contains('entert') ||
                              lowerName.contains('hiburan'))
                            icon = Icons.local_activity;

                          // calculate individual chart heights based on weekly totals
                          double maxTotal = 1.0;
                          for (var v in cat.weeklyTotals) {
                            if (v > maxTotal) maxTotal = v;
                          }
                          final List<double> heights = cat.weeklyTotals
                              .map((e) => e / maxTotal)
                              .toList();

                          return _buildCategoryTrendCard(
                            cat.categoryName,
                            icon,
                            AppHelpers.formatCurrencyIdr(cat.totalAmount),
                            heights,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Highlight Pekan Ini -> Insight Hari
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HIGHLIGHT HARI INI',
                          style: AppStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInsightItem(state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('Terjadi kesalahan')));
      },
    );
  }

  Widget _buildInsightItem(AnalysisLoaded state) {
    if (state.currentMonthWeekdayTotals.every((e) => e == 0)) {
      return _buildHighlightItem(
        icon: Icons.info_outline,
        iconColor: Colors.blue,
        iconBgColor: Colors.blue.withOpacity(0.1),
        text: 'Belum ada transaksi di bulan ini.',
      );
    }

    int maxIndex = 0;
    double maxVal = 0;
    for (int i = 0; i < state.currentMonthWeekdayTotals.length; i++) {
      if (state.currentMonthWeekdayTotals[i] > maxVal) {
        maxVal = state.currentMonthWeekdayTotals[i];
        maxIndex = i;
      }
    }

    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final highestDay = days[maxIndex];

    return _buildHighlightItem(
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFF39C12),
      iconBgColor: const Color(0xFFFFF3E0),
      text:
          'Pengeluaran paling besar bulan ini sering terjadi pada hari $highestDay.',
    );
  }

  Widget _buildTrendChart(AnalysisLoaded state) {
    final double maxVal1 = state.currentMonthWeekdayTotals.fold(
      0.0,
      (m, v) => v > m ? v : m,
    );
    final double maxVal2 = state.previousMonthWeekdayTotals.fold(
      0.0,
      (m, v) => v > m ? v : m,
    );
    final double maxVal = maxVal1 > maxVal2 ? maxVal1 : maxVal2;

    final safeMax = maxVal == 0 ? 1.0 : maxVal;

    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final valCurrent = state.currentMonthWeekdayTotals[index];
                final valPrev = state.previousMonthWeekdayTotals[index];
                final ratioCurrent = valCurrent / safeMax;
                final ratioPrev = valPrev / safeMax;

                return _buildBarGroup(days[index], ratioPrev, ratioCurrent);
              }),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendPill('Bulan Lalu', const Color(0xFFC8E6C9)),
              const SizedBox(width: 16),
              _buildLegendPill('Bulan Ini', const Color(0xFF27AE60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarGroup(String day, double heightPrev, double heightCurrent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: 150 * heightPrev,
              decoration: const BoxDecoration(
                color: Color(0xFFC8E6C9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 10,
              height: 150 * heightCurrent,
              decoration: const BoxDecoration(
                color: Color(0xFF27AE60),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: AppStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(250),
          const SizedBox(height: 24),
          _buildShimmerBox(100),
          const SizedBox(height: 32),
          _buildShimmerBox(20),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildShimmerBox(140, width: 140),
              const SizedBox(width: 16),
              _buildShimmerBox(140, width: 140),
            ],
          ),
          const SizedBox(height: 32),
          _buildShimmerBox(150),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double height, {double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLegendPill(String text, Color dotColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTrendCard(
    String title,
    IconData icon,
    String amount,
    List<double> chartHeights,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(icon, color: const Color(0xFF27AE60), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: AppStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          // Small Mini-Chart Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: chartHeights.map((height) {
              return Container(
                width: 16,
                height: 30 * height,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: AppStyles.bodyText.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
