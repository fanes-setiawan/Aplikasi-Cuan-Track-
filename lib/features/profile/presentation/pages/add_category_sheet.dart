import 'package:cuan_track/core/utils/app_sizes.dart';
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
  final String initialType;
  const AddCategorySheet({super.key, this.initialType = 'expense'});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.shopping_bag;
  Color _selectedColor = const Color(0xFF27AE60);
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radius32)),
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
                      'Tambah Kategori',
                      style: AppStyles.heading2.copyWith(fontSize: AppSizes.font18),
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
                    'Jenis Kategori',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = 'expense'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV12),
                            decoration: BoxDecoration(
                              color: _selectedType == 'expense'
                                  ? const Color(0xFF27AE60)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radius16),
                              border: Border.all(
                                color: _selectedType == 'expense'
                                    ? Colors.transparent
                                    : AppColors.divider,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pengeluaran',
                              style: AppStyles.bodyText.copyWith(
                                color: _selectedType == 'expense'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.padding16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = 'income'),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV12),
                            decoration: BoxDecoration(
                              color: _selectedType == 'income'
                                  ? const Color(0xFF27AE60)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radius16),
                              border: Border.all(
                                color: _selectedType == 'income'
                                    ? Colors.transparent
                                    : AppColors.divider,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Pemasukan',
                              style: AppStyles.bodyText.copyWith(
                                color: _selectedType == 'income'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingV32),
                  Text(
                    'Nama Kategori',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Misal: Belanja Bulanan',
                      hintStyle: AppStyles.bodyTextSecondary.copyWith(
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSizes.padding16,
                        vertical: AppSizes.paddingV16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius16),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius16),
                        borderSide: const BorderSide(color: Color(0xFF27AE60)),
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
                                ? const Color(0xFF27AE60)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.radius16),
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
                  SizedBox(height: AppSizes.paddingV32),
                  Text(
                    'Pilih Warna',
                    style: AppStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV16),
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
                                    width: AppSizes.padding4,
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
                        type: _selectedType,
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
                      Navigator.pop(context);
                    },
                  ),
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
