import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/constants/app_dimens.dart';
import 'transaction_map_detail_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class FinancialTimelineScreen extends StatefulWidget {
  const FinancialTimelineScreen({super.key});

  @override
  State<FinancialTimelineScreen> createState() =>
      _FinancialTimelineScreenState();
}

class _FinancialTimelineScreenState extends State<FinancialTimelineScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'Hari ini',
    'Minggu ini',
    'Bulan ini',
    'Semua',
  ];

  // Dummy initial location (Jakarta)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456),
    zoom: 14.4746,
  );

  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
        _hasLocationPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020617),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Linimasa Keuangan',
          style: AppStyles.heading3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Stack(
              children: [
                // 1. Google Map
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  zoomControlsEnabled: false,
                  myLocationEnabled: _hasLocationPermission,
                  myLocationButtonEnabled: _hasLocationPermission,
                  markers: _createMarkers(),
                ),

                // 2. Summary Card overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: _buildSummaryCard(),
                ),
              ],
            ),
          ),

          // 3. Timeline List
          Expanded(
            child: Container(color: const Color(0xFF020617), child: _buildTimelineList()),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: const Color(0xFF020617),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: AppDimens.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.lg,
                  vertical: AppDimens.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(AppDimens.radiusXL),
                ),
                child: Text(
                  _filters[index],
                  style: AppStyles.bodyTextSecondary.copyWith(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return {
      const Marker(
        markerId: MarkerId('1'),
        position: LatLng(-6.2088, 106.8456),
        infoWindow: InfoWindow(title: 'Kopi Kenangan', snippet: 'Rp 25.000'),
      ),
      const Marker(
        markerId: MarkerId('2'),
        position: LatLng(-6.2188, 106.8356),
        infoWindow: InfoWindow(title: 'Superindo', snippet: 'Rp 85.000'),
      ),
    };
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengeluaran Hari Ini',
                  style: AppStyles.caption.copyWith(color: Colors.grey),
                ),
                Text(
                  'Rp 185.000',
                  style: AppStyles.heading3.copyWith(color: Colors.white),
                ),
                Text(
                  '7 transaksi',
                  style: AppStyles.caption.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.show_chart, color: Color(0xFF10B981), size: 40),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.md),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.md),
          child: Text(
            'Hari Ini, 26 Agustus 2024',
            style: AppStyles.heading3.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        _buildTimelineItem(
          '08:15',
          'Kopi Kenangan',
          'Makanan & Minuman',
          '-25.000',
          Icons.coffee,
          Colors.orange,
        ),
        _buildTimelineItem(
          '11:42',
          'Superindo Supermarket',
          'Belanja',
          '-85.000',
          Icons.shopping_cart,
          Colors.green,
        ),
        _buildTimelineItem(
          '15:20',
          'SPBU Pertamina',
          'Transportasi',
          '-75.000',
          Icons.local_gas_station,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String time,
    String title,
    String category,
    String amount,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionMapDetailScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.md),
        child: Row(
          children: [
            Text(time, style: AppStyles.caption.copyWith(color: Colors.grey)),
            const SizedBox(width: AppDimens.sm),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Container(
              padding: const EdgeInsets.all(AppDimens.sm),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
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
                  Text(
                    category,
                    style: AppStyles.caption.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: AppStyles.bodyText.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
