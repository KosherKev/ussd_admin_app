import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Colors - Fortune Teller Dark Theme
/// Inspired by mystical, premium aesthetics with warm amber accents
class AppColors {
  // Background Colors
  static const background = Color(0xFF0B0F14);
  static const surfaceLow = Color(0xFF121417);
  static const surfaceMid = Color(0xFF1A1D22);
  static const surfaceHigh = Color(0xFF242730);

  // Primary Colors
  static const primaryAmber = Color(0xFFFF8A3D);
  static const primaryAmberLight = Color(0xFFFFB685);
  static const primaryAmberDark = Color(0xFFE57A2F);

  // Secondary Colors
  static const secondaryBlue = Color(0xFF3A7FA5);
  static const secondaryBlueLight = Color(0xFF5CA3CB);
  static const secondaryBlueDark = Color(0xFF2B5F7D);

  // Semantic Colors
  static const success = Color(0xFF36C577);
  static const successLight = Color(0xFF5FD999);
  static const successDark = Color(0xFF2BA562);

  static const warning = Color(0xFFE9B44C);
  static const warningLight = Color(0xFFF0C876);
  static const warningDark = Color(0xFFD9A23B);

  static const error = Color(0xFFFF4D4F);
  static const errorLight = Color(0xFFFF7B7D);
  static const errorDark = Color(0xFFE63E40);

  static const info = Color(0xFF4A9EFF);
  static const infoLight = Color(0xFF7BB8FF);
  static const infoDark = Color(0xFF3880D9);

  // Neutral/Gray Scale
  static const white = Color(0xFFFFFFFF);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFE5E5E5);
  static const gray300 = Color(0xFFD4D4D4);
  static const gray400 = Color(0xFFA3A3A3);
  static const gray500 = Color(0xFF737373);
  static const gray600 = Color(0xFF525252);
  static const gray700 = Color(0xFF404040);
  static const gray800 = Color(0xFF262626);
  static const gray900 = Color(0xFF171717);
  static const black = Color(0xFF000000);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB8BCC8);
  static const textTertiary = Color(0xFF8A8E9B);
  static const textDisabled = Color(0xFF5A5E6B);

  // Glass/Frosted Effect
  static const glassBackground = Color(0x14FFFFFF); // 8% white
  static const glassBorder = Color(0x1AFFFFFF); // 10% white
  static const glassShadow = Color(0xA6000000); // 65% black

  // Gradient Colors
  static const gradientWarmStart = Color(0xFFC89B5E);
  static const gradientWarmEnd = Color(0xFF8A5A2B);
  static const gradientCoolStart = Color(0xFF3A5F78);
  static const gradientCoolEnd = Color(0xFF1F2E3A);

  // Chart Colors (for data visualization)
  static const chart1 = Color(0xFFFF8A3D);
  static const chart2 = Color(0xFF3A7FA5);
  static const chart3 = Color(0xFF36C577);
  static const chart4 = Color(0xFFE9B44C);
  static const chart5 = Color(0xFFFF4D4F);
  static const chart6 = Color(0xFF4A9EFF);
}

/// Typography System
class AppTypography {
  static TextTheme textTheme() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      // Display Styles
      displayLarge: GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // Title Styles
      titleLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.25,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // Body Styles
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),

      // Label Styles
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.15,
      ),
    );
  }
}

/// Spacing System
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Border Radius System
class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 28.0;
  static const double full = 9999.0;
}

