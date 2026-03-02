import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';
import '../bloc/analysis/analysis_bloc.dart';
import '../bloc/analysis/analysis_state.dart';

class ComparativeAnalysisScreen extends StatelessWidget {
  const ComparativeAnalysisScreen({super.key});

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
          final currentMonthStr = DateFormat(
            'MMM\nyyyy',
            'id',
          ).format(state.currentMonth);
          final prevMonth = DateTime(
            state.currentMonth.year,
            state.currentMonth.month - 1,
          );

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
                'Analisis\nPerbandingan',
                textAlign: TextAlign.start,
                style: AppStyles.heading2.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF1B5E20),
                  height: 1.2,
                ),
              ),
              titleSpacing: 0,
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
                        currentMonthStr,
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
                  // Month Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BULAN INI',
                                style: AppStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppHelpers.formatCurrencyIdr(
                                  state.currentMonthTotal,
                                ),
                                style: AppStyles.heading2.copyWith(
                                  color: const Color(0xFF1B5E20),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BULAN LALU',
                                style: AppStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppHelpers.formatCurrencyIdr(
                                  state.previousMonthTotal,
                                ),
                                style: AppStyles.heading2.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildTrendChart(state, prevMonth),

                  const SizedBox(height: 32),

                  // Insight Pengeluaran
                  Text(
                    'Insight Pengeluaran',
                    style: AppStyles.heading2.copyWith(
                      color: const Color(0xFF1B5E20),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInsightItem(
                    icon: state.comparisonPercentage > 0
                        ? Icons.trending_up
                        : (state.comparisonPercentage < 0
                              ? Icons.trending_down
                              : Icons.horizontal_rule),
                    iconColor: state.comparisonPercentage > 0
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFF27AE60),
                    iconBgColor: state.comparisonPercentage > 0
                        ? const Color(0xFFFDEDEC)
                        : const Color(0xFFE8F5E9),
                    bgColor: Colors.white,
                    richText: TextSpan(
                      style: AppStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '${state.insightHighlightText} ',
                          style: AppStyles.bodyText.copyWith(
                            color: state.comparisonPercentage > 0
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(text: state.insightText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Pengeluaran Terbesar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pengeluaran Terbesar',
                        style: AppStyles.heading2.copyWith(
                          color: const Color(0xFF1B5E20),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.topTransactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Belum ada transaksi bulan ini',
                          style: AppStyles.bodyTextSecondary,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: state.topTransactions.asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key;
                          final t = entry.value;
                          final isLast =
                              idx == state.topTransactions.length - 1;
                          final dateStr = DateFormat(
                            'dd MMMM yyyy • HH:mm',
                            'id',
                          ).format(t.date);

                          IconData icon = Icons.receipt_long;
                          if (t.categoryName != null) {
                            final catNameLower = t.categoryName!.toLowerCase();
                            if (catNameLower.contains('food') ||
                                catNameLower.contains('makan'))
                              icon = Icons.restaurant;
                            if (catNameLower.contains('transport'))
                              icon = Icons.directions_car;
                            if (catNameLower.contains('shopping') ||
                                catNameLower.contains('belanja'))
                              icon = Icons.shopping_bag;
                          }

                          return Column(
                            children: [
                              _buildTransactionItem(
                                icon: icon,
                                iconColor: const Color(0xFFE74C3C),
                                iconBgColor: const Color(0xFFFCE4EC),
                                title: t.title.isEmpty
                                    ? 'Pengeluaran'
                                    : t.title,
                                date: dateStr,
                                amount:
                                    '-${AppHelpers.formatCurrencyIdr(t.amount)}',
                              ),
                              if (!isLast) const Divider(height: 1),
                            ],
                          );
                        }).toList(),
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

  Widget _buildTrendChart(AnalysisLoaded state, DateTime prevMonth) {
    final double maxVal1 = state.currentMonthWeeklyTotals.fold(
      0.0,
      (m, v) => v > m ? v : m,
    );
    final double maxVal2 = state.previousMonthWeeklyTotals.fold(
      0.0,
      (m, v) => v > m ? v : m,
    );
    final double maxVal = maxVal1 > maxVal2 ? maxVal1 : maxVal2;

    // To avoid division by zero
    final safeMax = maxVal == 0 ? 1.0 : maxVal;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trend Pengeluaran',
                style: AppStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  _buildLegendPill(
                    DateFormat('MMM', 'id').format(state.currentMonth),
                    const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 8),
                  _buildLegendPill(
                    DateFormat('MMM', 'id').format(prevMonth),
                    const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (index) {
                final valCurrent = state.currentMonthWeeklyTotals[index];
                final valPrev = state.previousMonthWeeklyTotals[index];
                final ratioCurrent = valCurrent / safeMax;
                final ratioPrev = valPrev / safeMax;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 150 * ratioCurrent,
                            decoration: BoxDecoration(
                              color: const Color(0xFF27AE60),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 12,
                            height: 150 * ratioPrev,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'M ${index + 1}',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
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
          Row(
            children: [
              Expanded(child: _buildShimmerBox(100)),
              const SizedBox(width: 16),
              Expanded(child: _buildShimmerBox(100)),
            ],
          ),
          const SizedBox(height: 32),
          _buildShimmerBox(200),
          const SizedBox(height: 32),
          _buildShimmerBox(150),
          const SizedBox(height: 32),
          _buildShimmerBox(250),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
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
        const SizedBox(width: 4),
        Text(
          text,
          style: AppStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color bgColor,
    Color? borderColor,
    required InlineSpan richText,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: RichText(text: richText)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String date,
    required String amount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: AppStyles.heading2.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
