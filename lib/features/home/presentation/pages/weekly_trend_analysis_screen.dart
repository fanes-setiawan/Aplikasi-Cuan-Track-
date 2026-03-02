import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';

class WeeklyTrendAnalysisScreen extends StatelessWidget {
  const WeeklyTrendAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Analisis Tren Mingguan',
          style: AppStyles.heading2.copyWith(
            fontSize: 18,
            color: const Color(0xFF1B5E20),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: const Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Picker
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF27AE60),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '16 Oct - 22 Oct 2023',
                      style: AppStyles.bodyText.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chart Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Mockup Bar Chart
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBarGroup('Sen', 0.4, 0.5),
                        _buildBarGroup('Sel', 0.6, 0.4),
                        _buildBarGroup('Rab', 0.7, 0.6),
                        _buildBarGroup('Kam', 0.5, 0.3),
                        _buildBarGroup('Jum', 0.8, 0.9),
                        _buildBarGroup('Sab', 0.9, 0.7),
                        _buildBarGroup('Min', 0.6, 0.5),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendPill('Minggu Lalu', const Color(0xFFC8E6C9)),
                      const SizedBox(width: 16),
                      _buildLegendPill('Minggu Ini', const Color(0xFF27AE60)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF27AE60),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_down,
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
                          'Trend Mingguan',
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
                                text: '8% lebih rendah',
                                style: AppStyles.bodyText.copyWith(
                                  color: const Color(0xFF27AE60),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' dari minggu lalu.'),
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
              'Tren Kategori',
              style: AppStyles.heading2.copyWith(
                color: const Color(0xFF1B5E20),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryTrendCard('FOOD', Icons.restaurant, 'Rp 1.2M', [
                    0.3,
                    0.4,
                    0.2,
                    0.5,
                    0.6,
                  ]),
                  const SizedBox(width: 16),
                  _buildCategoryTrendCard(
                    'TRANSPORT',
                    Icons.directions_car,
                    'Rp 850rb',
                    [0.5, 0.4, 0.4, 0.3, 0.2],
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryTrendCard(
                    'ENT.',
                    Icons.local_activity,
                    'Rp 400rb',
                    [0.2, 0.2, 0.8, 0.3, 0.1],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Highlight Pekan Ini
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
                    'HIGHLIGHT PEKAN INI',
                    style: AppStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildHighlightItem(
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF27AE60),
                    iconBgColor: const Color(0xFFE8F5E9),
                    text:
                        'Anda menghemat Rp 150.000 pada kategori Transportasi.',
                  ),
                  const SizedBox(height: 24),
                  _buildHighlightItem(
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFF39C12),
                    iconBgColor: const Color(0xFFFFF3E0),
                    text: 'Pengeluaran Food sedikit meningkat di hari Jumat.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBarGroup(String day, double height1, double height2) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: 150 * height1,
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
              width: 12,
              height: 150 * height2,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
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
