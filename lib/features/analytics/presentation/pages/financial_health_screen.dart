import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';
import '../../../../features/savings/presentation/bloc/savings_bloc.dart';
import '../../../../features/savings/presentation/bloc/savings_state.dart';
import '../../../../features/debt/presentation/bloc/debt_bloc.dart';
import '../../../../features/debt/presentation/bloc/debt_state.dart';
import '../../../../features/home/presentation/bloc/home_bloc.dart';
import '../../../../features/home/presentation/bloc/home_state.dart';
import '../widgets/gauge_painter.dart';

class FinancialHealthScreen extends StatefulWidget {
  const FinancialHealthScreen({super.key});

  @override
  State<FinancialHealthScreen> createState() => _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends State<FinancialHealthScreen> {
  // Simulasi variabel
  double? _simulatedIncome;
  double? _simulatedExpense;
  double? _simulatedSavings;
  double? _simulatedDebt;

  bool _isSimulating = false;

  bool _aiLoading = false;
  String _aiRecommendation = '';

  bool _hasTriggeredAI = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFB),
        elevation: 0,
        leadingWidth: 80,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          'Kesehatan Keuangan',
          style: AppStyles.heading2.copyWith(
            fontSize: 18,
            color: const Color(0xFF1B5E20),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                AppHelpers.showSnackBar(context, 'Fitur berbagi segera hadir!');
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          return BlocBuilder<SavingsBloc, SavingsState>(
            builder: (context, savingsState) {
              return BlocBuilder<DebtBloc, DebtState>(
                builder: (context, debtState) {
                  // 1. Ekstrak data riil
                  double realIncome = 0;
                  double realExpense = 0;
                  double realSavings = 0;
                  double realDebt = 0;

                  if (homeState is HomeLoaded) {
                    realIncome = homeState.monthlyIncome;
                    realExpense = homeState.monthlyExpenses;
                  }

                  if (savingsState is SavingsLoaded) {
                    realSavings = savingsState.goals.fold(
                      0.0,
                      (sum, goal) => sum + goal.currentAmount,
                    );
                  }

                  if (debtState is DebtLoaded) {
                    for (var debt in debtState.debts) {
                      final remaining = debt.amount - debt.paidAmount;
                      if (remaining > 0 && debt.type == 'hutang') {
                        realDebt += remaining;
                      }
                    }
                  }

                  // 2. Gunakan nilai simulasi jika aktif, jika tidak gunakan nilai riil
                  double currentIncome = _simulatedIncome ?? realIncome;
                  double currentExpense = _simulatedExpense ?? realExpense;
                  double currentSavings = _simulatedSavings ?? realSavings;
                  double currentDebt = _simulatedDebt ?? realDebt;

                  // Cegah pembagian dengan nol
                  if (currentIncome <= 0) currentIncome = 1.0;

                  // 3. Hitung rasio keuangan
                  double savingRatio = currentSavings / currentIncome;
                  double debtRatio = currentDebt / currentIncome;
                  double emergencyFundRatio = currentExpense > 0
                      ? (currentSavings / currentExpense)
                      : 0;

                  // 4. Hitung Skor per Metrik (Skala 0 - 100)
                  double savingScore = savingRatio >= 0.20
                      ? 100
                      : (savingRatio / 0.20) * 100;

                  double debtScore = 0;
                  if (debtRatio <= 0.35) {
                    debtScore = 100;
                  } else if (debtRatio >= 1.0) {
                    debtScore = 0;
                  } else {
                    debtScore = (1.0 - (debtRatio - 0.35) / 0.65) * 100;
                  }

                  double emergencyScore = emergencyFundRatio >= 3.0
                      ? 100
                      : (emergencyFundRatio / 3.0) * 100;

                  // 5. Skor Kesehatan Keuangan Total
                  double overallScore =
                      (savingScore + debtScore + emergencyScore) / 3;
                  if (overallScore < 0) overallScore = 0;
                  if (overallScore > 100) overallScore = 100;

                  // Pemicu AI sekali saat data asli dimuat
                  if (realIncome > 0 && !_hasTriggeredAI) {
                    _hasTriggeredAI = true;
                    // Ambil rekomendasi AI berdasarkan data riil pengguna
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _fetchAIRecommendation(
                        realIncome,
                        realExpense,
                        realSavings,
                        realDebt,
                        realSavings / (realIncome > 0 ? realIncome : 1.0),
                        realDebt / (realIncome > 0 ? realIncome : 1.0),
                        realExpense > 0 ? (realSavings / realExpense) : 0,
                      );
                    });
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Gauge Chart
                        _buildGaugeCard(overallScore),
                        const SizedBox(height: 24),

                        // Section Analisis Metrik
                        Text(
                          'Analisis Metrik Keuangan',
                          style: AppStyles.heading3.copyWith(
                            color: const Color(0xFF1B5E20),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildMetricItem(
                          title: 'Saving Ratio',
                          value: '${(savingRatio * 100).toStringAsFixed(0)}%',
                          target: 'Target: >20%',
                          progress: savingRatio / 0.20,
                          score: savingScore,
                          desc: savingScore >= 100
                              ? 'Sangat bagus! Rasio tabungan Anda memenuhi standar ideal.'
                              : 'Sedikit di bawah target. Cobalah alokasikan tabungan Anda sebelum berbelanja.',
                          activeColor: savingScore >= 100
                              ? const Color(0xFF4CAF50)
                              : (savingScore > 50
                                    ? const Color(0xFFFDD835)
                                    : const Color(0xFFE53935)),
                        ),
                        const SizedBox(height: 16),

                        _buildMetricItem(
                          title: 'Debt-to-Income Ratio',
                          value: '${(debtRatio * 100).toStringAsFixed(0)}%',
                          target: 'Target: <35%',
                          progress: debtRatio > 0 ? (0.35 / debtRatio) : 1.0,
                          score: debtScore,
                          desc: debtScore >= 100
                              ? 'Sangat aman! Beban cicilan hutang Anda terkendali dengan baik.'
                              : 'Waspada. Rasio hutang Anda cukup tinggi, kurangi pengajuan cicilan baru.',
                          activeColor: debtScore >= 100
                              ? const Color(0xFF4CAF50)
                              : (debtScore > 50
                                    ? const Color(0xFFFDD835)
                                    : const Color(0xFFE53935)),
                          isInverseProgress: true,
                          ratioPercent: debtRatio,
                          ratioLimit: 0.35,
                        ),
                        const SizedBox(height: 16),

                        _buildMetricItem(
                          title: 'Dana Darurat (Emergency Fund)',
                          value:
                              '${emergencyFundRatio.toStringAsFixed(1)} Bulan',
                          target: 'Target: 3-6 Bulan',
                          progress: emergencyFundRatio / 3.0,
                          score: emergencyScore,
                          desc: emergencyScore >= 100
                              ? 'Sangat sehat! Dana darurat mencukupi untuk 3 bulan pengeluaran atau lebih.'
                              : 'Kritis! Tabungan Anda belum mencukupi untuk menopang pengeluaran darurat.',
                          activeColor: emergencyScore >= 100
                              ? const Color(0xFF4CAF50)
                              : (emergencyScore > 50
                                    ? const Color(0xFFFDD835)
                                    : const Color(0xFFE53935)),
                        ),
                        const SizedBox(height: 24),

                        // Section Rekomendasi AI
                        _buildAIRecommendationCard(),
                        const SizedBox(height: 32),

                        // Tombol Simulasi
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              _showSimulationSheet(
                                realIncome: realIncome,
                                realExpense: realExpense,
                                realSavings: realSavings,
                                realDebt: realDebt,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSimulating
                                      ? Icons.settings_backup_restore
                                      : Icons.tune,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isSimulating
                                      ? 'Reset Simulasi'
                                      : 'Mulai Simulasi Perbaikan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGaugeCard(double score) {
    String status = 'Bahaya';
    Color statusColor = const Color(0xFFE53935);
    Color statusBgColor = const Color(0xFFFFEBEE);

    if (score > 70) {
      status = 'Sehat';
      statusColor = const Color(0xFF4CAF50);
      statusBgColor = const Color(0xFFE8F5E9);
    } else if (score > 35) {
      status = 'Cukup Sehat';
      statusColor = const Color(0xFFFDD835);
      statusBgColor = const Color(0xFFFFFDE7);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: score),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Column(
                children: [
                  SizedBox(
                    height: 140,
                    width: 250,
                    child: CustomPaint(painter: GaugePainter(score: val)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${val.toStringAsFixed(0)} / 100',
                    style: AppStyles.heading1.copyWith(
                      fontSize: 28,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
            ),
            child: Text(
              status,
              style: AppStyles.bodyText.copyWith(
                color: statusColor == const Color(0xFFFDD835)
                    ? Colors.orange[800]
                    : statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isSimulating
                ? 'Mode Simulasi Aktif. Tarik slider untuk melihat perubahan skor secara langsung.'
                : 'Keuanganmu masuk kategori $status. Ikuti rekomendasi di bawah untuk peningkatan.',
            textAlign: TextAlign.center,
            style: AppStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required String target,
    required double progress,
    required double score,
    required String desc,
    required Color activeColor,
    bool isInverseProgress = false,
    double ratioPercent = 0,
    double ratioLimit = 0.35,
  }) {
    double progressFactor = progress.clamp(0.0, 1.0);
    if (isInverseProgress) {
      // Untuk Debt ratio: jika ratio 0% -> progres bar penuh (sehat). Jika ratio > limit -> menyusut.
      progressFactor = ratioPercent <= ratioLimit
          ? 1.0
          : (ratioPercent >= 1.0
                    ? 0.0
                    : (1.0 - (ratioPercent - ratioLimit) / (1.0 - ratioLimit)))
                .clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: AppStyles.heading2.copyWith(
                  fontSize: 14,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            target,
            style: AppStyles.caption.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressFactor,
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: AppStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi CuanAI',
                  style: AppStyles.heading2.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _aiLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      )
                    : Text(
                        _aiRecommendation,
                        style: AppStyles.bodyText.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSimulationSheet({
    required double realIncome,
    required double realExpense,
    required double realSavings,
    required double realDebt,
  }) {
    // Inisialisasi simulator jika kosong
    _simulatedIncome ??= realIncome <= 0 ? 5000000 : realIncome;
    _simulatedExpense ??= realExpense;
    _simulatedSavings ??= realSavings;
    _simulatedDebt ??= realDebt;

    setState(() {
      _isSimulating = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Simulasi Perbaikan Finansial',
                    style: AppStyles.heading2.copyWith(
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Geser slider untuk melihat bagaimana penyesuaian nominal keuangan mempengaruhi skor kesehatan Anda.',
                    style: AppStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Slider 1: Pendapatan
                  _buildSliderItem(
                    label: 'Pendapatan Bulanan',
                    value: _simulatedIncome!,
                    min: 1000000,
                    max: 50000000,
                    divisions: 49,
                    onChanged: (val) {
                      setSheetState(() => _simulatedIncome = val);
                      setState(() => _simulatedIncome = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slider 2: Pengeluaran
                  _buildSliderItem(
                    label: 'Pengeluaran Bulanan',
                    value: _simulatedExpense!,
                    min: 500000,
                    max: 30000000,
                    divisions: 59,
                    onChanged: (val) {
                      setSheetState(() => _simulatedExpense = val);
                      setState(() => _simulatedExpense = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slider 3: Tabungan
                  _buildSliderItem(
                    label: 'Total Tabungan',
                    value: _simulatedSavings!,
                    min: 0,
                    max: 100000000,
                    divisions: 100,
                    onChanged: (val) {
                      setSheetState(() => _simulatedSavings = val);
                      setState(() => _simulatedSavings = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slider 4: Hutang
                  _buildSliderItem(
                    label: 'Total Hutang',
                    value: _simulatedDebt!,
                    min: 0,
                    max: 50000000,
                    divisions: 50,
                    onChanged: (val) {
                      setSheetState(() => _simulatedDebt = val);
                      setState(() => _simulatedDebt = val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tombol Selesai & Reset
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              _simulatedIncome = null;
                              _simulatedExpense = null;
                              _simulatedSavings = null;
                              _simulatedDebt = null;
                            });
                            setState(() {
                              _simulatedIncome = null;
                              _simulatedExpense = null;
                              _simulatedSavings = null;
                              _simulatedDebt = null;
                              _isSimulating = false;
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Selesai',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSliderItem({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppStyles.bodyText.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              AppHelpers.formatCurrencyIdr(value),
              style: AppStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
                fontSize: 13,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF4CAF50),
            inactiveTrackColor: Colors.grey[200],
            thumbColor: const Color(0xFF1B5E20),
            overlayColor: const Color(0xFF1B5E20).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFF1B5E20),
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _fetchAIRecommendation(
    double income,
    double expense,
    double savings,
    double debt,
    double savingRatio,
    double debtRatio,
    double emergencyFundRatio,
  ) async {
    if (_aiRecommendation.isNotEmpty || _aiLoading) return;
    setState(() {
      _aiLoading = true;
    });
    try {
      final ai = await FirebaseAI.googleAI();
      final model = ai.generativeModel(model: 'gemini-2.5-flash');
      final prompt =
          """
Rangkum kondisi keuangan pengguna berikut dalam 2-3 kalimat ramah dan solutif (panggil 'kamu', berikan 1 saran spesifik untuk meningkatkan skor kesehatan keuangan mereka):
- Pendapatan Bulanan: Rp ${income.toStringAsFixed(0)}
- Pengeluaran Bulanan: Rp ${expense.toStringAsFixed(0)}
- Total Tabungan saat ini: Rp ${savings.toStringAsFixed(0)}
- Total Hutang saat ini: Rp ${debt.toStringAsFixed(0)}
- Saving Ratio: ${(savingRatio * 100).toStringAsFixed(0)}% (Target: >20%)
- Debt-to-Income Ratio: ${(debtRatio * 100).toStringAsFixed(0)}% (Target: <35%)
- Dana Darurat: ${emergencyFundRatio.toStringAsFixed(1)} bulan pengeluaran (Target: 3-6 bulan)

Jawab langsung dengan saran praktis tanpa kalimat pengantar basa-basi formal. Gunakan bahasa Indonesia.
""";
      final response = await model.generateContent([Content.text(prompt)]);
      setState(() {
        _aiRecommendation = response.text ?? 'Gagal membuat rekomendasi AI.';
        _aiLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiRecommendation =
            "Berdasarkan data keuanganmu, kamu perlu berfokus pada pembangunan Dana Darurat yang ideal (target 3-6 bulan pengeluaran). Kurangi pengeluaran non-primer dan alokasikan selisihnya ke tabungan aktif secara rutin!";
        _aiLoading = false;
      });
    }
  }
}
