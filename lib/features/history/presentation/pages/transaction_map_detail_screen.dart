import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';

class TransactionMapDetailScreen extends StatelessWidget {
  const TransactionMapDetailScreen({super.key});

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Transaksi',
          style: AppStyles.heading3.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Header
          SizedBox(
            height: 250,
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              markers: {
                const Marker(
                  markerId: MarkerId('detail_1'),
                  position: LatLng(-6.2088, 106.8456),
                ),
              },
            ),
          ),

          // Bottom Detail Sheet
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusXL),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.coffee,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kopi Kenangan',
                                style: AppStyles.heading2.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Makanan & Minuman',
                                style: AppStyles.bodyTextSecondary.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2F1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Pengeluaran',
                                  style: AppStyles.caption.copyWith(
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xl),
                    Text(
                      '-25.000',
                      style: AppStyles.heading1.copyWith(
                        color: Colors.red,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: AppDimens.xl),

                    _buildDetailRow(Icons.calendar_today, '26 Agustus 2024'),
                    _buildDetailRow(Icons.access_time, '08:15'),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Jl. Sudirman No. 45\nJakarta Pusat',
                    ),
                    _buildDetailRow(
                      Icons.notes,
                      'Catatan\nNgopi sebelum kerja ☕',
                    ),
                    _buildDetailRow(
                      Icons.payment,
                      'Metode Pembayaran\nDompet Digital',
                    ),
                    _buildDetailRow(
                      Icons.local_offer_outlined,
                      'Tag\nKopi, Harian',
                    ),

                    const SizedBox(height: AppDimens.xl),
                    Text(
                      'Foto Struk',
                      style: AppStyles.bodyText.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.receipt, color: Colors.grey),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusS,
                            ),
                          ),
                          child: const Icon(Icons.add, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.xxl),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusM,
                            ),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Edit Transaksi',
                          style: AppStyles.bodyText.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Text(
              text,
              style: AppStyles.bodyText.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
