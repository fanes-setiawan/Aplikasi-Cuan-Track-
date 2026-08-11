import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_entity.dart';
import '../bloc/edit_budget_bloc.dart';
import '../bloc/edit_budget_event.dart';
import '../bloc/edit_budget_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'package:cuan_track/features/category/domain/entities/category_entity.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_bloc.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_event.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_state.dart';
import '../../../../core/utils/app_helpers.dart';

class EditBudgetScreen extends StatefulWidget {
  final BudgetEntity budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  late String _selectedPeriod;
  late bool _remindMe;
  CategoryEntity? _selectedCategory;
  late String _rawAmount;

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
    _selectedPeriod = widget.budget.period;
    _remindMe = widget.budget.remindMe;

    if (widget.budget.amount == widget.budget.amount.toInt()) {
      _rawAmount = widget.budget.amount.toInt().toString();
    } else {
      _rawAmount = widget.budget.amount.toString();
    }

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(AppSizes.padding8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Colors.white),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Edit Anggaran',
          style: AppStyles.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<EditBudgetBloc, EditBudgetState>(
        listener: (context, state) {
          if (state is EditBudgetSuccess) {
            AppHelpers.showSnackBar(context, 'Anggaran berhasil diperbarui!');
            Navigator.pop(context);
          } else if (state is EditBudgetError) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.lg,
                    vertical: AppDimens.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KATEGORI',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV8),
                      BlocConsumer<CategoryBloc, CategoryState>(
                        listener: (context, catState) {
                          if (catState is CategoryLoaded &&
                              _selectedCategory == null) {
                            final expenseCategories = catState.categories
                                .where((c) => c.type == 'expense')
                                .toList();
                            try {
                              _selectedCategory = expenseCategories.firstWhere(
                                (c) => c.name == widget.budget.categoryName,
                              );
                            } catch (e) {
                              if (expenseCategories.isNotEmpty) {
                                _selectedCategory = expenseCategories.first;
                              }
                            }
                            setState(() {});
                          }
                        },
                        builder: (context, catState) {
                          if (catState is CategoryLoading ||
                              catState is CategoryInitial) {
                            return _buildSelectionContainer(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSizes.padding8),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          } else if (catState is CategoryLoaded) {
                            final expenseCategories = catState.categories
                                .where((c) => c.type == 'expense')
                                .toList();

                            if (expenseCategories.isEmpty) {
                              return _buildSelectionContainer(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSizes.paddingV8,
                                  ),
                                  child: Text(
                                    "Belum ada kategori pengeluaran",
                                    style: AppStyles.bodyText,
                                  ),
                                ),
                              );
                            }

                            return _buildSelectionContainer(
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
                                            color: const Color(0xFF27AE60),
                                            size: 24,
                                          ),
                                          SizedBox(width: AppSizes.padding12),
                                          Text(
                                            cat.name,
                                            style: AppStyles.bodyText.copyWith(
                                              fontWeight: FontWeight.w600,
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
                      SizedBox(height: AppSizes.paddingV24),
                      Text(
                        'BATAS ANGGARAN',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV8),
                      _buildSelectionContainer(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.money,
                              color: Color(0xFF27AE60),
                              size: 24,
                            ),
                            SizedBox(width: AppSizes.padding12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _showNumericKeypadBottomSheet();
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Rp ',
                                      style: AppStyles.heading2.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _formattedAmount,
                                      style: AppStyles.heading2.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV24),
                      Text(
                        'PERIODE',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV8),
                      _buildSelectionContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod.isEmpty
                                ? 'Bulanan'
                                : _selectedPeriod,
                            dropdownColor: const Color(0xFF0F172A),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF94A3B8),
                            ),
                            items: ['Mingguan', 'Bulanan', 'Tahunan'].map((
                              String period,
                            ) {
                              return DropdownMenuItem<String>(
                                value: period,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF27AE60),
                                      size: 24,
                                    ),
                                    SizedBox(width: AppSizes.padding12),
                                    Text(
                                      period,
                                      style: AppStyles.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
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
                                  _selectedPeriod = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.paddingV24),
                      _buildSelectionContainer(
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
                                Icons.notifications_active,
                                color: Color(0xFF27AE60),
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
                                    'Beritahu saat mencapai 80% limit',
                                    style: AppStyles.caption.copyWith(
                                      fontSize: AppSizes.font12,
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
                              activeTrackColor: const Color(0xFF27AE60),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg,
                  vertical: AppDimens.md,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is EditBudgetLoading
                            ? null
                            : _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius16,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: state is EditBudgetLoading
                            ? SizedBox(
                                width: AppSizes.padding24,
                                height: AppSizes.paddingV24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Simpan Perubahan',
                                style: AppStyles.bodyText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.font16,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Batal',
                          style: AppStyles.bodyText.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.font16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionContainer({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.padding16,
        vertical: AppSizes.paddingV12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(AppSizes.radius16),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }

  void _showNumericKeypadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radius24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSizes.padding16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Text(
                          'Masukkan Nominal',
                          style: AppStyles.heading3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Color(0xFF27AE60),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(AppSizes.padding24),
                    alignment: Alignment.center,
                    child: Text(
                      'Rp $_formattedAmount',
                      style: AppStyles.heading1.copyWith(color: Colors.white),
                    ),
                  ),
                  _buildKeyboardRow(['1', '2', '3'], setModalState),
                  _buildKeyboardRow(['4', '5', '6'], setModalState),
                  _buildKeyboardRow(['7', '8', '9'], setModalState),
                  _buildKeyboardRow(['000', '0', 'DEL'], setModalState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKeyboardRow(List<String> keys, StateSetter setModalState) {
    return Row(
      children: keys.map((key) => _buildKey(key, setModalState)).toList(),
    );
  }

  Widget _buildKey(String key, StateSetter setModalState) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setModalState(() {
            _updateAmount(key);
          });
          setState(() {});
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

  void _updateAmount(String key) {
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
    if (amount <= 0) {
      AppHelpers.showSnackBar(
        context,
        'Nominal tidak boleh kosong',
        isError: true,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final updatedBudget = BudgetEntity(
      id: widget.budget.id,
      userId: widget.budget.userId,
      categoryName: _selectedCategory?.name ?? widget.budget.categoryName,
      amount: amount,
      period: _selectedPeriod.isEmpty ? widget.budget.period : _selectedPeriod,
      remindMe: _remindMe,
      createdAt: widget.budget.createdAt,
    );

    context.read<EditBudgetBloc>().add(UpdateBudgetEvent(updatedBudget));
  }
}
