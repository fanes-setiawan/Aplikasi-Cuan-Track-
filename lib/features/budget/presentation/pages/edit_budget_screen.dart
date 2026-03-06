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

    // Formatting the initial amount correctly so the numeric keypad works
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Edit Anggaran',
          style: AppStyles.heading2.copyWith(fontWeight: FontWeight.bold),
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
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
                                            color: const Color(0xFF27AE60),
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            cat.name,
                                            style: AppStyles.bodyText.copyWith(
                                              fontWeight: FontWeight.w600,
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
                      const SizedBox(height: 24),
                      Text(
                        'BATAS ANGGARAN',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSelectionContainer(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.money,
                              color: Color(0xFF27AE60),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
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
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _formattedAmount,
                                      style: AppStyles.heading2.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PERIODE',
                        style: AppStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSelectionContainer(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod.isEmpty
                                ? 'Bulanan'
                                : _selectedPeriod,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
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
                                    const SizedBox(width: 12),
                                    Text(
                                      period,
                                      style: AppStyles.bodyText.copyWith(
                                        fontWeight: FontWeight.w600,
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
                      const SizedBox(height: 24),
                      _buildSelectionContainer(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_active,
                                color: Color(0xFF27AE60),
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
                                    'Beritahu saat mencapai 80% limit',
                                    style: AppStyles.caption.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
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
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: state is EditBudgetLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Simpan Perubahan',
                                style: AppStyles.bodyText.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Batal',
                          style: AppStyles.bodyText.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Text('Masukkan Nominal', style: AppStyles.heading3),
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
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'Rp $_formattedAmount',
                      style: AppStyles.heading1,
                    ),
                  ),
                  _buildKeyboardRow(['1', '2', '3'], setModalState),
                  _buildKeyboardRow(['4', '5', '6'], setModalState),
                  _buildKeyboardRow(['7', '8', '9'], setModalState),
                  _buildKeyboardRow(['.', '0', 'DEL'], setModalState),
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

  void _updateAmount(String key) {
    if (key == 'DEL') {
      if (_rawAmount.length > 1) {
        _rawAmount = _rawAmount.substring(0, _rawAmount.length - 1);
      } else {
        _rawAmount = "0";
      }
    } else if (key == '.') {
      // ignore decimal for IDR format
    } else {
      if (_rawAmount == "0") {
        _rawAmount = key;
      } else {
        // limit length to avoid overflow
        if (_rawAmount.length < 12) {
          _rawAmount += key;
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
