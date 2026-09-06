# Implementasi Linimasa Keuangan (Maps)

Fitur ini akan menampilkan riwayat transaksi dalam bentuk peta (Google Maps) dan daftar linimasa (timeline) sesuai dengan desain yang diberikan.

## User Review Required
> [!IMPORTANT]
> Fitur ini membutuhkan library `google_maps_flutter`. Agar Google Maps dapat berjalan di Android dan iOS, kita perlu memasukkan API Key ke dalam `AndroidManifest.xml` dan `AppDelegate.swift`. 
> Saya akan mengatur konfigurasi ini menggunakan API Key yang sudah disimpan di file `.env` jika memungkinkan, atau memasukkannya secara statis. Mohon konfirmasi jika Anda setuju.

## Proposed Changes

### `pubspec.yaml`
- Menambahkan dependensi `google_maps_flutter`.

### `android/app/src/main/AndroidManifest.xml`
- Menambahkan metadata untuk `com.google.android.geo.API_KEY` agar Google Maps bisa di-render di Android.

### `lib/features/history/presentation/pages/financial_timeline_screen.dart`
- [NEW] Layar utama yang menampilkan Google Maps di bagian atas dan daftar transaksi di bagian bawah.
- Mengimplementasikan Filter "Hari ini", "Minggu ini", dll.
- Menampilkan marker (pin lokasi) kustom di peta berdasarkan kategori transaksi.

### `lib/features/history/presentation/pages/transaction_map_detail_screen.dart`
- [NEW] Layar detail transaksi yang menampilkan peta statis lokasi transaksi dan rincian lengkap seperti foto struk, catatan, dan tombol "Edit Transaksi".

### `lib/features/home/presentation/pages/home_screen.dart`
- [MODIFY] Mengubah navigasi klik ikon peta dari yang sebelumnya memunculkan `BottomSheet` menjadi membuka `FinancialTimelineScreen`.

## Verification Plan
### Automated Tests
- Menjalankan `flutter pub get` untuk memastikan dependensi terinstal.
### Manual Verification
- Pengguna diminta untuk membuka aplikasi dan menekan ikon peta di beranda.
- Memastikan Google Maps berhasil dimuat dan menampilkan marker dengan benar.
