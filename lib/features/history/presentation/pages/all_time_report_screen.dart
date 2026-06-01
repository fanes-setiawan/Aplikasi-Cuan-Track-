import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/pdf_report_generator.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class AllTimeReportScreen extends StatefulWidget {
  const AllTimeReportScreen({super.key});

  @override
  State<AllTimeReportScreen> createState() => _AllTimeReportScreenState();
}

class _AllTimeReportScreenState extends State<AllTimeReportScreen> {
  String _userId = '';
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _userName = user.displayName ?? user.email?.split('@').first ?? 'Pengguna Cuan Track';
      context.read<HistoryBloc>().add(LoadAllTimeTransactionsEvent(_userId));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Pratinjau Laporan', style: AppStyles.heading2),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryInitial || state is HistoryLoading) {
            return _buildShimmerLoading();
          }

          if (state is HistoryError) {
            return Center(child: Text(state.message));
          }

          if (state is AllTimeHistoryLoaded) {
            return PdfPreview(
              build: (format) => PdfReportGenerator.generateAllTimeReportBytes(
                _userName,
                state.transactions,
                state.totalIncome,
                state.totalExpense,
              ),
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName: 'Laporan_Keuangan_AllTime_${_userName.replaceAll(' ', '_')}.pdf',
              loadingWidget: _buildShimmerLoading(),
              pdfPreviewPageDecoration: const BoxDecoration(
                color: Colors.white,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.md),
      child: AppShimmer(
        child: Column(
          children: [
            AppShimmer.rectangular(height: 140, borderRadius: AppDimens.radiusL),
            const SizedBox(height: AppDimens.md),
            Row(
              children: [
                Expanded(child: AppShimmer.rectangular(height: 80, borderRadius: AppDimens.radiusL)),
                const SizedBox(width: AppDimens.md),
                Expanded(child: AppShimmer.rectangular(height: 80, borderRadius: AppDimens.radiusL)),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            AppShimmer.rectangular(height: 38, borderRadius: 20),
            const SizedBox(height: AppDimens.xl),
            ...List.generate(
              3,
              (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmer.rectangular(width: 100, height: 14),
                  const SizedBox(height: AppDimens.md),
                  ...List.generate(
                    2,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: AppShimmer.rectangular(height: 70, borderRadius: AppDimens.radiusM),
                    ),
                  ),
                  const SizedBox(height: AppDimens.md),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
