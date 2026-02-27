import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'add_budget_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text('Manajemen Anggaran', style: AppStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create New Budget Button
            Padding(
              padding: const EdgeInsets.all(AppDimens.md),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBudgetScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF27AE60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF27AE60).withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Buat Anggaran Baru',
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Budget Summary
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL ANGGARAN',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp 8.500.000',
                        style: AppStyles.heading2.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TERPAKAI',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '65%',
                        style: AppStyles.heading2.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              child: Text(
                'ANGGARAN AKTIF',
                style: AppStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.md),

            // Budget Items
            _buildBudgetItem(
              title: 'Makanan',
              spent: 'Rp 1.200.000',
              total: 'Rp 2.500.000',
              progress: 0.48,
              percent: '48%',
              icon: Icons.restaurant,
              iconBgColor: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFEA580C),
              progressColor: const Color(0xFF27AE60),
            ),
            _buildBudgetItem(
              title: 'Transportasi',
              spent: 'Rp 850.000',
              total: 'Rp 1.000.000',
              progress: 0.85,
              percent: '85%',
              icon: Icons.directions_car,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              progressColor: const Color(0xFFF97316),
              highlightColor: const Color(0xFFFFF7ED),
            ),
            _buildBudgetItem(
              title: 'Belanja',
              spent: 'Rp 1.450.000',
              total: 'Rp 1.500.000',
              progress: 0.96,
              percent: '96%',
              icon: Icons.shopping_bag,
              iconBgColor: const Color(0xFFF5F3FF),
              iconColor: const Color(0xFF7C3AED),
              progressColor: const Color(0xFFEF4444),
              highlightColor: const Color(0xFFFEF2F2),
            ),
            _buildBudgetItem(
              title: 'Hiburan',
              spent: 'Rp 300.000',
              total: 'Rp 1.000.000',
              progress: 0.30,
              percent: '30%',
              icon: Icons.theater_comedy,
              iconBgColor: const Color(0xFFFDF2F8),
              iconColor: const Color(0xFFDB2777),
              progressColor: const Color(0xFF27AE60),
              highlightColor: const Color(0xFFF0FDF4),
            ),
            const SizedBox(height: AppDimens.xl),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
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
              const SizedBox(height: 12),
              _buildMenuItem(
                icon: Icons.sort,
                title: 'Urutkan Anggaran',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 64),
              _buildMenuItem(
                icon: Icons.restart_alt,
                title: 'Atur Ulang Semua',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 64),
              _buildMenuItem(
                icon: Icons.edit_note,
                title: 'Edit Kategori',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 64),
              _buildMenuItem(
                icon: Icons.archive_outlined,
                title: 'Tampilkan Anggaran Terarsip',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: const Color(0xFF1B5E20), size: 28),
      title: Text(
        title,
        style: AppStyles.bodyText.copyWith(
          color: const Color(0xFF1B5E20),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBudgetItem({
    required String title,
    required String spent,
    required String total,
    required double progress,
    required String percent,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color progressColor,
    Color? highlightColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 8),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: 24),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$spent / $total',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: highlightColor ?? const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  percent,
                  style: AppStyles.caption.copyWith(
                    color: progress >= 0.9
                        ? const Color(0xFFEF4444)
                        : (progress >= 0.8
                              ? const Color(0xFFF97316)
                              : const Color(0xFF27AE60)),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
