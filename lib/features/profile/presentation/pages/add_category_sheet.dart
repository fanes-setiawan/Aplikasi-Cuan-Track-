import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/app_helpers.dart';
import 'package:cuan_track/features/category/domain/entities/category_entity.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_bloc.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_event.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({super.key});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.shopping_bag;
  Color _selectedColor = const Color(0xFF27AE60);

  final List<IconData> _icons = [
    Icons.shopping_bag,
    Icons.directions_car,
    Icons.home,
    Icons.favorite,
    Icons.local_cafe,
    Icons.restaurant,
    Icons.airplanemode_active,
    Icons.payments,
    Icons.business_center,
    Icons.school,
  ];

  final List<Color> _colors = [
    const Color(0xFF27AE60),
    const Color(0xFF2563EB),
    const Color(0xFFEF4444),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFF4F46E5),
    const Color(0xFFEC4899),
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
                      'Tambah Kategori',
                      style: AppStyles.heading2.copyWith(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama Kategori',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Misal: Belanja Bulanan',
                      hintStyle: AppStyles.bodyTextSecondary.copyWith(
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF27AE60)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Pilih Ikon',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                ? const Color(0xFF27AE60)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.divider.withOpacity(0.5),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF27AE60,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Pilih Warna',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: color.withOpacity(0.3),
                                    width: 4,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  )
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
                    text: 'Simpan Kategori',
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        AppHelpers.showSnackBar(
                          context,
                          'Anda belum login',
                          isError: true,
                        );
                        return;
                      }

                      if (_nameController.text.isEmpty) {
                        AppHelpers.showSnackBar(
                          context,
                          'Nama kategori harus diisi',
                          isError: true,
                        );
                        return;
                      }

                      String iconName = 'category_outlined';
                      if (_selectedIcon == Icons.shopping_bag)
                        iconName = 'expense_shopping';
                      else if (_selectedIcon == Icons.directions_car)
                        iconName = 'expense_transport';
                      else if (_selectedIcon == Icons.home)
                        iconName = 'expense_home';
                      else if (_selectedIcon == Icons.favorite)
                        iconName = 'expense_heart';
                      else if (_selectedIcon == Icons.local_cafe)
                        iconName = 'expense_cafe';
                      else if (_selectedIcon == Icons.restaurant)
                        iconName = 'expense_food';
                      else if (_selectedIcon == Icons.airplanemode_active)
                        iconName = 'expense_travel';
                      else if (_selectedIcon == Icons.payments)
                        iconName = 'income_salary';
                      else if (_selectedIcon == Icons.business_center)
                        iconName = 'income_business';
                      else if (_selectedIcon == Icons.school)
                        iconName = 'expense_education';

                      String colorHex =
                          '0xFF${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

                      final newCategory = CategoryEntity(
                        id: '',
                        userId: user.uid,
                        name: _nameController.text.trim(),
                        type:
                            'expense', // default user categories to expense for now, unless toggled
                        iconName: iconName,
                        colorHex: colorHex,
                      );

                      context.read<CategoryBloc>().add(
                        AddCategory(newCategory),
                      );

                      AppHelpers.showSnackBar(
                        context,
                        'Kategori berhasil ditambahkan',
                      );
                      Navigator.pop(context); // Close sheet
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
