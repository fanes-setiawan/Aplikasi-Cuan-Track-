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
import '../../../transaction/presentation/pages/transaction_detail_screen.dart';

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
            'MMM yyyy',
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
                        currentMonthStr,
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
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.divider),
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
                                      fontSize: 16,
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
                                borderRadius: BorderRadius.circular(20),
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
                                      fontSize: 16,
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

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: state.comparisonPercentage > 0
                              ? const Color(0xFFFDEDEC)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: state.comparisonPercentage > 0
                                    ? const Color(0xFFE74C3C)
                                    : const Color(0xFF27AE60),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.comparisonPercentage > 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Insight Perbandingan',
                                    style: AppStyles.heading2.copyWith(
                                      color: const Color(0xFF1B5E20),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      style: AppStyles.bodyText.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${state.comparisonPercentage.abs().toStringAsFixed(1)}% ',
                                          style: AppStyles.bodyText.copyWith(
                                            color:
                                                state.comparisonPercentage > 0
                                                ? const Color(0xFFE74C3C)
                                                : const Color(0xFF27AE60),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: state.comparisonPercentage > 0
                                              ? 'lebih tinggi dibandingkan bulan lalu.'
                                              : 'lebih hemat dibandingkan bulan lalu.',
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

                      Text(
                        'Transaksi Terbesar',
                        style: AppStyles.heading2.copyWith(
                          color: const Color(0xFF1B5E20),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.topTransactions.isEmpty)
                        const Center(child: Text("Belum ada data transaksi."))
                      else
                        ...state.topTransactions.asMap().entries.map((entry) {
                          final t = entry.value;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TransactionDetailScreen(transaction: t),
                                ),
                              );
                            },
                            child: _buildTransactionCustomItem(
                              title: t.title.isEmpty ? 'Pengeluaran' : t.title,
                              category: t.categoryName ?? 'Lainnya',
                              amount: AppHelpers.formatCurrencyIdr(t.amount),
                              date: DateFormat(
                                'dd MMM yyyy',
                                'id',
                              ).format(t.date),
                              icon: _getIconForCategory(t.categoryName ?? ''),
                            ),
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
                'Trend Mingguan',
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
          const SizedBox(height: 32),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                    const SizedBox(height: 12),
                    Text(
                      'W${index + 1}',
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
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLegendPill(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
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

  Widget _buildTransactionCustomItem({
    required String title,
    required String category,
    required String amount,
    required String date,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFE74C3C), size: 24),
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
                  '$category • $date',
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppStyles.heading2.copyWith(
              fontSize: 14,
              color: const Color(0xFFE74C3C),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('makan')) return Icons.restaurant;
    if (name.contains('transport')) return Icons.directions_car;
    if (name.contains('belanja')) return Icons.shopping_bag;
    return Icons.receipt_long;
  }
}
