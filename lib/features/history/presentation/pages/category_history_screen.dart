import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../home/domain/entities/transaction_entity.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../../../transaction/presentation/pages/transaction_detail_screen.dart';
import '../../../../injection_container.dart' as di;

class CategoryHistoryScreen extends StatelessWidget {
  final String categoryName;
  final DateTime month;
  final Color categoryColor;

  const CategoryHistoryScreen({
    super.key,
    required this.categoryName,
    required this.month,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryBloc>(
      create: (_) => di.sl<HistoryBloc>(),
      child: _CategoryHistoryView(
        categoryName: categoryName,
        month: month,
        categoryColor: categoryColor,
      ),
    );
  }
}

class _CategoryHistoryView extends StatefulWidget {
  final String categoryName;
  final DateTime month;
  final Color categoryColor;

  const _CategoryHistoryView({
    required this.categoryName,
    required this.month,
    required this.categoryColor,
  });

  @override
  State<_CategoryHistoryView> createState() => _CategoryHistoryViewState();
}

class _CategoryHistoryViewState extends State<_CategoryHistoryView> {
  String _userId = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      context.read<HistoryBloc>().add(
        ChangeMonthEvent(_userId, widget.month),
      );
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMMM yyyy', 'id_ID').format(widget.month);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(widget.categoryName, style: AppStyles.heading2),
            Text(
              monthStr,
              style: AppStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryInitial || state is HistoryLoading) {
            return _buildShimmer();
          }

          if (state is HistoryError) {
            return Center(child: Text(state.message));
          }

          if (state is HistoryLoaded) {
            // Filter transaksi berdasarkan kategori
            final filtered = state.transactions
                .where((t) => t.categoryName == widget.categoryName)
                .toList()
              ..sort((a, b) => a.date.compareTo(b.date));

            if (filtered.isEmpty) {
              return const EmptyState(
                title: 'Tidak ada transaksi',
                subtitle: 'Tidak ada transaksi untuk kategori ini di bulan ini.',
              );
            }

            double totalAmount = 0;
            for (var t in filtered) {
              totalAmount += t.amount;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  _buildSummaryCard(filtered.length, totalAmount),
                  const SizedBox(height: AppDimens.md),
                  // Excel table
                  _buildTable(filtered, totalAmount),
                  const SizedBox(height: AppDimens.xl * 2),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(int count, double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.categoryColor,
            widget.categoryColor.withOpacity(0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: widget.categoryColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL ${widget.categoryName.toUpperCase()}',
                  style: AppStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(total),
                  style: AppStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: AppStyles.heading1.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
              Text(
                'transaksi',
                style: AppStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<TransactionEntity> transactions, double totalAmount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: widget.categoryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        child: Column(
          children: [
            // ── Header Row ──
            _buildHeaderRow(),
            // ── Data Rows ──
            ...transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              return _buildDataRow(index, t);
            }),
            // ── Footer / Total Row ──
            _buildFooterRow(transactions.length, totalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: widget.categoryColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          _headerCell('No', flex: 1, center: true),
          _headerCell('Tanggal', flex: 3),
          _headerCell('Keterangan', flex: 4),
          _headerCell('Jumlah', flex: 4, right: true),
        ],
      ),
    );
  }

  Widget _headerCell(
    String label, {
    required int flex,
    bool center = false,
    bool right = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign:
            center
                ? TextAlign.center
                : (right ? TextAlign.right : TextAlign.left),
        style: AppStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDataRow(int index, TransactionEntity t) {
    final isEven = index % 2 == 0;
    final isExpense = t.type == 'expense';
    final amountColor = isExpense
        ? const Color(0xFFE53935)
        : const Color(0xFF43A047);
    final amountSign = isExpense ? '-' : '+';

    final displayTitle = (t.notes?.isNotEmpty == true)
        ? t.notes!
        : (t.title.isNotEmpty ? t.title : (t.categoryName ?? '-'));
    final dateStr = DateFormat('dd/MM/yy').format(t.date);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(transaction: t),
        ),
      ),
      child: Container(
        color: isEven
            ? Colors.white
            : widget.categoryColor.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        child: Row(
          children: [
            // No
            Expanded(
              flex: 1,
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: AppStyles.caption.copyWith(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ),
            // Tanggal
            Expanded(
              flex: 3,
              child: Text(
                dateStr,
                style: AppStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            // Keterangan
            Expanded(
              flex: 4,
              child: Text(
                displayTitle,
                style: AppStyles.bodyText.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Jumlah
            Expanded(
              flex: 4,
              child: Text(
                '$amountSign${_formatCurrency(t.amount)}',
                textAlign: TextAlign.right,
                style: AppStyles.bodyText.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterRow(int count, double totalAmount) {
    return Container(
      color: widget.categoryColor.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          // No (kosong)
          const Expanded(flex: 1, child: SizedBox()),
          // Tanggal (kosong)
          const Expanded(flex: 3, child: SizedBox()),
          // Label TOTAL
          Expanded(
            flex: 4,
            child: Text(
              'TOTAL ($count transaksi)',
              style: AppStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Nilai Total
          Expanded(
            flex: 4,
            child: Text(
              _formatCurrency(totalAmount),
              textAlign: TextAlign.right,
              style: AppStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: widget.categoryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.md),
      child: AppShimmer(
        child: Column(
          children: [
            AppShimmer.rectangular(height: 90, borderRadius: AppDimens.radiusL),
            const SizedBox(height: AppDimens.md),
            AppShimmer.rectangular(height: 300, borderRadius: AppDimens.radiusL),
          ],
        ),
      ),
    );
  }
}
