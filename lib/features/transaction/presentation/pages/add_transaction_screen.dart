import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../injection_container.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/services/audio_service.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../bloc/add_transaction_bloc.dart';
import '../bloc/add_transaction_event.dart';
import '../bloc/add_transaction_state.dart';
import 'package:cuan_track/features/category/domain/entities/category_entity.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_bloc.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_state.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_event.dart';
import 'package:cuan_track/features/profile/presentation/pages/add_category_sheet.dart';
import 'package:cuan_track/features/payment_method/domain/entities/payment_method_entity.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_bloc.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_state.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_event.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isIncome;
  final TransactionEntity? transactionForEdit;
  final double? initialAmount;
  final String? initialNote;

  const AddTransactionScreen({
    super.key,
    this.isIncome = true,
    this.transactionForEdit,
    this.initialAmount,
    this.initialNote,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _rawAmount = "0";
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  PaymentMethodEntity? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<PaymentMethodBloc>().add(LoadPaymentMethods(user.uid));
      context.read<CategoryBloc>().add(LoadCategories(user.uid));
    }

    if (widget.transactionForEdit != null) {
      final t = widget.transactionForEdit!;
      _rawAmount = t.amount.toStringAsFixed(0);
      _selectedDate = t.date;
      _noteController.text = t.notes ?? '';
      if (t.categoryId.isNotEmpty && t.categoryName != null) {
        _selectedCategory = CategoryEntity(
          id: t.categoryId,
          userId: t.userId,
          name: t.categoryName!,
          iconName: 'category',
          colorHex: '#27AE60',
          type: t.type,
        );
      }
      if (t.paymentMethodId != null) {
        _selectedPaymentMethod = PaymentMethodEntity(
          id: t.paymentMethodId!,
          userId: t.userId,
          name: 'Loading...',
          type: 'Tunai',
          accountNumber: '',
          balance: 0.0,
          iconPath: '',
        );
      }
    } else {
      if (widget.initialAmount != null && widget.initialAmount! > 0) {
        _rawAmount = widget.initialAmount!.toStringAsFixed(0);
      }
      if (widget.initialNote != null) {
        _noteController.text = widget.initialNote!;
      }
    }
  }

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
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
          style: AppStyles.heading2.copyWith(color: Colors.white),
        ),
      ),
      body: BlocConsumer<AddTransactionBloc, AddTransactionState>(
        listener: (context, state) {
          if (state is AddTransactionSuccess) {
            if (widget.isIncome) {
              AudioService().playIncome();
            } else {
              AudioService().playSuccess();
            }
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              context.read<HomeBloc>().add(LoadHomeData(user.uid));
            }
            sl<AdService>().showInterstitialAd();
            Navigator.pop(context);
          } else if (state is AddTransactionFailure) {
            AudioService().playError();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimens.xl),
                      GestureDetector(
                        onTap: () {
                          _showNumericKeypadBottomSheet();
                        },
                        child: Center(
                          child: Column(
                          children: [
                            Text(
                              'NOMINAL',
                              style: AppStyles.caption.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: AppDimens.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'Rp',
                                  style: AppStyles.heading1.copyWith(
                                    color: AppColors.primary,
                                    fontSize: AppSizes.font24,
                                  ),
                                ),
                                SizedBox(width: AppSizes.padding8),
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
                          ],
                        ),
                      ),
                      ),
                      const SizedBox(height: AppDimens.xl + 10),

                      Text(
                        'Pilih Kategori',
                        style: AppStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading ||
                              state is CategoryInitial) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppDimens.md),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is CategoryLoaded) {
                            final filteredCategories = state.categories
                                .where(
                                  (c) =>
                                      c.type ==
                                      (widget.isIncome ? 'income' : 'expense'),
                                )
                                .toList();

                            if (filteredCategories.isNotEmpty) {
                              _selectedCategory ??= filteredCategories.first;
                            }

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...filteredCategories.map(
                                    (cat) => _buildCategoryChip(cat),
                                  ),
                                  _buildAddCategoryButton(),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: AppDimens.xl),

                      BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                        builder: (context, state) {
                          String value = "Loading...";
                          if (state is PaymentMethodLoaded) {
                            if (state.paymentMethods.isNotEmpty) {
                              if (widget.transactionForEdit != null &&
                                  _selectedPaymentMethod != null) {
                                _selectedPaymentMethod = state.paymentMethods
                                    .firstWhere(
                                      (method) =>
                                          method.id ==
                                          _selectedPaymentMethod!.id,
                                      orElse: () => state.paymentMethods.first,
                                    );
                              } else {
                                _selectedPaymentMethod ??=
                                    state.paymentMethods.first;
                              }
                              value = _selectedPaymentMethod!.name;
                            } else {
                              value = "Belum ada metode";
                            }
                          } else if (state is PaymentMethodError) {
                            value = "Error";
                          }

                          return _buildInputTile(
                            label: 'METODE PEMBAYARAN',
                            value: value,
                            icon: Icons.account_balance_wallet_outlined,
                            onTap: () async {
                              if (state is PaymentMethodLoaded &&
                                  state.paymentMethods.isNotEmpty) {
                                final selected =
                                    await showModalBottomSheet<
                                      PaymentMethodEntity
                                    >(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF0F172A),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(height: AppSizes.paddingV16),
                                              Container(
                                                height: 5,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF1E293B),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              SizedBox(height: AppSizes.paddingV16),
                                              Text(
                                                'Pilih Metode Pembayaran',
                                                style: AppStyles.heading2.copyWith(color: Colors.white),
                                              ),
                                              SizedBox(height: AppSizes.paddingV16),
                                              ...state.paymentMethods.map(
                                                (m) => ListTile(
                                                  leading: Container(
                                                    padding:
                                                        EdgeInsets.all(AppSizes.padding8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF1E293B,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      m.type == 'Tunai'
                                                          ? Icons
                                                                .payments_outlined
                                                          : Icons
                                                                .account_balance_wallet,
                                                      color: const Color(
                                                        0xFF94A3B8,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    m.name,
                                                    style: AppStyles.bodyText
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                  subtitle: Text(
                                                    m.type,
                                                    style: AppStyles.caption.copyWith(color: const Color(0xFF94A3B8)),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context, m);
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: AppSizes.paddingV32),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                if (selected != null) {
                                  setState(() {
                                    _selectedPaymentMethod = selected;
                                  });
                                }
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppDimens.md),

                      _buildInputTile(
                        label: 'TANGGAL',
                        value: DateFormat(
                          'EEEE, dd MMM yyyy',
                          'id_ID',
                        ).format(_selectedDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppDimens.md),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
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
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.notes,
                              color: Color(0xFF94A3B8),
                            ),
                            hintText: 'Tambah catatan...',
                            border: InputBorder.none,
                            hintStyle: AppStyles.bodyText.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          style: AppStyles.bodyText.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.md),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: state is AddTransactionLoading
                        ? null
                        : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      ),
                      elevation: 0,
                    ),
                    child: state is AddTransactionLoading
                        ? SizedBox(
                            height: AppSizes.paddingV24,
                            width: AppSizes.padding24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Simpan Transaksi',
                            style: AppStyles.bodyText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(CategoryEntity category) {
    bool isSelected = _selectedCategory?.id == category.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(AppDimens.round),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIconForName(category.iconName),
              size: 18,
              color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
            ),
            SizedBox(width: AppSizes.padding8),
            Text(
              category.name,
              style: AppStyles.bodyText.copyWith(
                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
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

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddCategorySheet(
            initialType: widget.isIncome ? 'income' : 'expense',
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E293B), style: BorderStyle.none),
        ),
        child: Icon(
          Icons.add_circle_outline,
          color: const Color(0xFF94A3B8),
          size: 32,
        ),
      ),
    );
  }

  Widget _buildInputTile({
    required String label,
    required String value,
    required IconData icon,
    bool isNote = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF94A3B8), size: 24),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: AppStyles.caption.copyWith(
                        fontSize: AppSizes.font10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  Text(
                    value,
                    style: AppStyles.bodyText.copyWith(
                      color: isNote
                          ? const Color(0xFF94A3B8)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (!isNote)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showNumericKeypadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radius24)),
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
                        Text('Masukkan Nominal', style: AppStyles.heading3.copyWith(color: Colors.white)),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Color(0xFF10B981),
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
    return Row(children: keys.map((key) => _buildKey(key, setModalState)).toList());
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
              color: const Color(0xFF1E293B),
              width: 0.5,
            ),
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

  void _saveTransaction() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final amountParsed = double.tryParse(_rawAmount) ?? 0.0;

    if (amountParsed <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nominal tidak boleh nol.")));
      return;
    }

    final entity = TransactionEntity(
      id: widget.transactionForEdit?.id ?? '',
      userId: user.uid,
      title: widget.isIncome ? "Pemasukan" : "Pengeluaran",
      amount: amountParsed,
      type: widget.isIncome ? 'income' : 'expense',
      categoryId: _selectedCategory?.id ?? '',
      categoryName: _selectedCategory?.name ?? '',
      paymentMethodId: _selectedPaymentMethod?.id,
      date: _selectedDate,
      notes: _noteController.text.trim(),
    );

    if (widget.transactionForEdit != null) {
      context.read<AddTransactionBloc>().add(UpdateTransaction(entity));
    } else {
      context.read<AddTransactionBloc>().add(SubmitTransaction(entity));
    }
  }
}
