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

  void _showAddPaymentDialog(
    BuildContext context,
    String debtId,
    double remaining,
  ) {
    if (remaining <= 0) return;
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Bayar Cicilan', style: AppStyles.heading2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sisa: ${AppHelpers.formatCurrencyIdr(remaining)}',
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
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
                      debtId: debtId,
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
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opsi ${debt.type == 'hutang' ? 'Hutang' : 'Piutang'}',
                style: AppStyles.heading2,
              ),
              const SizedBox(height: 16),
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
                    final remaining = debt.amount - debt.paidAmount;
                    _showAddPaymentDialog(context, debt.id, remaining);
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
          title: Text('Detail', style: AppStyles.heading2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Nama', debt.personName),
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
            ],
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
                margin: const EdgeInsets.all(8),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(width: 4),
              Text(
                title,
                style: AppStyles.caption.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppHelpers.formatCurrencyIdr(amount),
            style: AppStyles.heading2.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
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

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.md),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final dateStr = DateFormat('dd MMM yyyy').format(debt.dueDate);
        final isOverdue = !debt.isPaid && debt.dueDate.isBefore(DateTime.now());

        IconData itemIcon = Icons.person_outline;
        if (debt.description.toLowerCase().contains('toko') ||
            debt.description.toLowerCase().contains('warung')) {
          itemIcon = Icons.shopping_cart_outlined;
        } else if (debt.description.toLowerCase().contains('sewa') ||
            debt.description.toLowerCase().contains('kontrakan')) {
          itemIcon = Icons.home_outlined;
        }

        return GestureDetector(
          onTap: () {
            _showDebtOptions(context, debt);
          },
          onLongPress: () {
            _showDebtOptions(context, debt);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusL),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    itemIcon,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            debt.personName,
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.error,
                              color: Color(0xFFEF4444),
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                      if (debt.description.isNotEmpty)
                        Text(
                          debt.description,
                          style: AppStyles.caption.copyWith(
                            color: AppColors.textHint,
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: isOverdue
                                ? const Color(0xFFEF4444)
                                : AppColors.textHint,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue
                                ? 'Lewat: $dateStr'
                                : 'Jatuh Tempo: $dateStr',
                            style: AppStyles.caption.copyWith(
                              color: isOverdue
                                  ? const Color(0xFFEF4444)
                                  : AppColors.textHint,
                              fontWeight: isOverdue
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppHelpers.formatCurrencyIdr(debt.amount),
                      style: AppStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: debt.isPaid
                            ? const Color(0xFFE8F5E9)
                            : (isOverdue
                                  ? const Color(0xFFFFF1F1)
                                  : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(AppDimens.radiusL),
                      ),
                      child: Text(
                        debt.isPaid
                            ? 'LUNAS'
                            : (isOverdue ? 'TERLAMBAT' : 'AKTIF'),
                        style: AppStyles.caption.copyWith(
                          color: debt.isPaid
                              ? Colors.green
                              : (isOverdue
                                    ? const Color(0xFFEF4444)
                                    : AppColors.textHint),
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.md,
                  vertical: 8,
                ),
                child: AppShimmer.rectangular(
                  height: 90,
                  borderRadius: AppDimens.radiusL,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
