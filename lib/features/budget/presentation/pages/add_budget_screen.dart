import 'package:cuan_track/core/utils/app_sizes.dart';
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
import '../../../../core/services/audio_service.dart';
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
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(Icons.chevron_left, color: Colors.white),
                Text(
                  'Kembali',
                  style: AppStyles.bodyText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Tambah Anggaran',
          style: AppStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body: BlocConsumer<AddBudgetBloc, AddBudgetState>(
        listener: (context, state) {
          if (state is AddBudgetSuccess) {
            AudioService().playSuccess();
            AppHelpers.showSnackBar(context, 'Anggaran berhasil disimpan!');
            Navigator.pop(context);
          } else if (state is AddBudgetError) {
            AudioService().playError();
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
                      SizedBox(height: AppSizes.paddingV16),
                      Text(
                        'LIMIT ANGGARAN',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Rp',
                            style: AppStyles.heading1.copyWith(
                              color: AppColors.primary,
                              fontSize: AppSizes.font24,
                            ),
                          ),
                          SizedBox(width: AppSizes.padding12),
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
                      const Divider(thickness: 1, color: Color(0xFF1E293B)),
                      SizedBox(height: AppSizes.paddingV32),
                      Text(
                        'PILIH KATEGORI',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV12),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading ||
                              state is CategoryInitial) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSizes.padding8),
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
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingV8,
                                ),
                                child: Text(
                                  "Belum ada kategori pengeluaran",
                                  style: AppStyles.bodyText,
                                ),
                              );
                            }

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.padding16,
                                vertical: AppSizes.paddingV4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusM,
                                ),
                                border: Border.all(
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CategoryEntity>(
                                  value: _selectedCategory,
                                  dropdownColor: const Color(0xFF0F172A),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF94A3B8),
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
                                          SizedBox(width: AppSizes.padding12),
                                          Text(
                                            cat.name,
                                            style: AppStyles.bodyText.copyWith(
                                              color: Colors.white,
                                            ),
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
                      SizedBox(height: AppSizes.paddingV32),
                      Text(
                        'PERIODE',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV12),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusM,
                          ),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          children: [
                            _buildPeriodItem('Mingguan'),
                            _buildPeriodItem('Bulanan'),
                            _buildPeriodItem('Tahunan'),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV32),
                      Container(
                        padding: EdgeInsets.all(AppSizes.padding20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusL,
                          ),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radius12,
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_active_outlined,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(width: AppSizes.padding16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ingatkan Saya',
                                    style: AppStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Notifikasi saat mencapai 80% limit',
                                    style: AppStyles.caption.copyWith(
                                      fontSize: AppSizes.font10,
                                      color: const Color(0xFF94A3B8),
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
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV32),
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
                    ? SizedBox(
                        width: AppSizes.padding24,
                        height: AppSizes.paddingV24,
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
          padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            border: Border.all(
              color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: AppStyles.bodyText.copyWith(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : const Color(0xFF94A3B8),
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
      color: const Color(0xFF020617),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeyboardRow(['1', '2', '3']),
          _buildKeyboardRow(['4', '5', '6']),
          _buildKeyboardRow(['7', '8', '9']),
          _buildKeyboardRow(['000', '0', 'DEL']),
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
            } else {
              if (_rawAmount == "0") {
                if (key != '000' && key != '0') {
                  _rawAmount = key;
                }
              } else {
                if (_rawAmount.length < 12) {
                  _rawAmount += key;
                  if (_rawAmount.length > 12) {
                    _rawAmount = _rawAmount.substring(0, 12);
                  }
                }
              }
            }
          });
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF1E293B), width: 0.5),
          ),
          child: Center(
            child: key == 'DEL'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  )
                : Text(
                    key,
                    style: AppStyles.heading2.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
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
