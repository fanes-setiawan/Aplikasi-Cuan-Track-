import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/empty_state.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';
import 'package:intl/intl.dart';
import 'add_savings_goal_screen.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/savings_history_entity.dart';
import '../bloc/savings_category_bloc.dart';
import '../bloc/savings_category_event.dart';
import '../widgets/add_savings_category_sheet.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );
  String _userId = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      context.read<SavingsBloc>().add(LoadSavingsGoals(_userId));
      context.read<SavingsCategoryBloc>().add(LoadSavingsCategories(_userId));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showAddFundsDialog(
    BuildContext context,
    String goalId,
    double remaining,
  ) {
    if (remaining <= 0) return;

    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Tambah Tabungan', style: AppStyles.heading2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sisa target: ${AppHelpers.formatCurrencyIdr(remaining)}',
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
                  labelText: 'Nominal Rupiah',
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
                  context.read<SavingsBloc>().add(
                    AddFundsToGoal(
                      userId: _userId,
                      goalId: goalId,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavingsBloc, SavingsState>(
      listener: (context, state) {
        if (state is AddSavingsFundsSuccess) {
          if (state.isAchieved) {
            _confettiController.play();
            AppHelpers.showSnackBar(
              context,
              'Selamat! Anda telah mencapai target "${state.goal.title}"',
            );
          } else {
            AppHelpers.showSnackBar(context, 'Berhasil menambahkan tabungan');
          }
        } else if (state is SavingsError) {
          AppHelpers.showSnackBar(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: AppDimens.sm),
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
          title: Text('Tabungan Saya', style: AppStyles.heading2),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddSavingsCategorySheet(),
                );
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_outlined, color: AppColors.primary),
                  Text(
                    'Tujuan',
                    style: TextStyle(fontSize: 10, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            BlocBuilder<SavingsBloc, SavingsState>(
              builder: (context, state) {
                if (state is SavingsLoading) {
                  return _buildSavingsShimmer();
                } else if (state is SavingsLoaded) {
                  final totalSavings = state.goals.fold(
                    0.0,
                    (sum, goal) => sum + goal.currentAmount,
                  );
                  final totalTarget = state.goals.fold(
                    0.0,
                    (sum, goal) => sum + goal.targetAmount,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalCard(totalSavings, totalTarget),
                        const SizedBox(height: AppDimens.xl),

                        _buildPurposeSummary(state.goals),
                        const SizedBox(height: AppDimens.xl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Target Tabungan', style: AppStyles.heading3),
                            Text(
                              '${state.goals.where((g) => !g.isAchieved).length} Aktif',
                              style: AppStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.md),

                        if (state.goals.isEmpty)
                          const EmptyState(
                            title: 'Belum ada target',
                            subtitle:
                                'Buat target tabungan untuk memotivasi Anda mencapai impian.',
                            imageWidth: 120,
                          )
                        else
                          ...state.goals.map((goal) => _buildGoalItem(goal)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Riwayat Menabung', style: AppStyles.heading3),
                            Text(
                              'Lihat Semua',
                              style: AppStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.md),
                        _buildHistoryPlaceholder(state.history),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSavingsGoalScreen(),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: const Text(
            'Tambah Target',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total, double totalTarget) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.savings,
              size: 150,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Tabungan',
                      style: AppStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const Icon(Icons.credit_card, color: Colors.white70),
                  ],
                ),
                Text(
                  AppHelpers.formatCurrencyIdr(total),
                  style: AppStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                Divider(color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: AppDimens.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL TARGET',
                          style: AppStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppHelpers.formatCurrencyIdr(totalTarget),
                          style: AppStyles.bodyText.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SISA TARGET',
                          style: AppStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppHelpers.formatCurrencyIdr(
                            totalTarget - total > 0 ? totalTarget - total : 0,
                          ),
                          style: AppStyles.bodyText.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSummary(List<dynamic> goals) {
    if (goals.isEmpty) return const SizedBox.shrink();

    final Map<String, Map<String, dynamic>> summary = {};
    for (var goal in goals) {
      final name = goal.categoryName ?? 'Lainnya';
      if (!summary.containsKey(name)) {
        summary[name] = {
          'target': 0.0,
          'collected': 0.0,
          'icon': goal.categoryIconName,
          'color': goal.categoryColorHex,
        };
      }
      summary[name]!['target'] += goal.targetAmount;
      summary[name]!['collected'] += goal.currentAmount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ringkasan per Tujuan Nabung', style: AppStyles.heading3),
        const SizedBox(height: AppDimens.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: summary.entries.map((entry) {
              final progress =
                  (entry.value['collected'] / entry.value['target']).clamp(
                    0.0,
                    1.0,
                  );
              final icon = AppHelpers.getCategoryIcon(entry.value['icon']);
              final color = entry.value['color'] != null
                  ? Color(int.parse(entry.value['color']))
                  : AppColors.primary;

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: AppDimens.md),
                padding: const EdgeInsets.all(AppDimens.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppStyles.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: AppStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppHelpers.formatCurrencyIdr(entry.value['target']),
                          style: AppStyles.caption.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.divider.withOpacity(0.3),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terkumpul: ${AppHelpers.formatCurrencyIdr(entry.value['collected'])}',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showGoalActions(BuildContext context, dynamic goal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                title: const Text('Edit Target'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSavingsGoalScreen(goal: goal),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Target'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, goal);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target'),
        content: Text(
          'Apakah Anda yakin ingin menghapus target "${goal.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<SavingsBloc>().add(
                DeleteSavingsGoal(_userId, goal.id),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(dynamic goal) {
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final remaining = goal.targetAmount - goal.currentAmount;

    final IconData icon = AppHelpers.getCategoryIcon(goal.categoryIconName);
    final Color iconColor = goal.categoryColorHex != null
        ? Color(int.parse(goal.categoryColorHex))
        : AppColors.primary;
    final Color iconBgColor = iconColor.withOpacity(0.1);

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final dateStr =
        'Target: ${monthNames[goal.deadline.month - 1]} ${goal.deadline.year}';

    return GestureDetector(
      onTap: () {
        if (!goal.isAchieved) {
          _showAddFundsDialog(context, goal.id, remaining);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: AppDimens.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.title, style: AppStyles.heading3),
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: AppStyles.caption.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                            if (goal.categoryName != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.textHint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                goal.categoryName!,
                                style: AppStyles.caption.copyWith(
                                  color: iconColor.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppStyles.bodyText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showGoalActions(context, goal),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.divider.withOpacity(0.5),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TERKUMPUL',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      AppHelpers.formatCurrencyIdr(goal.currentAmount),
                      style: AppStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'KURANG',
                      style: AppStyles.caption.copyWith(
                        color: AppColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      AppHelpers.formatCurrencyIdr(
                        remaining > 0 ? remaining : 0.0,
                      ),
                      style: AppStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPlaceholder(List<SavingsHistoryEntity> history) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: Text(
            'Belum ada riwayat menabung',
            style: AppStyles.caption.copyWith(color: AppColors.textHint),
          ),
        ),
      );
    }

    return Column(
      children: history.map((item) => _buildHistoryItem(item)).toList(),
    );
  }

  Widget _buildHistoryItem(SavingsHistoryEntity item) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(item.date);
    final amountStr = '+${AppHelpers.formatCurrencyIdr(item.amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.savings_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setoran - ${item.goalTitle}',
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateStr,
                  style: AppStyles.caption.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Text(
            amountStr,
            style: AppStyles.bodyText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.md),
      child: AppShimmer(
        child: Column(
          children: [
            AppShimmer.rectangular(
              height: 180,
              borderRadius: AppDimens.radiusL,
            ),
            const SizedBox(height: AppDimens.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.rectangular(width: 150, height: 24),
                AppShimmer.rectangular(width: 60, height: 14),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            ...List.generate(
              2,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.md),
                child: AppShimmer.rectangular(
                  height: 150,
                  borderRadius: AppDimens.radiusL,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.md),
            AppShimmer.rectangular(height: 56, borderRadius: AppDimens.radiusM),
            const SizedBox(height: AppDimens.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer.rectangular(width: 150, height: 24),
                AppShimmer.rectangular(width: 80, height: 14),
              ],
            ),
            const SizedBox(height: AppDimens.md),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.sm),
                child: AppShimmer.rectangular(
                  height: 70,
                  borderRadius: AppDimens.radiusM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
