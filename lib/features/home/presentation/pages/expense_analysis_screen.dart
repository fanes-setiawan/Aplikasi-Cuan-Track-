import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import 'weekly_trend_analysis_screen.dart';
import 'comparative_analysis_screen.dart';

class ExpenseAnalysisScreen extends StatelessWidget {
  const ExpenseAnalysisScreen({super.key});

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
          'Analisis Pengeluaran',
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
              Icons.calendar_today_outlined,
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
            // Donut Chart Mockup Placeholder
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1B5E20), width: 30),
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
                        'Rp 3.150.000',
                        style: AppStyles.heading1.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oktober 2023',
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

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendPill('Food: 45%', const Color(0xFF1B5E20), true),
                const SizedBox(width: 12),
                _buildLegendPill(
                  'Transport: 30%',
                  const Color(0xFF27AE60),
                  false,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendPill(
                  'Shopping: 25%',
                  const Color(0xFF2ECC71),
                  false,
                ),
              ],
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
                            builder: (context) =>
                                const ComparativeAnalysisScreen(),
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
                            builder: (context) =>
                                const WeeklyTrendAnalysisScreen(),
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
                    amount: 'Rp 3.150.000',
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFFE74C3C),
                    bgColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalysisGridCard(
                    title: 'Bulan Lalu',
                    amount: 'Rp 2.800.000',
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
                    amount: '+12.5%',
                    subtitle: 'Lebih boros',
                    icon: Icons.compare_arrows,
                    iconColor: const Color(0xFFF39C12),
                    bgColor: const Color(0xFFFFF3E0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalysisGridCard(
                    title: 'Rata-rata/Hari',
                    amount: 'Rp 105.000',
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

            // Cards
            _buildCategoryCard(
              icon: Icons.restaurant,
              title: 'Makanan & Minuman',
              amount: 'Rp 1.417.500',
              percentage: '45% dari total anggaran',
              trend: '12% lebih tinggi dari bulan lalu',
              isTrendingUp: true,
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              icon: Icons.directions_car,
              title: 'Transportasi',
              amount: 'Rp 945.000',
              percentage: '30% dari total anggaran',
              trend: '5% lebih rendah dari bulan lalu',
              isTrendingUp: false,
              isNeutral: false,
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              icon: Icons.shopping_bag,
              title: 'Belanja',
              amount: 'Rp 787.500',
              percentage: '25% dari total anggaran',
              trend: 'Sama dengan bulan lalu',
              isTrendingUp: false,
              isNeutral: true,
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
                              const TextSpan(
                                text:
                                    'Pengeluaran makan siang Anda meningkat tajam minggu ini. Pertimbangkan untuk membawa bekal untuk menghemat hingga ',
                              ),
                              TextSpan(
                                text: 'Rp 200.000',
                                style: AppStyles.bodyText.copyWith(
                                  color: const Color(0xFF27AE60),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' di minggu depan.'),
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
            Text(
              'Detail Sub-Kategori (Food)',
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
                children: [
                  _buildSubCategoryItem('Restoran & Kafe', 'Rp 850.000', 0.6),
                  const Divider(height: 1),
                  _buildSubCategoryItem('Bahan Makanan', 'Rp 467.500', 0.35),
                  const Divider(height: 1),
                  _buildSubCategoryItem('Camilan', 'Rp 100.000', 0.1),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
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
}
