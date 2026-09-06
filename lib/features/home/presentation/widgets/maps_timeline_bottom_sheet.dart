import 'package:flutter/material.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';

class MapsTimelineBottomSheet extends StatelessWidget {
  const MapsTimelineBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimens.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
            child: Row(
              children: [
                SvgPicture.asset(
                  AppAssets.iconMaps,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF34D399),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: AppDimens.sm),
                Text(
                  'Linimasa Perjalanan Keuangan',
                  style: AppStyles.heading3.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.xl),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.lg,
                vertical: AppDimens.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimelineItem(
                    title: 'Pencapaian Bulan Ini',
                    subtitle: '+ 2.5% peningkatan saldo',
                    date: 'Saat Ini',
                    icon: Icons.flag,
                    color: const Color(0xFF34D399),
                    isFirst: true,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Target Tabungan Tercapai',
                    subtitle: 'Dana Darurat terkumpul',
                    date: 'Minggu Lalu',
                    icon: Icons.savings,
                    color: const Color(0xFF60A5FA),
                    isFirst: false,
                    isLast: false,
                  ),
                  _buildTimelineItem(
                    title: 'Mulai Mencatat',
                    subtitle: 'Langkah pertama mengelola cuan',
                    date: 'Bulan Lalu',
                    icon: Icons.play_arrow,
                    color: const Color(0xFFFBBF24),
                    isFirst: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.xxl),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String date,
    required IconData icon,
    required Color color,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line & dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  )
                else
                  const SizedBox(height: 16),

                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.md),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: AppStyles.caption.copyWith(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppStyles.bodyText.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppStyles.caption.copyWith(
                            color: const Color(0xFFCBD5E1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
