import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';

class ComparativeAnalysisScreen extends StatelessWidget {
  const ComparativeAnalysisScreen({super.key});

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
                  'Oktober\n2023',
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
                          'Rp 3.150.000',
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
                          'Rp 2.890.000',
                          style: AppStyles.heading2.copyWith(
                            color: const Color(0xFF94A3B8), // Muted color
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

            // Line Chart Section
            Container(
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
                          _buildLegendPill('Okt', const Color(0xFF27AE60)),
                          const SizedBox(width: 8),
                          _buildLegendPill('Sep', const Color(0xFFCBD5E1)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Mockup Line Chart
                  SizedBox(
                    height: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              // Background grid lines (mocked)
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  4,
                                  (index) => Container(
                                    height: 1,
                                    color: AppColors.divider.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              // Mock curve lines using simple custom paint or placeholders
                              // Here we just use a placeholder text as drawing a real smooth
                              // path without a chart library is complex for a simple mock.
                              Center(
                                child: Text(
                                  '[ Grafik Garis Perbandingan ]',
                                  style: AppStyles.caption.copyWith(
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Minggu 1',
                              style: AppStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Minggu 2',
                              style: AppStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Minggu 3',
                              style: AppStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Minggu 4',
                              style: AppStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
              icon: Icons.trending_up,
              iconColor: const Color(0xFF27AE60),
              iconBgColor: const Color(0xFFC8E6C9),
              bgColor: const Color(0xFFE8F5E9),
              richText: TextSpan(
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Pengeluaran Anda naik '),
                  TextSpan(
                    text: '9.2% ',
                    style: AppStyles.bodyText.copyWith(
                      color: const Color(0xFFE74C3C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'dibanding bulan lalu. Kenaikan terbesar terjadi pada kategori ',
                  ),
                  TextSpan(
                    text: 'Hiburan',
                    style: AppStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                  const TextSpan(text: ' di minggu ketiga.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              icon: Icons.lightbulb,
              iconColor: const Color(0xFFF39C12),
              iconBgColor: const Color(0xFFFFE0B2),
              bgColor: Colors
                  .white, // In mockup it looks white/transparent with border
              borderColor: const Color(0xFFFAFAFA),
              richText: TextSpan(
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Anda bisa menghemat hingga '),
                  TextSpan(
                    text: 'Rp 150.000 ',
                    style: AppStyles.bodyText.copyWith(
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'jika mengurangi frekuensi makan di luar pada akhir pekan.',
                  ),
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
                Text(
                  'LIHAT SEMUA',
                  style: AppStyles.bodyText.copyWith(
                    color: const Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildTransactionItem(
                    icon: Icons.shopping_cart,
                    iconColor: const Color(0xFFE74C3C),
                    iconBgColor: const Color(0xFFFCE4EC),
                    title: 'Belanja Bulanan Supermarket',
                    date: '12 Oktober 2023 • 14:20',
                    amount: '-Rp 850.000',
                  ),
                  const Divider(height: 1),
                  _buildTransactionItem(
                    icon: Icons.bolt,
                    iconColor: const Color(0xFF3498DB),
                    iconBgColor: const Color(0xFFE3F2FD),
                    title: 'Tagihan Listrik & Air',
                    date: '05 Oktober 2023 • 09:15',
                    amount: '-Rp 620.000',
                  ),
                  const Divider(height: 1),
                  _buildTransactionItem(
                    icon: Icons.restaurant,
                    iconColor: const Color(0xFF27AE60),
                    iconBgColor: const Color(0xFFE8F5E9),
                    title: 'Makan Malam Akhir Pekan',
                    date: '21 Oktober 2023 • 20:30',
                    amount: '-Rp 450.000',
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
