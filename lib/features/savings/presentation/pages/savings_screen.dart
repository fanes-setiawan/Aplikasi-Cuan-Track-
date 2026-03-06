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
import 'add_savings_goal_screen.dart';
import '../../../../core/utils/currency_formatter.dart';

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

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTotalCard(totalSavings),
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
                          )
                        else
                          ...state.goals.map((goal) => _buildGoalItem(goal)),

                        const SizedBox(height: AppDimens.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddSavingsGoalScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Tambah Target Baru',
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

                        const SizedBox(height: AppDimens.xl + 10),

                        // History Section Placeholder
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
                        _buildHistoryPlaceholder(),
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
                blastDirection: pi / 2, // down
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(double total) {
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
          // Background subtle pattern
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
                const SizedBox(height: 4),
                Text(
                  AppHelpers.formatCurrencyIdr(total),
                  style: AppStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppDimens.lg),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SAFE & SECURED',
                      style: AppStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildGoalItem(dynamic goal) {
    final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    final remaining = goal.targetAmount - goal.currentAmount;
    final bool isLaptop = goal.title.toLowerCase().contains('laptop');
    final IconData icon = isLaptop ? Icons.laptop_mac : Icons.flight_takeoff;
    final Color iconBgColor = isLaptop
        ? const Color(0xFFE0F2F1)
        : const Color(0xFFE3F2FD);
    final Color iconColor = isLaptop
        ? const Color(0xFF00897B)
        : const Color(0xFF1976D2);

    // Format the date assuming deadline is in DateTime
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
      onLongPress: () {
        context.read<SavingsBloc>().add(DeleteSavingsGoal(_userId, goal.id));
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
                        Text(
                          dateStr,
                          style: AppStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppStyles.bodyText.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildHistoryPlaceholder() {
    return Column(
      children: [
        _buildHistoryItem(
          'Setoran - Beli Laptop',
          'Hari ini, 09:15',
          '+Rp 500.000',
        ),
        _buildHistoryItem(
          'Setoran - Liburan Bali',
          '22 Okt 2023',
          '+Rp 250.000',
        ),
        _buildHistoryItem('Auto-debet Bulanan', '20 Okt 2023', '+Rp 1.000.000'),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String subtitle, String amount) {
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
            child: const Icon(
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
                  title,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppStyles.caption.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          Text(
            amount,
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
