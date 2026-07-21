import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/budget_entity.dart';
import 'add_budget_screen.dart';
import 'edit_budget_screen.dart';
import '../bloc/edit_budget_bloc.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../injection_container.dart' as di;

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<BudgetBloc>().add(LoadBudgets(user.uid));
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text('Manajemen Anggaran', style: AppStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoading) {
            return _buildBudgetShimmer();
          }

          if (state is BudgetError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is BudgetLoaded) {
            final double totalProgress = state.totalBudget > 0
                ? state.totalSpent / state.totalBudget
                : 0.0;
            final int totalPercent = (totalProgress * 100).toInt();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddBudgetScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF27AE60).withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: Colors.white),
                            SizedBox(width: AppSizes.padding8),
                            Text(
                              'Buat Anggaran Baru',
                              style: AppStyles.bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                      vertical: AppSizes.paddingV8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL ANGGARAN',
                              style: AppStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: AppSizes.paddingV4),
                            Text(
                              _formatCurrency(state.totalBudget),
                              style: AppStyles.heading2.copyWith(fontSize: AppSizes.font24),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TERPAKAI',
                              style: AppStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: AppSizes.paddingV4),
                            Text(
                              '$totalPercent%',
                              style: AppStyles.heading2.copyWith(
                                fontSize: AppSizes.font24,
                                color: totalPercent >= 90
                                    ? const Color(0xFFEF4444)
                                    : (totalPercent >= 80
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFF27AE60)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.md,
                    ),
                    child: Text(
                      'ANGGARAN AKTIF',
                      style: AppStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),

                  if (state.budgets.isEmpty)
                    const EmptyState(
                      title: 'Belum Ada Anggaran',
                      subtitle:
                          'Mulai buat anggaran untuk mengatur pengeluaran Anda dengan lebih baik.',
                      imageWidth: 120,
                    )
                  else
                    ...state.budgets.map((budget) {
                      final spent = state.spentAmounts[budget.id] ?? 0.0;
                      double progress = budget.amount > 0
                          ? spent / budget.amount
                          : 0.0;
                      if (progress > 1.0) progress = 1.0;
                      final percent = (progress * 100).toInt();

                      return _buildBudgetItem(
                        title: budget.categoryName,
                        spent: _formatCurrency(spent),
                        total: _formatCurrency(budget.amount),
                        progress: progress,
                        percent: '$percent%',
                        icon: _getIconForCategory(budget.categoryName),
                        iconBgColor: _getBgColorForCategory(
                          budget.categoryName,
                        ),
                        iconColor: _getColorForCategory(budget.categoryName),
                        progressColor: progress >= 0.9
                            ? const Color(0xFFEF4444)
                            : (progress >= 0.8
                                  ? const Color(0xFFF97316)
                                  : const Color(0xFF27AE60)),
                        budget: budget,
                      );
                    }).toList(),

                  const SizedBox(height: AppDimens.xl),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radius32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSizes.paddingV12),
              Container(
                width: 40,
                height: AppSizes.paddingV4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSizes.paddingV12),
              _buildMenuItem(
                icon: Icons.sort,
                title: 'Urutkan Anggaran',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 64),
              _buildMenuItem(
                icon: Icons.restart_alt,
                title: 'Atur Ulang Semua',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 64),
              _buildMenuItem(
                icon: Icons.edit_note,
                title: 'Edit Kategori',
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1, indent: 64),
              _buildMenuItem(
                icon: Icons.archive_outlined,
                title: 'Tampilkan Anggaran Terarsip',
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: AppSizes.paddingV32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.padding24, vertical: AppSizes.paddingV8),
      leading: Icon(icon, color: const Color(0xFF1B5E20), size: 28),
      title: Text(
        title,
        style: AppStyles.bodyText.copyWith(
          color: const Color(0xFF1B5E20),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBudgetItem({
    required String title,
    required String spent,
    required String total,
    required double progress,
    required String percent,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color progressColor,
    required BudgetEntity budget,
    Color? highlightColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: AppSizes.paddingV8),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.padding12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(width: AppSizes.padding16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSizes.paddingV4),
                    Text(
                      '$spent / $total',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding8, vertical: AppSizes.paddingV4),
                decoration: BoxDecoration(
                  color: highlightColor ?? const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  percent,
                  style: AppStyles.caption.copyWith(
                    color: progress >= 0.9
                        ? const Color(0xFFEF4444)
                        : (progress >= 0.8
                              ? const Color(0xFFF97316)
                              : const Color(0xFF27AE60)),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.padding8),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => di.sl<EditBudgetBloc>(),
                          child: EditBudgetScreen(budget: budget),
                        ),
                      ),
                    ).then((_) {
                      context.read<BudgetBloc>().add(
                        LoadBudgets(budget.userId),
                      );
                    });
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, budget);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: AppSizes.padding12),
                        Text(
                          'Edit',
                          style: AppStyles.bodyText.copyWith(
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: AppSizes.padding12),
                        Text(
                          'Delete',
                          style: AppStyles.bodyText.copyWith(
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingV16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radius8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    BudgetEntity budget,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
          title: Text('Hapus Anggaran', style: AppStyles.heading3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus anggaran ini?',
                style: AppStyles.bodyText,
              ),
              SizedBox(height: AppSizes.paddingV16),
              Container(
                padding: EdgeInsets.all(AppSizes.padding12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizes.padding8),
                      decoration: BoxDecoration(
                        color: _getBgColorForCategory(budget.categoryName),
                        borderRadius: BorderRadius.circular(AppSizes.radius8),
                      ),
                      child: Icon(
                        _getIconForCategory(budget.categoryName),
                        color: _getColorForCategory(budget.categoryName),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSizes.padding12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.categoryName,
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatCurrency(budget.amount),
                            style: AppStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: AppStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<BudgetBloc>().add(
                  DeleteBudget(budget.userId, budget.id),
                );
              },
              child: Text(
                'Hapus',
                style: AppStyles.bodyText.copyWith(
                  color: const Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return Icons.restaurant;
      case 'Transportasi':
        return Icons.directions_car;
      case 'Belanja':
        return Icons.shopping_bag;
      case 'Hiburan':
        return Icons.theater_comedy;
      default:
        return Icons.category;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return const Color(0xFFEA580C);
      case 'Transportasi':
        return const Color(0xFF2563EB);
      case 'Belanja':
        return const Color(0xFF7C3AED);
      case 'Hiburan':
        return const Color(0xFFDB2777);
      default:
        return const Color(0xFF475569);
    }
  }

  Color _getBgColorForCategory(String category) {
    switch (category) {
      case 'Makanan & Minuman':
        return const Color(0xFFFFF7ED);
      case 'Transportasi':
        return const Color(0xFFEFF6FF);
      case 'Belanja':
        return const Color(0xFFF5F3FF);
      case 'Hiburan':
        return const Color(0xFFFDF2F8);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Widget _buildBudgetShimmer() {
    return SingleChildScrollView(
      child: AppShimmer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.md),
              child: AppShimmer.rectangular(
                height: 56,
                borderRadius: AppDimens.radiusM,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.md,
                vertical: AppSizes.paddingV8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer.rectangular(width: 100, height: AppSizes.paddingV12),
                      SizedBox(height: AppSizes.paddingV8),
                      AppShimmer.rectangular(width: 150, height: AppSizes.paddingV24),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppShimmer.rectangular(width: 60, height: AppSizes.paddingV12),
                      SizedBox(height: AppSizes.paddingV8),
                      AppShimmer.rectangular(width: 40, height: AppSizes.paddingV24),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingV24),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.md,
                  vertical: AppSizes.paddingV8,
                ),
                child: AppShimmer.rectangular(
                  height: 100,
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
