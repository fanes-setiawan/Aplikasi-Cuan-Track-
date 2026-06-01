import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_entity.dart';
import '../bloc/add_budget_bloc.dart';
import '../bloc/add_budget_event.dart';
import '../bloc/add_budget_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'package:cuan_track/features/category/domain/entities/category_entity.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_bloc.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_event.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_state.dart';
import '../../../../core/utils/app_helpers.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  String _selectedPeriod = 'Bulanan';
  bool _remindMe = true;
  CategoryEntity? _selectedCategory;
  String _rawAmount = "0";

  String get _formattedAmount {
    if (_rawAmount.isEmpty) return "0";
    final amountParsed = double.tryParse(_rawAmount) ?? 0.0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    ).format(amountParsed).trim();
  }

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
                Icon(Icons.chevron_left, color: AppColors.primary),
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
      body: BlocConsumer<AddBudgetBloc, AddBudgetState>(
        listener: (context, state) {
          if (state is AddBudgetSuccess) {
            AppHelpers.showSnackBar(context, 'Anggaran berhasil disimpan!');
            Navigator.pop(context);
          } else if (state is AddBudgetError) {
            AppHelpers.showSnackBar(
              context,
              'Gagal: ${state.message}',
              isError: true,
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                              color: AppColors.primary,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  _formattedAmount,
                                  style: AppStyles.heading1.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 48,
                                  ),
                                ),
                                Container(
                                  width: 3,
                                  height: 40,
                                  margin: const EdgeInsets.only(left: 4),
                                  color: AppColors.primary,
                                ),
                              ],
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
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading ||
                              state is CategoryInitial) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is CategoryLoaded) {
                            final expenseCategories = state.categories
                                .where((c) => c.type == 'expense')
                                .toList();
                            if (expenseCategories.isNotEmpty) {
                              _selectedCategory ??= expenseCategories.first;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  "Belum ada kategori pengeluaran",
                                  style: AppStyles.bodyText,
                                ),
                              );
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFB),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusM,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CategoryEntity>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.textSecondary,
                                  ),
                                  items: expenseCategories.map((
                                    CategoryEntity cat,
                                  ) {
                                    return DropdownMenuItem<CategoryEntity>(
                                      value: cat,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getIconForName(cat.iconName),
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            cat.name,
                                            style: AppStyles.bodyText,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedCategory = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusM,
                          ),
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
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusL,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
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
                                    style: AppStyles.caption.copyWith(
                                      fontSize: 10,
                                    ),
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                _buildNumericKeypad(),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: BlocBuilder<AddBudgetBloc, AddBudgetState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is AddBudgetLoading ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  elevation: 0,
                ),
                child: state is AddBudgetLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        'Simpan Anggaran',
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
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

  Widget _buildNumericKeypad() {
    return Container(
      color: const Color(0xFFF8FAFB),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeyboardRow(['1', '2', '3']),
          _buildKeyboardRow(['4', '5', '6']),
          _buildKeyboardRow(['7', '8', '9']),
          _buildKeyboardRow(['.', '0', 'DEL']),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(children: keys.map((key) => _buildKey(key)).toList());
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (key == 'DEL') {
              if (_rawAmount.length > 1) {
                _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
              } else {
                _rawAmount = "0";
              }
            } else if (key == '.') {
            } else {
              if (_rawAmount == "0") {
                _rawAmount = key;
              } else {
                if (_rawAmount.length < 12) {
                  _rawAmount += key;
                }
              }
            }
          });
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.divider.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Center(
            child: key == 'DEL'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  )
                : Text(
                    key,
                    style: AppStyles.heading2.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForName(String name) {
    if (name.contains('salary')) return Icons.payments_outlined;
    if (name.contains('business')) return Icons.business_center_outlined;
    if (name.contains('bonus')) return Icons.stars_outlined;
    if (name.contains('invest')) return Icons.show_chart_outlined;
    if (name.contains('food')) return Icons.fastfood_outlined;
    if (name.contains('transport')) return Icons.directions_car_outlined;
    if (name.contains('shopping')) return Icons.shopping_bag_outlined;
    if (name.contains('entertainment')) return Icons.sports_esports_outlined;
    if (name.contains('home')) return Icons.home_outlined;
    if (name.contains('heart')) return Icons.favorite_border_outlined;
    if (name.contains('cafe')) return Icons.local_cafe_outlined;
    if (name.contains('travel')) return Icons.flight_takeoff_outlined;
    if (name.contains('education')) return Icons.school_outlined;
    return Icons.category_outlined;
  }

  void _saveBudget() {
    final amount = double.tryParse(_rawAmount) ?? 0;
    if (amount <= 0) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final budget = BudgetEntity(
      id: '',
      userId: user.uid,
      categoryName: _selectedCategory?.name ?? 'Uncategorized',
      amount: amount,
      period: _selectedPeriod,
      remindMe: _remindMe,
      createdAt: DateTime.now(),
    );

    context.read<AddBudgetBloc>().add(SaveBudgetEvent(budget));
  }
}
