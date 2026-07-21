import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  // --- Font Sizes (menggunakan .sp agar responsif terhadap setelan font pengguna) ---
  static double get font10 => 10.sp;
  static double get font12 => 12.sp;
  static double get font14 => 14.sp;
  static double get font16 => 16.sp;
  static double get font18 => 18.sp;
  static double get font20 => 20.sp;
  static double get font24 => 24.sp;
  static double get font32 => 32.sp;

  // --- Padding & Margin (menggunakan .w atau .h) ---
  // Gunakan .w untuk padding horizontal dan .h untuk padding vertikal
  static double get padding4 => 4.w;
  static double get padding8 => 8.w;
  static double get padding12 => 12.w;
  static double get padding16 => 16.w;
  static double get padding20 => 20.w;
  static double get padding24 => 24.w;
  static double get padding32 => 32.w;
  
  static double get paddingV4 => 4.h;
  static double get paddingV8 => 8.h;
  static double get paddingV12 => 12.h;
  static double get paddingV16 => 16.h;
  static double get paddingV20 => 20.h;
  static double get paddingV24 => 24.h;
  static double get paddingV32 => 32.h;

  // --- Radius (menggunakan .r) ---
  static double get radius4 => 4.r;
  static double get radius8 => 8.r;
  static double get radius12 => 12.r;
  static double get radius16 => 16.r;
  static double get radius24 => 24.r;
  static double get radius32 => 32.r;

  // --- Icon Sizes (menggunakan .w atau .sp tergantung preferensi) ---
  static double get icon16 => 16.w;
  static double get icon20 => 20.w;
  static double get icon24 => 24.w;
  static double get icon32 => 32.w;
  static double get icon48 => 48.w;

  // --- Button Height (menggunakan .h) ---
  static double get buttonHeight => 48.h;
  static double get buttonHeightSmall => 36.h;

  // --- General Width & Height (menggunakan .w dan .h) ---
  static double get screenWidth => 1.sw;
  static double get screenHeight => 1.sh;

  // Helper function: custom width and height
  static double customWidth(double value) => value.w;
  static double customHeight(double value) => value.h;
  static double customFont(double value) => value.sp;
  static double customRadius(double value) => value.r;
}
