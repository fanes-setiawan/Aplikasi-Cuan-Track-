import 'package:cuan_track/core/utils/app_sizes.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _providers = [
    {
      'name': 'Bank BCA',
      'category': 'Rekening Bank',
      'icon': Icons.account_balance,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
    },
    {
      'name': 'Bank Mandiri',
      'category': 'Rekening Bank',
      'icon': Icons.account_balance,
      'color': const Color(0xFFFFFBEB),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'name': 'Bank BNI',
      'category': 'Rekening Bank',
      'icon': Icons.account_balance,
      'color': const Color(0xFFFDF2F2),
      'iconColor': const Color(0xFFE11D48),
    },
    {
      'name': 'Bank BRI',
      'category': 'Rekening Bank',
      'icon': Icons.account_balance,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF1E40AF),
    },
    {
      'name': 'GoPay',
      'category': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFECFDF5),
      'iconColor': const Color(0xFF059669),
    },
    {
      'name': 'OVO',
      'category': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFFAF5FF),
      'iconColor': const Color(0xFF7C3AED),
    },
    {
      'name': 'Dana',
      'category': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
    },
    {
      'name': 'ShopeePay',
      'category': 'E-Wallet',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFFFFF7ED),
      'iconColor': const Color(0xFFEA580C),
    },
    {
      'name': 'Tunai Pribadi',
      'category': 'Tunai',
      'icon': Icons.payments_outlined,
      'color': const Color(0xFFF0FDF4),
      'iconColor': const Color(0xFF27AE60),
    },
  ];

  List<Map<String, dynamic>> get _filteredProviders {
    return _providers.where((p) {
      final matchesCategory = p['category'] == _selectedCategory;
      final matchesSearch = p['name'].toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radius32),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: AppSizes.paddingV12),
          Container(
            width: 40,
            height: AppSizes.paddingV4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSizes.paddingV12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Pilih Metode Pembayaran',
                      style: AppStyles.heading2.copyWith(
                        fontSize: AppSizes.font18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          SizedBox(height: AppSizes.paddingV24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipe Akun',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV12),
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
                  SizedBox(height: AppSizes.paddingV32),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(AppSizes.radius16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari penyedia layanan...',
                        hintStyle: AppStyles.bodyTextSecondary.copyWith(
                          color: AppColors.textHint,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV32),
                  Text(
                    'Penyedia Layanan',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV16),
                  if (_filteredProviders.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.textHint.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: AppSizes.paddingV16),
                            Text(
                              'Penyedia tidak ditemukan',
                              style: AppStyles.bodyTextSecondary.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredProviders.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: AppSizes.paddingV12),
                      itemBuilder: (context, index) {
                        final provider = _filteredProviders[index];
                        return _buildProviderItem(
                          provider['name'],
                          provider['icon'],
                          provider['color'],
                          provider['iconColor'],
                        );
                      },
                    ),
                  SizedBox(height: AppSizes.paddingV32),
                ],
              ),
            ),
          ),
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
                  'Batal',
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
          _searchQuery = '';
          _searchController.clear();
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(
            color: isSelected ? const Color(0xFF27AE60) : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
            SizedBox(height: AppSizes.paddingV8),
            Text(
              title,
              style: AppStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: AppSizes.font10,
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
    return InkWell(
      onTap: () {
        Navigator.pop(context, name);
      },
      borderRadius: BorderRadius.circular(AppSizes.radius16),
      child: Container(
        padding: EdgeInsets.all(AppSizes.padding12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radius16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSizes.radius12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: AppSizes.padding16),
            Expanded(
              child: Text(
                name,
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
