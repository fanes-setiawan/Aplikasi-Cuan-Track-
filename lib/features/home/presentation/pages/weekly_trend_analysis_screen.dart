import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
                'Analisis Tren\nMingguan',
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
                        style: AppStyles.bodyText.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: AnimationLimiter(
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rata-rata Mingguan',
                                      style: AppStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      AppHelpers.formatCurrencyIdr(
                                        state.currentMonthTotal / 4,
                                      ),
                                      style: AppStyles.heading2.copyWith(
                                        color: const Color(0xFF1B5E20),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.trending_up,
                                        size: 14,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '12%',
                                        style: AppStyles.caption.copyWith(
                                          color: const Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              height: 180,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: state.currentMonthWeeklyTotals
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final idx = entry.key;
                                      final val = entry.value;
                                      final maxVal = state
                                          .currentMonthWeeklyTotals
                                          .reduce((a, b) => a > b ? a : b);
                                      final height = maxVal > 0
                                          ? (val / maxVal) * 150
                                          : 0.0;
                                      final isHighest =
                                          idx == state.highestSpendingWeekIndex;

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: height.toDouble(),
                                            decoration: BoxDecoration(
                                              color: isHighest
                                                  ? const Color(0xFF27AE60)
                                                  : const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'W${idx + 1}',
                                            style: AppStyles.caption.copyWith(
                                              fontWeight: isHighest
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isHighest
                                                  ? const Color(0xFF1B5E20)
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTrendStatCard(
                              'Minggu Tertinggi',
                              'Minggu ${state.highestSpendingWeekIndex + 1}',
                              AppHelpers.formatCurrencyIdr(
                                state.highestSpendingWeekAmount,
                              ),
                              const Color(0xFFE74C3C),
                              const Color(0xFFFDEDEC),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTrendStatCard(
                              'Minggu Terendah',
                              'Minggu ${state.lowestSpendingWeekIndex + 1}',
                              AppHelpers.formatCurrencyIdr(
                                state.lowestSpendingWeekAmount,
                              ),
                              const Color(0xFF27AE60),
                              const Color(0xFFE8F5E9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Text(
                        'Rincian Mingguan',
                        style: AppStyles.heading2.copyWith(
                          color: const Color(0xFF1B5E20),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...state.currentMonthWeeklyTotals.asMap().entries.map((
                        entry,
                      ) {
                        final idx = entry.key;
                        final amount = entry.value;
                        return _buildWeeklyListItem(
                          'Minggu ${idx + 1}',
                          '${idx * 7 + 1} - ${idx == 3 ? 31 : (idx + 1) * 7} ${DateFormat('MMM', 'id').format(state.currentMonth)}',
                          AppHelpers.formatCurrencyIdr(amount),
                          idx == state.highestSpendingWeekIndex,
                        );
                      }).toList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('Terjadi kesalahan')));
      },
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

  Widget _buildTrendStatCard(
    String label,
    String value,
    String amount,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.heading2.copyWith(color: color, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: AppStyles.bodyText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyListItem(
    String title,
    String dateRange,
    String amount,
    bool isHighest,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighest ? const Color(0xFF27AE60) : AppColors.divider,
          width: isHighest ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isHighest
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF8FAFB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_view_week,
              color: isHighest
                  ? const Color(0xFF1B5E20)
                  : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.heading2.copyWith(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  dateRange,
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
                style: AppStyles.heading2.copyWith(
                  fontSize: 14,
                  color: isHighest
                      ? const Color(0xFF1B5E20)
                      : AppColors.textPrimary,
                ),
              ),
              if (isHighest)
                Text(
                  'Tertinggi',
                  style: AppStyles.caption.copyWith(
                    color: const Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
