import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';

class PaymentSelectionSheet extends StatefulWidget {
  const PaymentSelectionSheet({super.key});

  @override
  State<PaymentSelectionSheet> createState() => _PaymentSelectionSheetState();
}

class _PaymentSelectionSheetState extends State<PaymentSelectionSheet> {
  String _selectedCategory = 'Rekening Bank';
  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Bank BCA',
      'icon': Icons.account_balance,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
    },
    {
      'name': 'Bank Mandiri',
      'icon': Icons.account_balance,
      'color': const Color(0xFFFFFBEB),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'name': 'GoPay',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFECFDF5),
      'iconColor': const Color(0xFF059669),
    },
    {
      'name': 'OVO',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFFAF5FF),
      'iconColor': const Color(0xFF7C3AED),
    },
    {
      'name': 'Dana',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Pilih Metode Pembayaran Baru',
                      style: AppStyles.heading2.copyWith(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 48,
                ), // Padding to balance the close button
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Tipe Akun Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipe Akun',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(
                        'Rekening Bank',
                        Icons.account_balance,
                      ),
                      _buildCategoryItem(
                        'E-Wallet',
                        Icons.account_balance_wallet_outlined,
                      ),
                      _buildCategoryItem('Tunai', Icons.payments_outlined),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Search Bar
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(16),
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
                          'Cari penyedia layanan...',
                          style: AppStyles.bodyTextSecondary.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Penyedia Populer Section
                  Text(
                    'Penyedia Populer',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _providers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final provider = _providers[index];
                      return _buildProviderItem(
                        provider['name'],
                        provider['icon'],
                        provider['color'],
                        provider['iconColor'],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Lanjut',
                  style: AppStyles.bodyText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    bool isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF27AE60) : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF27AE60)
                  : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderItem(
    String name,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
