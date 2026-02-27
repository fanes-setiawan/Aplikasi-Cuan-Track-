import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  String _selectedPeriod = 'Bulanan';
  bool _remindMe = true;
  final TextEditingController _amountController = TextEditingController(
    text: '2000000',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(Icons.chevron_left, color: AppColors.primary),
                Text(
                  'Kembali',
                  style: AppStyles.bodyText.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: Text('Tambah Anggaran', style: AppStyles.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'LIMIT ANGGARAN',
              style: AppStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp',
                  style: AppStyles.heading1.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: AppStyles.heading1.copyWith(fontSize: 40),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 32),
            Text(
              'PILIH KATEGORI',
              style: AppStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Makanan & Minuman',
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                  items:
                      [
                        'Makanan & Minuman',
                        'Transportasi',
                        'Belanja',
                        'Hiburan',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                value == 'Makanan & Minuman'
                                    ? Icons.restaurant
                                    : value == 'Transportasi'
                                    ? Icons.directions_car
                                    : value == 'Belanja'
                                    ? Icons.shopping_bag
                                    : Icons.theater_comedy,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(value, style: AppStyles.bodyText),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'PERIODE',
              style: AppStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: Row(
                children: [
                  _buildPeriodItem('Mingguan'),
                  _buildPeriodItem('Bulanan'),
                  _buildPeriodItem('Tahunan'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFB),
                borderRadius: BorderRadius.circular(AppDimens.radiusL),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingatkan Saya',
                          style: AppStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Notifikasi saat mencapai 80% limit',
                          style: AppStyles.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _remindMe,
                    onChanged: (val) {
                      setState(() {
                        _remindMe = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              elevation: 0,
            ),
            child: Text(
              'Simpan Anggaran',
              style: AppStyles.bodyText.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodItem(String title) {
    bool isSelected = _selectedPeriod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: AppStyles.bodyText.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
