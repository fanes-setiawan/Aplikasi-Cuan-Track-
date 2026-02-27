import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../notification/presentation/pages/notification_screen.dart';
import '../../../transaction/presentation/pages/add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppDimens.lg),
              _buildBalanceCard(),
              const SizedBox(height: AppDimens.lg),
              _buildActionButtons(context),
              const SizedBox(height: AppDimens.xl),
              _buildExpenseAnalysis(),
              const SizedBox(height: AppDimens.xl),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimens.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Pagi,',
              style: AppStyles.bodyTextSecondary.copyWith(fontSize: 12),
            ),
            Text('Halo, User!', style: AppStyles.heading2),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27AE60).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: Stack(
          children: [
            // Background Pattern/Wave
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL SALDO',
                        style: AppStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDimens.round),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+ 2.5%',
                              style: AppStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp ',
                        style: AppStyles.heading2.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '25.000.000',
                        style: AppStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.lg),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBalanceStat(
                            'PEMASUKAN',
                            'Rp 8.420.000',
                            const Color(0xFFA7FFEB),
                          ),
                        ),
                        VerticalDivider(
                          color: Colors.white.withOpacity(0.3),
                          thickness: 1,
                          width: 32,
                          indent: 4,
                          endIndent: 4,
                        ),
                        Expanded(
                          child: _buildBalanceStat(
                            'PENGELUARAN',
                            'Rp 3.150.000',
                            const Color(0xFFFFE0B2),
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
    );
  }

  Widget _buildBalanceStat(String label, String value, Color bulletColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: bulletColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(),
                ),
              );
            },
            child: _buildActionButton(
              'Tambah',
              Icons.add_circle,
              const Color(0xFFE8F5E9),
              const Color(0xFF2E7D32),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.md),
        Expanded(
          child: _buildActionButton(
            'Catat',
            Icons.edit_document,
            Colors.white,
            const Color(0xFF2E7D32),
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color bgColor,
    Color textColor, {
    bool isOutlined = false,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: isOutlined ? Border.all(color: AppColors.divider) : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.bodyText.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseAnalysis() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Analisis Pengeluaran', style: AppStyles.heading2),
            const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        Container(
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
          child: Row(
            children: [
              // Mock Donut Chart
              _buildMockDonutChart(),
              const SizedBox(width: AppDimens.xl),
              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('Food', '45%', const Color(0xFF1B5E20)),
                    _buildLegendItem(
                      'Transport',
                      '30%',
                      const Color(0xFF2ECC71),
                    ),
                    _buildLegendItem(
                      'Shopping',
                      '25%',
                      const Color(0xFFA5D6A7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockDonutChart() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(120, 120),
            painter: DonutChartPainter(
              ratios: [0.45, 0.30, 0.25],
              colors: [
                const Color(0xFF1B5E20),
                const Color(0xFF2ECC71),
                const Color(0xFFA5D6A7),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('TOTAL', style: AppStyles.caption.copyWith(fontSize: 10)),
                Text('100%', style: AppStyles.heading2.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              label == 'Food'
                  ? Icons.restaurant
                  : label == 'Transport'
                  ? Icons.directions_car
                  : Icons.shopping_bag,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppStyles.bodyTextSecondary),
          const Spacer(),
          Text(
            percent,
            style: AppStyles.bodyText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Transaksi Terakhir', style: AppStyles.heading2),
            Text(
              'Lihat Semua',
              style: AppStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        _buildTransactionItem(
          'Makan Siang - Bakso',
          'HARI INI, 12:30 • FOOD',
          '-Rp 25.000',
          Colors.orange[100]!,
          Colors.orange[900]!,
          Icons.restaurant,
        ),
        _buildTransactionItem(
          'Bensin Mobil',
          'KEMARIN, 18:45 • TRANSPORT',
          '-Rp 150.000',
          Colors.blue[100]!,
          Colors.blue[900]!,
          Icons.directions_car,
        ),
        _buildTransactionItem(
          'Belanja Bulanan',
          '22 OKT 2023 • SHOPPING',
          '-Rp 450.000',
          Colors.purple[100]!,
          Colors.purple[900]!,
          Icons.shopping_bag,
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    String subtitle,
    String amount,
    Color bgColor,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.sm + 2),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Text(
            amount,
            style: AppStyles.bodyText.copyWith(
              color: Colors.red[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> ratios;
  final List<Color> colors;

  DonutChartPainter({required this.ratios, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 25;
    final Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    double startAngle = -1.5708; // Start from top (-90 degrees)

    for (int i = 0; i < ratios.length; i++) {
      final double sweepAngle = ratios[i] * 2 * 3.14159;
      final Paint paint = Paint()
        ..color = colors[i]
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
