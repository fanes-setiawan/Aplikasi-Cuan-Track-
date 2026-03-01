import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_bloc.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_event.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_state.dart';
import 'add_category_sheet.dart';

class CustomCategoriesScreen extends StatefulWidget {
  const CustomCategoriesScreen({super.key});

  @override
  State<CustomCategoriesScreen> createState() => _CustomCategoriesScreenState();
}

class _CustomCategoriesScreenState extends State<CustomCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<CategoryBloc>().add(LoadCategories(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Kategori Kustom', style: AppStyles.heading2),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryError) {
            return Center(child: Text("Gagal memuat: ${state.message}"));
          } else if (state is CategoryLoaded) {
            final categories = state.categories;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppDimens.lg),
                  if (categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Text(
                        "Belum ada kategori yang ditambahkan",
                        style: AppStyles.bodyTextSecondary,
                      ),
                    ),
                  ...categories.map(
                    (cat) => _buildCategoryCard(
                      id: cat.id,
                      icon: _getIconForName(cat.iconName),
                      name: cat.name,
                      description: cat.type == 'income'
                          ? 'Pemasukan'
                          : 'Pengeluaran',
                      iconBgColor: Color(
                        int.parse(cat.colorHex),
                      ).withOpacity(0.1),
                      iconColor: Color(int.parse(cat.colorHex)),
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const AddCategorySheet(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF27AE60).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Tambah Kategori Baru',
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
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getIconForName(String name) {
    if (name.contains('salary')) return Icons.payments_outlined;
    if (name.contains('bonus')) return Icons.stars_outlined;
    if (name.contains('invest')) return Icons.show_chart_outlined;
    if (name.contains('food')) return Icons.fastfood_outlined;
    if (name.contains('transport')) return Icons.directions_car_outlined;
    if (name.contains('shopping')) return Icons.shopping_bag_outlined;
    if (name.contains('entertainment')) return Icons.sports_esports_outlined;
    return Icons.category_outlined;
  }

  Widget _buildCategoryCard({
    required String id,
    required IconData icon,
    required String name,
    required String description,
    required Color iconBgColor,
    required Color iconColor,
    required BuildContext context,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textHint,
                  size: 22,
                ),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    context.read<CategoryBloc>().add(
                      DeleteCategory(userId: user.uid, categoryId: id),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
