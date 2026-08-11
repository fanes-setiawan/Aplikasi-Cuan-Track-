import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../domain/entities/savings_category_entity.dart';
import '../bloc/savings_category_bloc.dart';
import '../bloc/savings_category_event.dart';

class AddSavingsCategorySheet extends StatefulWidget {
  final SavingsCategoryEntity? category;
  const AddSavingsCategorySheet({super.key, this.category});

  @override
  State<AddSavingsCategorySheet> createState() =>
      _AddSavingsCategorySheetState();
}

class _AddSavingsCategorySheetState extends State<AddSavingsCategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.savings;
  Color _selectedColor = const Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = AppHelpers.getCategoryIcon(widget.category!.iconName);
      _selectedColor = Color(int.parse(widget.category!.colorHex));
    }
  }

  final List<IconData> _icons = [
    Icons.savings,
    Icons.flight_takeoff,
    Icons.laptop_mac,
    Icons.home,
    Icons.directions_car,
    Icons.school,
    Icons.favorite,
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.local_hospital,
    Icons.camera_alt,
    Icons.phone_iphone,
    Icons.watch_later,
    Icons.sports_esports,
  ];

  final List<Color> _colors = [
    const Color(0xFF27AE60),
    const Color(0xFF2563EB),
    const Color(0xFFEF4444),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFF4F46E5),
    const Color(0xFFEC4899),
    const Color(0xFF14B8A6),
    const Color(0xFFF97316),
    const Color(0xFF64748B),
  ];

  String _getIconName(IconData icon) {
    if (icon == Icons.savings) return 'savings';
    if (icon == Icons.flight_takeoff) return 'travel';
    if (icon == Icons.laptop_mac) return 'electronics';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.directions_car) return 'transport';
    if (icon == Icons.school) return 'education';
    if (icon == Icons.favorite) return 'heart';
    if (icon == Icons.shopping_bag) return 'shopping';
    if (icon == Icons.restaurant) return 'food';
    if (icon == Icons.local_hospital) return 'health';
    if (icon == Icons.camera_alt) return 'camera';
    if (icon == Icons.phone_iphone) return 'phone';
    if (icon == Icons.watch_later) return 'bonus';
    if (icon == Icons.sports_esports) return 'entertainment';
    return 'savings';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                      widget.category != null
                          ? 'Edit Tujuan'
                          : 'Tambah Tujuan Nabung',
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
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Tujuan',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Misal: Beli Laptop Baru',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius16),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV32),
                  Text(
                    'Pilih Ikon',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius16,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.divider,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSizes.paddingV32),
                  Text(
                    'Pilih Warna',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                  CustomButton(
                    text: widget.category != null
                        ? 'Update Tujuan'
                        : 'Simpan Tujuan',
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null || _nameController.text.isEmpty) return;

                      final colorHex =
                          '0xFF${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

                      final category = SavingsCategoryEntity(
                        id: widget.category?.id ?? '',
                        userId: user.uid,
                        name: _nameController.text.trim(),
                        iconName: _getIconName(_selectedIcon),
                        colorHex: colorHex,
                      );

                      if (widget.category != null) {
                        context.read<SavingsCategoryBloc>().add(
                          UpdateSavingsCategory(category),
                        );
                      } else {
                        context.read<SavingsCategoryBloc>().add(
                          AddSavingsCategory(category),
                        );
                      }

                      Navigator.pop(context);
                    },
                  ),
                  if (widget.category != null) ...[
                    SizedBox(height: AppSizes.paddingV16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            context.read<SavingsCategoryBloc>().add(
                              DeleteSavingsCategory(
                                user.uid,
                                widget.category!.id,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Hapus Tujuan',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: AppSizes.paddingV32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