/// Shadow System
class AppShadows {
  static const shadowSm = [
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const shadowMd = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const shadowLg = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const shadowXl = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const shadowGlass = [
    BoxShadow(
      color: Color(0xA6000000), // 65% black (from design)
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];
}

/// Main Theme Builder
ThemeData buildTheme() {
  final base = ThemeData.dark();
  final textTheme = AppTypography.textTheme();

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    
    // Color Scheme
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primaryAmber,
      primaryContainer: AppColors.primaryAmberDark,
      secondary: AppColors.secondaryBlue,
      secondaryContainer: AppColors.secondaryBlueDark,
      error: AppColors.error,
      errorContainer: AppColors.errorDark,
      surface: AppColors.surfaceLow,
      surfaceContainerHighest: AppColors.surfaceHigh,
      brightness: Brightness.dark,
      onPrimary: AppColors.black,
      onSecondary: AppColors.white,
      onError: AppColors.white,
      onSurface: AppColors.textPrimary,
      outline: AppColors.gray600,
    ),

    // Typography
    textTheme: textTheme,

    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.white),
      iconTheme: const IconThemeData(color: AppColors.white, size: 24),
    ),

    // Card Theme
    // cardTheme: CardTheme(
    //   color: AppColors.surfaceLow,
    //   elevation: 0,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(AppRadius.xl),
    //   ),
    //   margin: const EdgeInsets.all(AppSpacing.xs),
    // ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      
      // Borders
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primaryAmber, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),

      // Labels and Hints
      labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
      errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
      helperStyle: textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        backgroundColor: AppColors.primaryAmber,
        foregroundColor: AppColors.black,
        disabledBackgroundColor: AppColors.gray700,
        disabledForegroundColor: AppColors.textDisabled,
        elevation: 0,
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        foregroundColor: AppColors.primaryAmber,
        textStyle: textTheme.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        foregroundColor: AppColors.primaryAmber,
        side: const BorderSide(color: AppColors.primaryAmber, width: 1.5),
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: AppColors.textDisabled,
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLow,
      selectedItemColor: AppColors.primaryAmber,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: textTheme.labelSmall,
      unselectedLabelStyle: textTheme.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Dialog Theme
    // dialogTheme: DialogTheme(
    //   backgroundColor: AppColors.surfaceMid,
    //   elevation: 24,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(AppRadius.xl),
    //   ),
    //   titleTextStyle: textTheme.titleMedium?.copyWith(color: AppColors.white),
    //   contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
    // ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceMid,
      selectedColor: AppColors.primaryAmber,
      disabledColor: AppColors.gray700,
      labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
      secondaryLabelStyle: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      elevation: 0,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryAmber;
        }
        return AppColors.gray400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryAmberLight.withValues(alpha: 0.5);
        }
        return AppColors.gray700;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryAmber;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.black),
      side: const BorderSide(color: AppColors.gray600, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xxs),
      ),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryAmber;
        }
        return AppColors.gray600;
      }),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryAmber,
      linearTrackColor: AppColors.gray700,
      circularTrackColor: AppColors.gray700,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.gray700,
      thickness: 1,
      space: AppSpacing.md,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primaryAmber.withValues(alpha: 0.1),
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textPrimary,
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryAmber,
      foregroundColor: AppColors.black,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),

    // Tab Bar Theme
    // tabBarTheme: TabBarTheme(
    //   labelColor: AppColors.primaryAmber,
    //   unselectedLabelColor: AppColors.textSecondary,
    //   labelStyle: textTheme.labelLarge,
    //   unselectedLabelStyle: textTheme.labelMedium,
    //   indicator: const UnderlineTabIndicator(
    //     borderSide: BorderSide(
    //       color: AppColors.primaryAmber,
    //       width: 2,
    //     ),
    //   ),
    // ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: AppColors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
    ),
  );
}

/// Gradient Helpers
class AppGradients {
  static LinearGradient warm({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: const [AppColors.gradientWarmStart, AppColors.gradientWarmEnd],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient cool({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: const [AppColors.gradientCoolStart, AppColors.gradientCoolEnd],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient amber({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: const [AppColors.primaryAmberLight, AppColors.primaryAmberDark],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient blue({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: const [AppColors.secondaryBlueLight, AppColors.secondaryBlueDark],
      begin: begin,
      end: end,
    );
  }
}
