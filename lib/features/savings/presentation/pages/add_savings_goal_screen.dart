import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../domain/entities/savings_goal_entity.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final numericAmount = _amountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final amount = double.tryParse(numericAmount) ?? 0;

      final goal = SavingsGoalEntity(
        id: const Uuid().v4(),
        title: _titleController.text,
        targetAmount: amount,
        currentAmount: 0,
        deadline: _selectedDeadline!,
      );

      context.read<SavingsBloc>().add(AddSavingsGoal(user.uid, goal));
      Navigator.pop(context);
    } else if (_selectedDeadline == null) {
      AppHelpers.showSnackBar(
        context,
        'Silakan pilih tenggat waktu',
        isError: true,
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDeadline = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Buat Target', style: AppStyles.heading2),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama Target',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Cth: Liburan ke Bali, Beli Laptop...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama target wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Text(
                'Nominal Target',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyFormatter()],
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nominal wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Text(
                'Tenggat Waktu / Deadline',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDeadline != null
                            ? '${_selectedDeadline!.day} / ${_selectedDeadline!.month} / ${_selectedDeadline!.year}'
                            : 'Pilih Tanggal',
                        style: AppStyles.bodyText.copyWith(
                          color: _selectedDeadline != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                  child: const Text(
                    'Simpan Target',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
