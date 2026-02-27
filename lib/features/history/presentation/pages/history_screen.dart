import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';

class HistoryScreen extends StatelessWidget {
  final bool showBackButton;
  const HistoryScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text('Riwayat Transaksi', style: AppStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => _showReportPreview(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Container(
              margin: const EdgeInsets.all(AppDimens.md),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.chevron_left,
                    color: AppColors.textSecondary,
                  ),
                  Text(
                    'Oktober 2023',
                    style: AppStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Search and Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cari transaksi...',
                            style: AppStyles.bodyTextSecondary.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            // Summary Card
            Container(
              margin: const EdgeInsets.all(AppDimens.md),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'TOTAL PEMASUKAN',
                        'Rp 8.420.000',
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.white.withOpacity(0.3),
                      thickness: 1,
                      width: 32,
                    ),
                    Expanded(
                      child: _buildSummaryItem(
                        'TOTAL PENGELUARAN',
                        'Rp 3.150.000',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildSectionHeader('HARI INI', '25 Okt 2023'),
            _buildHistoryItem(
              'Makan Siang - Bakso',
              '12:30 • Food',
              '-Rp 25.000',
              const Color(0xFFFFECE0),
              const Color(0xFFFF8A00),
              Icons.restaurant,
            ),
            _buildHistoryItem(
              'Grab Car - Kantor',
              '08:15 • Transport',
              '-Rp 45.000',
              const Color(0xFFE3F2FD),
              const Color(0xFF2196F3),
              Icons.directions_car,
            ),

            _buildSectionHeader('KEMARIN', '24 Okt 2023'),
            _buildHistoryItem(
              'Bonus Project',
              '16:45 • Income',
              '+Rp 1.500.000',
              const Color(0xFFE8F5E9),
              const Color(0xFF4CAF50),
              Icons.payments_outlined,
              isExpense: false,
            ),
            _buildHistoryItem(
              'Minimarket',
              '14:20 • Shopping',
              '-Rp 112.500',
              const Color(0xFFF3E5F5),
              const Color(0xFF9C27B0),
              Icons.shopping_bag,
            ),

            _buildSectionHeader('20 OKT 2023', ''),
            _buildHistoryItem(
              'Gaji Bulanan',
              '09:00 • Income',
              '+Rp 6.500.000',
              const Color(0xFFE8F5E9),
              const Color(0xFF4CAF50),
              Icons.account_balance,
              isExpense: false,
            ),
            const SizedBox(height: AppDimens.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildSectionHeader(String title, String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.md, 12, AppDimens.md, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
            ),
          ),
          if (date.isNotEmpty)
            Text(
              date,
              style: AppStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textHint,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String title,
    String subtitle,
    String amount,
    Color iconBgColor,
    Color iconColor,
    IconData icon, {
    bool isExpense = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 6),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
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
                Text(
                  subtitle,
                  style: AppStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppStyles.bodyText.copyWith(
              color: isExpense
                  ? const Color(0xFFE57373)
                  : const Color(0xFF66BB6A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pratinjau Laporan',
                style: AppStyles.heading2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 24),

              // Report Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Keuangan',
                              style: AppStyles.bodyText.copyWith(
                                color: const Color(0xFF27AE60),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'OKTOBER 2023',
                              style: AppStyles.caption.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Dicetak pada',
                              style: AppStyles.caption.copyWith(fontSize: 10),
                            ),
                            Text(
                              '25 Okt 2023, 15:45',
                              style: AppStyles.bodyTextSecondary.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'SALDO AKHIR',
                      style: AppStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp 5.270.000',
                      style: AppStyles.heading1.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 24),

                    // Bar Chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PEMASUKAN',
                          style: AppStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF27AE60),
                          ),
                        ),
                        Text(
                          'PENGELUARAN',
                          style: AppStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEB5757),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Container(
                              height: 12,
                              color: const Color(0xFF27AE60),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 12,
                              color: const Color(0xFFEB5757),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp 8.420.000',
                          style: AppStyles.caption.copyWith(fontSize: 10),
                        ),
                        Text(
                          'Rp 3.150.000',
                          style: AppStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'PENGELUARAN TERBESAR',
                      style: AppStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildReportDetailItem(
                      'Shopping',
                      'Rp 1.250.000',
                      const Color(0xFF9B51E0),
                    ),
                    _buildReportDetailItem(
                      'Food & Drinks',
                      'Rp 845.000',
                      const Color(0xFFF2994A),
                    ),
                    _buildReportDetailItem(
                      'Transport',
                      'Rp 420.000',
                      const Color(0xFF2D9CDB),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Unduh Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Trigger actual PDF generation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Unduh PDF',
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportDetailItem(String label, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppStyles.bodyTextSecondary),
          const Spacer(),
          Text(
            amount,
            style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
