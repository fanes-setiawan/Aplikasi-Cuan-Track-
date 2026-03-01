import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/bloc/home_event.dart';
import '../bloc/add_transaction_bloc.dart';
import '../bloc/add_transaction_event.dart';
import '../bloc/add_transaction_state.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isIncome;
  const AddTransactionScreen({super.key, this.isIncome = true});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _rawAmount = "0";
  late String _selectedCategory;
  late List<String> _categories;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();

  final Map<String, String> _categoryIconMap = {
    "Gaji": "income_salary",
    "Bonus": "income_bonus",
    "Investasi": "income_invest",
    "Makan": "expense_food",
    "Transport": "expense_transport",
    "Belanja": "expense_shopping",
  };

  @override
  void initState() {
    super.initState();
    _categories = widget.isIncome
        ? ["Gaji", "Bonus", "Investasi"]
        : ["Makan", "Transport", "Belanja"];
    _selectedCategory = _categories[0];
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
          style: AppStyles.heading2,
        ),
      ),
      body: BlocConsumer<AddTransactionBloc, AddTransactionState>(
        listener: (context, state) {
          if (state is AddTransactionSuccess) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              context.read<HomeBloc>().add(LoadHomeData(user.uid));
            }
            Navigator.pop(context);
          } else if (state is AddTransactionFailure) {
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
                      // Nominal Display
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'NOMINAL',
                              style: AppStyles.caption.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
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
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                      const SizedBox(height: AppDimens.xl + 10),

                      // Category Selection
                      Text(
                        'Pilih Kategori',
                        style: AppStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimens.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ..._categories.map(
                              (cat) => _buildCategoryChip(cat),
                            ),
                            _buildAddCategoryButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimens.xl),

                      // Date Selection
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

                      // Note Input
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.md,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusM,
                          ),
                          border: Border.all(
                            color: AppColors.divider.withOpacity(0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            icon: const Icon(
                              Icons.notes,
                              color: AppColors.textSecondary,
                            ),
                            hintText: 'Tambah catatan...',
                            border: InputBorder.none,
                            hintStyle: AppStyles.bodyText.copyWith(
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                          style: AppStyles.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Custom Numeric Keypad
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                _buildNumericKeypad(),
              // Save Button
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
                        ? const SizedBox(
                            height: 24,
                            width: 24,
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

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.round),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              label == "Gaji"
                  ? Icons.payments_outlined
                  : label == "Bonus"
                  ? Icons.stars_outlined
                  : label == "Investasi"
                  ? Icons.show_chart_outlined
                  : label == "Makan"
                  ? Icons.restaurant
                  : label == "Transport"
                  ? Icons.directions_car
                  : Icons.shopping_bag,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppStyles.bodyText.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider, style: BorderStyle.none),
      ),
      child: Icon(
        Icons.add_circle_outline,
        color: AppColors.textSecondary.withOpacity(0.3),
        size: 32,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: AppStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary.withOpacity(0.6),
                      ),
                    ),
                  Text(
                    value,
                    style: AppStyles.bodyText.copyWith(
                      color: isNote
                          ? AppColors.textSecondary.withOpacity(0.5)
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isNote)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      color: const Color(0xFFF8FAFB),
      child: Column(
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

  void _saveTransaction() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Parse amount
    final amountParsed = double.tryParse(_rawAmount) ?? 0.0;

    if (amountParsed <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nominal tidak boleh nol.")));
      return;
    }

    final entity = TransactionEntity(
      id: '', // Firestore auto-generates
      userId: user.uid,
      title: widget.isIncome ? "Pemasukan" : "Pengeluaran",
      amount: amountParsed,
      type: widget.isIncome ? 'income' : 'expense',
      categoryId: _categoryIconMap[_selectedCategory] ?? _selectedCategory,
      categoryName: _selectedCategory,
      date: _selectedDate,
      notes: _noteController.text.trim(),
    );

    context.read<AddTransactionBloc>().add(SubmitTransaction(entity));
  }
}
