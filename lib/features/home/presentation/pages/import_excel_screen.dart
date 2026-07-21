import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../core/utils/excel_helper.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../category/domain/repositories/category_repository.dart';
import '../../../payment_method/domain/repositories/payment_method_repository.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _previewData = [];
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Transaksi Excel', style: AppStyles.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _previewData.isEmpty
                      ? _buildEmptyState()
                      : _buildPreviewList(),
                ),
                if (_previewData.isNotEmpty) _buildFooter(),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSizes.padding16),
      margin: EdgeInsets.symmetric(horizontal: AppSizes.padding16, vertical: AppSizes.paddingV8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: AppSizes.padding12),
              Expanded(
                child: Text(
                  'Gunakan template kami untuk memastikan format data sudah benar.',
                  style: AppStyles.caption,
                ),
              ),
              TextButton(
                onPressed: _downloadTemplate,
                child: const Text('Unduh Template'),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingV16),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(
              _selectedFile == null ? 'Pilih File Excel' : 'Ganti File',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.move_to_inbox_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          SizedBox(height: AppSizes.paddingV16),
          Text('Belum ada file yang dipilih', style: AppStyles.bodyText),
          SizedBox(height: AppSizes.paddingV8),
          Text(
            'Pilih file .xlsx untuk melihat preview',
            style: AppStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16, vertical: AppSizes.paddingV8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preview Data (${_previewData.length} Baris)',
                style: AppStyles.heading3,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() {
                  _previewData = [];
                  _selectedFile = null;
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16),
            itemCount: _previewData.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = _previewData[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item['title'], style: AppStyles.bodyText),
                subtitle: Text(
                  '${item['categoryName']} • ${item['paymentMethodName']}',
                  style: AppStyles.caption,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item['type'] == 'income' ? '+' : '-'}${AppHelpers.formatCurrencyIdr(item['amount'])}',
                      style: AppStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item['type'] == 'income'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(item['date']),
                      style: AppStyles.caption,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(AppSizes.padding16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _importData,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
          ),
          child: Text('Import Sekarang', style: AppStyles.buttonText),
        ),
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    try {
      await ExcelHelper.generateTemplate();
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(
          context,
          'Gagal mengunduh template: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final file = result.files.first;
        final data = await ExcelHelper.parseExcelFile(file);

        setState(() {
          _selectedFile = file;
          _previewData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppHelpers.showSnackBar(
          context,
          'Gagal membaca file: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _importData() async {
    if (_previewData.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final auth = sl<FirebaseAuth>();
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User tidak terautentikasi');
      }

      final categoryRepo = sl<CategoryRepository>();
      final paymentMethodRepo = sl<PaymentMethodRepository>();
      final transactionRepo = sl<TransactionRepository>();

      final categories = await categoryRepo.watchCategories(userId).first;
      final paymentMethods = await paymentMethodRepo
          .watchPaymentMethods(userId)
          .first;

      int successCount = 0;
      for (var item in _previewData) {
        final category = categories.firstWhere(
          (c) =>
              c.name.toLowerCase() ==
              item['categoryName'].toString().toLowerCase(),
          orElse: () => categories.first,
        );

        final paymentMethod = paymentMethods.firstWhere(
          (p) =>
              p.name.toLowerCase() ==
              item['paymentMethodName'].toString().toLowerCase(),
          orElse: () => paymentMethods.first,
        );

        final transaction = TransactionEntity(
          id: '',
          userId: userId,
          title: item['title'],
          amount: item['amount'],
          type: item['type'],
          categoryId: category.id,
          categoryName: category.name,
          paymentMethodId: paymentMethod.id,
          date: item['date'],
          notes: item['notes'],
        );

        await transactionRepo.addTransaction(transaction);
        successCount++;
      }

      if (mounted) {
        setState(() => _isLoading = false);
        AppHelpers.showSnackBar(
          context,
          'Berhasil mengimport $successCount transaksi',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppHelpers.showSnackBar(
          context,
          'Gagal mengimport data: $e',
          isError: true,
        );
      }
    }
  }
}
