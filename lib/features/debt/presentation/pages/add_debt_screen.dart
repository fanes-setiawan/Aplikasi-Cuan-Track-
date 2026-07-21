import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../domain/entities/debt_entity.dart';
import '../bloc/debt_bloc.dart';
import '../bloc/debt_event.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtEntity? debt;
  const AddDebtScreen({super.key, this.debt});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime? _selectedDeadline;
  DateTime? _selectedStartDate;
  String _selectedType = 'hutang';

  bool _isInstallment = false;
  final _monthsController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.debt?.startDate ?? DateTime.now();
    if (widget.debt != null) {
      _nameController.text = widget.debt!.personName;
      _amountController.text = widget.debt!.amount.toInt().toString();
      _descriptionController.text = widget.debt!.description;
      _titleController.text = widget.debt!.title;
      _selectedDeadline = widget.debt!.dueDate;
      _selectedType = widget.debt!.type;
      _isInstallment = widget.debt!.isInstallment;
      if (_isInstallment) {
        _monthsController.text = widget.debt!.totalMonths.toString();
        _monthlyPaymentController.text = widget.debt!.monthlyPayment
            .toInt()
            .toString();
      }
    }
    _monthsController.addListener(_calculateTotalAmount);
    _monthlyPaymentController.addListener(_calculateTotalAmount);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    _monthsController.dispose();
    _monthlyPaymentController.dispose();
    super.dispose();
  }

  void _calculateTotalAmount() {
    if (!_isInstallment) return;
    final months = int.tryParse(_monthsController.text) ?? 0;
    final monthlyVal = _monthlyPaymentController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final monthlyPayment = int.tryParse(monthlyVal) ?? 0;

    if (months > 0 && monthlyPayment > 0) {
      final total = months * monthlyPayment;
      final formatter = NumberFormat.decimalPattern('id_ID');
      setState(() {
        _amountController.text = formatter.format(total);
      });
    }
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final numericAmount = _amountController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final amount = double.tryParse(numericAmount) ?? 0;

      int totalMonths = 0;
      double monthlyPayment = 0.0;

      if (_isInstallment) {
        totalMonths = int.tryParse(_monthsController.text) ?? 0;
        final numericMonthly = _monthlyPaymentController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        monthlyPayment = double.tryParse(numericMonthly) ?? 0.0;
      }

      final debt = DebtEntity(
        id: widget.debt?.id ?? const Uuid().v4(),
        personName: _nameController.text,
        type: _selectedType,
        amount: amount,
        paidAmount: widget.debt?.paidAmount ?? 0,
        dueDate: _selectedDeadline!,
        startDate: _selectedStartDate,
        description: _descriptionController.text.trim(),
        title: _titleController.text.trim(),
        isInstallment: _isInstallment,
        totalMonths: totalMonths,
        paidInstallmentMonths: widget.debt?.paidInstallmentMonths ?? const [],
        monthlyPayment: monthlyPayment,
      );

      if (widget.debt != null) {
        context.read<DebtBloc>().add(UpdateDebt(user.uid, debt));
      } else {
        context.read<DebtBloc>().add(AddDebt(user.uid, debt));
      }
      Navigator.pop(context);
    } else if (_selectedDeadline == null) {
      AppHelpers.showSnackBar(
        context,
        'Silakan pilih tenggat waktu pembayaran',
        isError: true,
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
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

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedStartDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.debt != null ? 'Edit Catatan' : 'Catat Transaksi',
          style: AppStyles.heading2,
        ),
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
                'Jenis Transaksi',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.paddingV8),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      'Hutang Saya',
                      'hutang',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: _buildTypeButton(
                      'Piutang (Dipinjam)',
                      'piutang',
                      Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.paddingV16),

              Text(
                'Judul Transaksi (Opsional)',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.paddingV8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Cth: Bank BRI, Cicilan Motor...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingV16),

              Text(
                'Nama Orang',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.paddingV8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Cth: Budi, Andi...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama wajib diisi' : null,
              ),
              SizedBox(height: AppSizes.paddingV16),

              Text(
                'Nominal Rp',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.paddingV8),
              TextFormField(
                controller: _amountController,
                readOnly: _isInstallment,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyFormatter()],
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  filled: true,
                  fillColor: _isInstallment ? Colors.grey[200] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nominal wajib diisi' : null,
              ),
              SizedBox(height: AppSizes.paddingV16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catat Sebagai Angsuran / Cicilan',
                    style: AppStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _isInstallment,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        _isInstallment = val;
                        if (!val) {
                          _monthsController.clear();
                          _monthlyPaymentController.clear();
                          _amountController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: AppSizes.paddingV16),

              if (_isInstallment) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tenor (Bulan)',
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSizes.paddingV8),
                          TextFormField(
                            controller: _monthsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Cth: 12',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusM,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (_isInstallment &&
                                  (value == null || value.isEmpty)) {
                                return 'Tenor wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cicilan Per Bulan',
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSizes.paddingV8),
                          TextFormField(
                            controller: _monthlyPaymentController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyFormatter()],
                            decoration: InputDecoration(
                              prefixText: 'Rp ',
                              hintText: '0',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusM,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (_isInstallment &&
                                  (value == null || value.isEmpty)) {
                                return 'Cicilan wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.paddingV16),
              ],

              Text(
                'Keterangan (Opsional)',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.paddingV8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Cth: Pinjaman Modal, Jajan...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingV16),

              if (_isInstallment) ...[
                Text(
                  'Tanggal Mulai Cicilan',
                  style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSizes.paddingV8),
                GestureDetector(
                  onTap: _pickStartDate,
                  child: Container(
                    padding: EdgeInsets.all(AppSizes.padding16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedStartDate != null
                              ? '${_selectedStartDate!.day} / ${_selectedStartDate!.month} / ${_selectedStartDate!.year}'
                              : 'Pilih Tanggal Mulai',
                          style: AppStyles.bodyText.copyWith(
                            color: _selectedStartDate != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.paddingV16),
              ],

              Text(
                'Tenggat Waktu Pembayaran',
                style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: AppSizes.paddingV8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.all(AppSizes.padding16),
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
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSizes.paddingV32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveDebt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.font16,
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

  Widget _buildTypeButton(String title, String type, Color color) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: AppStyles.bodyText.copyWith(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
