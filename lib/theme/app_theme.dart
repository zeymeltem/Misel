import 'package:flutter/material.dart';

/// Tek merkezi tema kaynağı: tüm renkler, fontlar, boyutlar burada.
/// UI katmanındaki widget'lar renk/boyut sabiti tanımlamaz, buradan okur.
abstract final class AppColors {
  static const background = Color(0xFFF3F6EF);
  static const gardenBackground = Color(0xFFD9E8C9);
  static const gardenBanner = Color(0xFFE4F1D6);
  static const gardenBannerText = Color(0xFF4C7A3D);
  static const coinBadge = Color(0xFFF6C453);
  static const coinBadgeText = Color(0xFF6B4A16);
  static const tabSelectedBg = Color(0xFF1F2421);
  static const tabSelectedText = Colors.white;
  static const tabUnselectedText = Color(0xFF6C7268);
  static const cardBackground = Colors.white;
  static const priceText = Color(0xFF4C7A3D);
  static const shopIconCommon = Color(0xFF4FAE6E);
  static const shopIconRare = Color(0xFFE8759A);
  static const shopIconLegendary = Color(0xFF4A7FE0);

  static const streakText = Color(0xFFFF6B4A);
  static const coinPreviewText = Color(0xFF4C7A3D);
  static const sliderTrack = Color(0xFF1F2421);

  static const chipSelectedBg = Color(0xFFDCEBFA);
  static const chipSelectedText = Color(0xFF2563EB);
  static const chipUnselectedBorder = Color(0xFFD9DDD3);
  static const chipUnselectedText = Color(0xFF6C7268);
  static const chipAddBorder = Color(0xFF9CA79A);

  static const swatchBorderSelected = Color(0xFF2563EB);
  static const swatchBorderIdle = Color(0xFFE4E7DE);

  static const taskCardBg = Colors.white;
  static const taskCheckBorder = Color(0xFFC9CFC0);
  static const taskCheckedBg = Color(0xFF3FA65B);
  static const taskTitle = Color(0xFF1F2421);
  static const taskTitleDone = Color(0xFF9CA79A);
  static const routineBadgeBg = Color(0xFFDCEBFA);
  static const routineBadgeText = Color(0xFF2563EB);

  static const warningText = Color(0xFF8A9187);
  static const outlineButtonBorder = Color(0xFFD9DDD3);

  static const statCardBg = Color(0xFFF4F5F0);
  static const statValueText = Color(0xFF1F2421);
  static const avatarBg = Color(0xFFDCEBFA);
  static const avatarText = Color(0xFF2563EB);
  static const chartBarBg = Color(0xFFE6DCD3);
  static const chartBarActive = Color(0xFFFF6B4A);
  static const progressTrackBg = Color(0xFFCDD3C2);
  static const progressFill = Color(0xFF6FCF87);

  /// Etiket rengi paleti; Tag.colorIndex bu listeye mod alınarak eşlenir.
  static const List<Color> tagPalette = [
    Color(0xFF2F80ED),
    Color(0xFF9B51E0),
    Color(0xFFEB5757),
    Color(0xFF2F9E52),
    Color(0xFFF2994A),
    Color(0xFF56CCF2),
  ];
}

abstract final class AppTextStyles {
  static const breadcrumb = TextStyle(fontSize: 16, height: 1.5, color: AppColors.tabUnselectedText);
  static const sectionTitle = TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700);
  static const coinValue = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.coinBadgeText,
  );
  static const tab = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600);
  static const bannerText = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.gardenBannerText,
  );
  static const shopPrice = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: AppColors.priceText,
  );

  static const streak = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.streakText,
  );
  static const fieldLabel = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.tabUnselectedText,
  );
  static const durationValue = TextStyle(fontSize: 48, height: 1.2, fontWeight: FontWeight.w700);
  /// Seans sırasında geri sayan dijital saat (bkz. TimerScreen _ActiveView).
  static const timerClock = TextStyle(
    fontSize: 48,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    color: AppColors.taskTitle,
  );
  static const coinPreview = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.coinPreviewText,
  );
  static const chip = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600);
  static const taskTitle = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500);
  static const routineBadge = TextStyle(
    fontSize: 8,
    height: 1.5,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.routineBadgeText,
  );
  static const warning = TextStyle(fontSize: 16, height: 1.5, color: AppColors.warningText);

  static const profileName = TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w700);
  static const statLabel = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w600,
    color: AppColors.tabUnselectedText,
  );
  static const statValue = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.statValueText,
  );
  static const legend = TextStyle(fontSize: 16, height: 1.5, color: AppColors.tabUnselectedText);
  static const avatarInitials = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.avatarText,
  );
}

abstract final class AppSizes {
  static const screenPadding = 16.0;
  static const cardRadius = 24.0;
  static const bannerRadius = 20.0;
  static const pillRadius = 20.0;
  static const shopItemRadius = 18.0;
  static const shopItemSize = 92.0;
  static const gap = 12.0;

  static const chipRadius = 18.0;
  static const swatchSize = 56.0;
  static const swatchRadius = 14.0;
  static const taskCardRadius = 14.0;
  static const buttonRadius = 14.0;
  static const ringSize = 260.0;

  static const statCardRadius = 16.0;
  static const avatarSize = 96.0;
  static const taskRingSize = 96.0;
  static const chartHeight = 120.0;
  static const barWidth = 18.0;
  static const progressBarHeight = 8.0;

  /// Bahçe harita PNG'sinin (assets/images/garden_map.png) tasarlandığı
  /// piksel boyutu; her "parsel" (harita sayfası) bu boyutta sabittir.
  static const gardenMapWidth = 352.0;
  static const gardenMapHeight = 400.0;

  /// Harita PNG'sinin dış çerçevesi: içerik bu kadar pikselle içeri kayar.
  static const gardenMapBorder = 8.0;

  /// Çerçeve içindeki ızgara: 7 sütun x 8 satır, hücre başına 48px
  /// (7*48 + 2*8 = 352, 8*48 + 2*8 = 400 — harita boyutuyla birebir).
  static const gardenGridCols = 7;
  static const gardenGridRows = 8;
  static const gardenCellSize = 48.0;

  /// Mantar sprite'ının kendi boyutu (pixel art 32px) ve hücre içindeki
  /// yerleşimi: yatayda ortalanır, alttan bu kadar boşluk bırakılır (mantar
  /// zeminden büyüyormuş gibi dursun diye).
  static const gardenMushroomSize = 32.0;
  static const gardenMushroomBottomGap = 5.0;
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
    fontFamily: 'Pixelify',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5),
      bodySmall: TextStyle(fontSize: 16, height: 1.5),
      titleLarge: TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 16, height: 1.2, fontWeight: FontWeight.w600),
    ),
  );
}
