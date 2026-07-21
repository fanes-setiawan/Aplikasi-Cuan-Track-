import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../bloc/debt_bloc.dart';
import '../bloc/debt_event.dart';
import '../bloc/debt_state.dart';
import 'add_debt_screen.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/debt_entity.dart';
import 'installment_detail_screen.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      context.read<DebtBloc>().add(LoadDebts(_userId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPaymentDialog(BuildContext context, DebtEntity debt) {
    final remaining = debt.amount - debt.paidAmount;
    if (remaining <= 0) return;
    final TextEditingController amountController = TextEditingController();

    if (debt.isInstallment) {
      amountController.text = NumberFormat.decimalPattern(
        'id_ID',
      ).format(debt.monthlyPayment.toInt());
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            debt.isInstallment
                ? 'Bayar Cicilan Bulan ke-${debt.paidMonths + 1}'
                : 'Bayar Cicilan',
            style: AppStyles.heading2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                debt.isInstallment
                    ? 'Nominal Cicilan: ${AppHelpers.formatCurrencyIdr(debt.monthlyPayment)}\nSisa Total: ${AppHelpers.formatCurrencyIdr(remaining)}'
                    : 'Sisa: ${AppHelpers.formatCurrencyIdr(remaining)}',
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.paddingV16),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Nominal Bayar',
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppStyles.bodyText),
            ),
            ElevatedButton(
              onPressed: () {
                final numericAmount = amountController.text.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                final amount = double.tryParse(numericAmount) ?? 0;
                if (amount > 0) {
                  context.read<DebtBloc>().add(
                    AddPaymentToDebt(
                      userId: _userId,
                      debtId: debt.id,
                      amount: amount,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDebtOptions(BuildContext context, DebtEntity debt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusL),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.paddingV24,
            horizontal: AppSizes.padding16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opsi ${debt.type == 'hutang' ? 'Hutang' : 'Piutang'}',
                style: AppStyles.heading2,
              ),
              SizedBox(height: AppSizes.paddingV16),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: Text('Lihat Detail', style: AppStyles.bodyText),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDebtDetails(context, debt);
                },
              ),
              if (!debt.isPaid)
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.green),
                  title: Text('Bayar Cicilan', style: AppStyles.bodyText),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddPaymentDialog(context, debt);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.orange),
                title: Text('Edit Catatan', style: AppStyles.bodyText),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDebtScreen(debt: debt),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  'Hapus',
                  style: AppStyles.bodyText.copyWith(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmDialog(context, debt);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDebtDetails(BuildContext context, DebtEntity debt) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
          title: Text('Detail Transaksi', style: AppStyles.heading2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (debt.title.isNotEmpty) _detailRow('Judul', debt.title),
                _detailRow('Nama', debt.personName),
                if (debt.isInstallment) ...[
                  _detailRow(
                    'Jenis',
                    'Cicilan / Angsuran (${debt.totalMonths} Bulan)',
                  ),
                  _detailRow(
                    'Cicilan',
                    '${AppHelpers.formatCurrencyIdr(debt.monthlyPayment)} / Bulan',
                  ),
                  _detailRow('Sudah Bayar', '${debt.paidMonths} Bulan'),
                  _detailRow(
                    'Sisa Tenor',
                    '${debt.totalMonths - debt.paidMonths} Bulan',
                  ),
                ],
                _detailRow('Total', AppHelpers.formatCurrencyIdr(debt.amount)),
                _detailRow(
                  'Terbayar',
                  AppHelpers.formatCurrencyIdr(debt.paidAmount),
                ),
                _detailRow(
                  'Sisa',
                  AppHelpers.formatCurrencyIdr(debt.amount - debt.paidAmount),
                ),
                _detailRow('Status', debt.isPaid ? 'Lunas' : 'Belum Lunas'),
                _detailRow(
                  'Tempo',
                  DateFormat('dd MMM yyyy').format(debt.dueDate),
                ),
                if (debt.description.isNotEmpty)
                  _detailRow('Keterangan', debt.description),
                if (debt.isInstallment && debt.totalMonths > 0) ...[
                  SizedBox(height: AppSizes.paddingV16),
                  const Divider(),
                  SizedBox(height: AppSizes.paddingV8),
                  Text(
                    'Status Pembayaran Bulanan',
                    style: AppStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingV12),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: List.generate(debt.totalMonths, (index) {
                        final startMonth = debt.dueDate.month; // 1-based
                        final targetMonthIndex = (startMonth - 1 + index) % 12;
                        final monthsList = [
                          'Januari',
                          'Februari',
                          'Maret',
                          'April',
                          'Mei',
                          'Juni',
                          'Juli',
                          'Agustus',
                          'September',
                          'Oktober',
                          'November',
                          'Desember',
                        ];
                        final monthLabel = monthsList[targetMonthIndex];
                        final targetYear =
                            debt.dueDate.year + (startMonth - 1 + index) ~/ 12;

                        final isPaidMonth = debt.paidInstallmentMonths.contains(
                          index,
                        );

                        return Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.paddingV8,
                            horizontal: AppSizes.padding4,
                          ),
                          decoration: BoxDecoration(
                            color: isPaidMonth
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: isPaidMonth
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius8,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPaidMonth
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isPaidMonth ? Colors.green : Colors.grey,
                                size: 16,
                              ),
                              SizedBox(height: AppSizes.paddingV4),
                              Text(
                                monthLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isPaidMonth
                                      ? Colors.green[800]
                                      : Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                targetYear.toString(),
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPaidMonth ? 'Lunas' : 'Belum',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isPaidMonth
                                      ? Colors.green[600]
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, DebtEntity debt) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Hapus Catatan', style: AppStyles.heading2),
          content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DebtBloc>().add(DeleteDebt(_userId, debt.id));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DebtBloc, DebtState>(
      listener: (context, state) {
        if (state is AddDebtPaymentSuccess) {
          if (state.isPaidOff) {
            AppHelpers.showSnackBar(
              context,
              'Lunas! Hutang/Piutang atas nama ${state.debt.personName} telah lunas.',
            );
          } else {
            AppHelpers.showSnackBar(context, 'Berhasil mencatat pembayaran');
          }
        } else if (state is DebtError) {
          AppHelpers.showSnackBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: EdgeInsets.all(AppSizes.padding8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
          title: Text('Hutang & Piutang', style: AppStyles.heading2),
          centerTitle: false,
        ),
        body: BlocBuilder<DebtBloc, DebtState>(
          builder: (context, state) {
            if (state is DebtLoading || state is DebtInitial) {
              return _buildDebtShimmer();
            }

            if (state is DebtLoaded) {
              final totalHutang = state.debts
                  .where((d) => d.type == 'hutang')
                  .fold(0.0, (sum, d) => sum + (d.amount - d.paidAmount));
              final totalPiutang = state.debts
                  .where((d) => d.type == 'piutang')
                  .fold(0.0, (sum, d) => sum + (d.amount - d.paidAmount));

              final hutangList = state.debts
                  .where((d) => d.type == 'hutang')
                  .toList();
              final piutangList = state.debts
                  .where((d) => d.type == 'piutang')
                  .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'HUTANG SAYA',
                            totalHutang,
                            true,
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: _buildSummaryCard(
                            'PIUTANG SAYA',
                            totalPiutang,
                            false,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textHint,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: AppStyles.bodyText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: const [
                      Tab(text: 'Daftar Hutang'),
                      Tab(text: 'Daftar Piutang'),
                    ],
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDebtList(hutangList, 'Hutang'),
                        _buildDebtList(piutangList, 'Piutang'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddDebtScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Tambah Catatan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: AppSizes.paddingV16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, bool isHutang) {
    final bgColor = isHutang
        ? const Color(0xFFFFF1F1)
        : const Color(0xFFF1FFF8);
    final accentColor = isHutang
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final icon = isHutang ? Icons.north_east : Icons.south_west;
    final subtitle = isHutang
        ? 'Total yang harus dibayar'
        : 'Total yang akan diterima';

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 16),
              SizedBox(width: AppSizes.padding4),
              Text(
                title,
                style: AppStyles.caption.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.font10,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingV8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppHelpers.formatCurrencyIdr(amount),
              style: AppStyles.heading2.copyWith(
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppSizes.paddingV4),
          Text(
            subtitle,
            style: AppStyles.caption.copyWith(
              color: accentColor.withOpacity(0.6),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(List debts, String typeName) {
    if (debts.isEmpty) {
      return EmptyState(
        title: 'Tidak ada data $typeName',
        subtitle:
            'Mulai catat $typeName Anda untuk melacak keuangan dengan lebih rinci.',
        imageWidth: 100,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimens.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.76,
      ),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final DebtEntity debt = debts[index];
        final dateStr = DateFormat('dd MMM yyyy').format(debt.dueDate);
        final isOverdue = !debt.isPaid && debt.dueDate.isBefore(DateTime.now());
        final isHutang = debt.type == 'hutang';
        final accentColor = isHutang
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981);
        final lightAccentColor = isHutang
            ? const Color(0xFFFFF1F1)
            : const Color(0xFFF1FFF8);

        IconData itemIcon = Icons.person_outline;
        if (debt.description.toLowerCase().contains('toko') ||
            debt.description.toLowerCase().contains('warung')) {
          itemIcon = Icons.shopping_cart_outlined;
        } else if (debt.description.toLowerCase().contains('sewa') ||
            debt.description.toLowerCase().contains('kontrakan')) {
          itemIcon = Icons.home_outlined;
        } else if (debt.isInstallment) {
          itemIcon = Icons.replay;
        }

        return GestureDetector(
          onTap: () {
            if (debt.isInstallment) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      InstallmentDetailScreen(debt: debt, userId: _userId),
                ),
              );
            } else {
              _showDebtOptions(context, debt);
            }
          },
          onLongPress: () {
            _showDebtOptions(context, debt);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radius16),
              border: Border.all(
                color: isOverdue
                    ? const Color(0xFFEF4444).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                width: isOverdue ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.padding12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSizes.padding8),
                        decoration: BoxDecoration(
                          color: lightAccentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(itemIcon, color: accentColor, size: 16),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.padding8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: debt.isPaid
                              ? const Color(0xFFE8F5E9)
                              : (isOverdue
                                    ? const Color(0xFFFFF1F1)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          debt.isPaid
                              ? 'LUNAS'
                              : (isOverdue ? 'TERLAMBAT' : 'AKTIF'),
                          style: TextStyle(
                            color: debt.isPaid
                                ? Colors.green
                                : (isOverdue
                                      ? const Color(0xFFEF4444)
                                      : AppColors.textHint),
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.title.isNotEmpty ? debt.title : debt.personName,
                        style: AppStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (debt.title.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          debt.personName,
                          style: AppStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: AppSizes.font10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: AppSizes.paddingV4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppHelpers.formatCurrencyIdr(debt.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (debt.isInstallment) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.replay,
                              color: AppColors.primary,
                              size: 10,
                            ),
                            SizedBox(width: AppSizes.padding4),
                            Expanded(
                              child: Text(
                                '${debt.paidMonths}/${debt.totalMonths} Bln',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.font10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppHelpers.formatCurrencyIdr(debt.monthlyPayment)}/bln',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        Text(
                          'Non-Cicilan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: AppSizes.font10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sekali bayar',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 9,
                          ),
                        ),
                      ],
                      SizedBox(height: AppSizes.paddingV4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: isOverdue
                                ? const Color(0xFFEF4444)
                                : AppColors.textHint,
                            size: 9,
                          ),
                          SizedBox(width: AppSizes.padding4),
                          Expanded(
                            child: Text(
                              isOverdue ? 'Lewat: $dateStr' : 'Tempo: $dateStr',
                              style: TextStyle(
                                color: isOverdue
                                    ? const Color(0xFFEF4444)
                                    : AppColors.textHint,
                                fontWeight: isOverdue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebtShimmer() {
    return SingleChildScrollView(
      child: AppShimmer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.md),
              child: Row(
                children: [
                  Expanded(
                    child: AppShimmer.rectangular(
                      height: 80,
                      borderRadius: AppDimens.radiusL,
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: AppShimmer.rectangular(
                      height: 80,
                      borderRadius: AppDimens.radiusL,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              child: Row(
                children: [
                  Expanded(child: AppShimmer.rectangular(height: 40)),
                  Expanded(child: AppShimmer.rectangular(height: 40)),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.76,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return AppShimmer.rectangular(
                    height: 180,
                    borderRadius: 16.0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
