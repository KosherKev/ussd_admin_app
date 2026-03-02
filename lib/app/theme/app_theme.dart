import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// AppColors — ThemeExtension (adaptive light / dark)
// Usage: Theme.of(context).ext  or context.appColors
// ---------------------------------------------------------------------------
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surfaceLow,
    required this.surfaceMid,
    required this.surfaceHigh,
    required this.primaryAmber,
    required this.primaryAmberLight,
    required this.primaryAmberDark,
    required this.secondaryBlue,
    required this.secondaryBlueLight,
    required this.secondaryBlueDark,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.glassBackground,
    required this.glassBorder,
    required this.borderSubtle,
    required this.gradientWarmStart,
    required this.gradientWarmEnd,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.chart6,
  });

  final Color background;
  final Color surfaceLow;
  final Color surfaceMid;
  final Color surfaceHigh;
  final Color primaryAmber;
  final Color primaryAmberLight;
  final Color primaryAmberDark;
  final Color secondaryBlue;
  final Color secondaryBlueLight;
  final Color secondaryBlueDark;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color glassBackground;
  final Color glassBorder;
  final Color borderSubtle;
  final Color gradientWarmStart;
  final Color gradientWarmEnd;
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color chart6;

  // Convenience getters
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ---------- Dark Palette ----------
  static const dark = AppColors(
    background:          Color(0xFF0B0F14),
    surfaceLow:          Color(0xFF121417),
    surfaceMid:          Color(0xFF1A1D22),
    surfaceHigh:         Color(0xFF242730),
    primaryAmber:        Color(0xFFFF8A3D),
    primaryAmberLight:   Color(0xFFFFB685),
    primaryAmberDark:    Color(0xFFE57A2F),
    secondaryBlue:       Color(0xFF3A7FA5),
    secondaryBlueLight:  Color(0xFF5CA3CB),
    secondaryBlueDark:   Color(0xFF2B5F7D),
    success:             Color(0xFF36C577),
    warning:             Color(0xFFE9B44C),
    error:               Color(0xFFFF4D4F),
    info:                Color(0xFF4A9EFF),
    textPrimary:         Color(0xFFFFFFFF),
    textSecondary:       Color(0xFFB8BCC8),
    textTertiary:        Color(0xFF8A8E9B),
    textDisabled:        Color(0xFF5A5E6B),
    glassBackground:     Color(0x14FFFFFF),
    glassBorder:         Color(0x1AFFFFFF),
    borderSubtle:        Color(0xFF2A2D34),
    gradientWarmStart:   Color(0xFFC89B5E),
    gradientWarmEnd:     Color(0xFF8A5A2B),
    chart1:              Color(0xFFFF8A3D),
    chart2:              Color(0xFF3A7FA5),
    chart3:              Color(0xFF36C577),
    chart4:              Color(0xFFE9B44C),
    chart5:              Color(0xFFFF4D4F),
    chart6:              Color(0xFF4A9EFF),
  );

  // ---------- Light Palette ----------
  static const light = AppColors(
    background:          Color(0xFFF5F6FA),
    surfaceLow:          Color(0xFFFFFFFF),
    surfaceMid:          Color(0xFFF0F1F5),
    surfaceHigh:         Color(0xFFE8EAF0),
    primaryAmber:        Color(0xFFE8720C),
    primaryAmberLight:   Color(0xFFFF8A3D),
    primaryAmberDark:    Color(0xFFC45E00),
    secondaryBlue:       Color(0xFF2B6490),
    secondaryBlueLight:  Color(0xFF3A7FA5),
    secondaryBlueDark:   Color(0xFF1C4A6E),
    success:             Color(0xFF1E9E5E),
    warning:             Color(0xFFB8860B),
    error:               Color(0xFFCC2929),
    info:                Color(0xFF1A6FCC),
    textPrimary:         Color(0xFF0F1117),
    textSecondary:       Color(0xFF4A4E5C),
    textTertiary:        Color(0xFF7A7E8B),
    textDisabled:        Color(0xFFB0B4C1),
    glassBackground:     Color(0x0A000000),
    glassBorder:         Color(0x18000000),
    borderSubtle:        Color(0xFFE0E2EA),
    gradientWarmStart:   Color(0xFFFF8A3D),
    gradientWarmEnd:     Color(0xFFE8720C),
    chart1:              Color(0xFFE8720C),
    chart2:              Color(0xFF2B6490),
    chart3:              Color(0xFF1E9E5E),
    chart4:              Color(0xFFB8860B),
    chart5:              Color(0xFFCC2929),
    chart6:              Color(0xFF1A6FCC),
  );

  @override
  AppColors copyWith({
    Color? background, Color? surfaceLow, Color? surfaceMid,
    Color? surfaceHigh, Color? primaryAmber, Color? primaryAmberLight,
    Color? primaryAmberDark, Color? secondaryBlue, Color? secondaryBlueLight,
    Color? secondaryBlueDark, Color? success, Color? warning, Color? error,
    Color? info, Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? textDisabled, Color? glassBackground, Color? glassBorder,
    Color? borderSubtle, Color? gradientWarmStart, Color? gradientWarmEnd,
    Color? chart1, Color? chart2, Color? chart3, Color? chart4,
    Color? chart5, Color? chart6,
  }) {
    return AppColors(
      background:        background        ?? this.background,
      surfaceLow:        surfaceLow        ?? this.surfaceLow,
      surfaceMid:        surfaceMid        ?? this.surfaceMid,
      surfaceHigh:       surfaceHigh       ?? this.surfaceHigh,
      primaryAmber:      primaryAmber      ?? this.primaryAmber,
      primaryAmberLight: primaryAmberLight ?? this.primaryAmberLight,
      primaryAmberDark:  primaryAmberDark  ?? this.primaryAmberDark,
      secondaryBlue:     secondaryBlue     ?? this.secondaryBlue,
      secondaryBlueLight:secondaryBlueLight?? this.secondaryBlueLight,
      secondaryBlueDark: secondaryBlueDark ?? this.secondaryBlueDark,
      success:           success           ?? this.success,
      warning:           warning           ?? this.warning,
      error:             error             ?? this.error,
      info:              info              ?? this.info,
      textPrimary:       textPrimary       ?? this.textPrimary,
      textSecondary:     textSecondary     ?? this.textSecondary,
      textTertiary:      textTertiary      ?? this.textTertiary,
      textDisabled:      textDisabled      ?? this.textDisabled,
      glassBackground:   glassBackground   ?? this.glassBackground,
      glassBorder:       glassBorder       ?? this.glassBorder,
      borderSubtle:      borderSubtle      ?? this.borderSubtle,
      gradientWarmStart: gradientWarmStart ?? this.gradientWarmStart,
      gradientWarmEnd:   gradientWarmEnd   ?? this.gradientWarmEnd,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
      chart6: chart6 ?? this.chart6,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background:        Color.lerp(background,        other.background,        t)!,
      surfaceLow:        Color.lerp(surfaceLow,        other.surfaceLow,        t)!,
      surfaceMid:        Color.lerp(surfaceMid,        other.surfaceMid,        t)!,
      surfaceHigh:       Color.lerp(surfaceHigh,       other.surfaceHigh,       t)!,
      primaryAmber:      Color.lerp(primaryAmber,      other.primaryAmber,      t)!,
      primaryAmberLight: Color.lerp(primaryAmberLight, other.primaryAmberLight, t)!,
      primaryAmberDark:  Color.lerp(primaryAmberDark,  other.primaryAmberDark,  t)!,
      secondaryBlue:     Color.lerp(secondaryBlue,     other.secondaryBlue,     t)!,
      secondaryBlueLight:Color.lerp(secondaryBlueLight,other.secondaryBlueLight,t)!,
      secondaryBlueDark: Color.lerp(secondaryBlueDark, other.secondaryBlueDark, t)!,
      success:           Color.lerp(success,           other.success,           t)!,
      warning:           Color.lerp(warning,           other.warning,           t)!,
      error:             Color.lerp(error,             other.error,             t)!,
      info:              Color.lerp(info,              other.info,              t)!,
      textPrimary:       Color.lerp(textPrimary,       other.textPrimary,       t)!,
      textSecondary:     Color.lerp(textSecondary,     other.textSecondary,     t)!,
      textTertiary:      Color.lerp(textTertiary,      other.textTertiary,      t)!,
      textDisabled:      Color.lerp(textDisabled,      other.textDisabled,      t)!,
      glassBackground:   Color.lerp(glassBackground,   other.glassBackground,   t)!,
      glassBorder:       Color.lerp(glassBorder,       other.glassBorder,       t)!,
      borderSubtle:      Color.lerp(borderSubtle,      other.borderSubtle,      t)!,
      gradientWarmStart: Color.lerp(gradientWarmStart, other.gradientWarmStart, t)!,
      gradientWarmEnd:   Color.lerp(gradientWarmEnd,   other.gradientWarmEnd,   t)!,
      chart1: Color.lerp(chart1, other.chart1, t)!,
      chart2: Color.lerp(chart2, other.chart2, t)!,
      chart3: Color.lerp(chart3, other.chart3, t)!,
      chart4: Color.lerp(chart4, other.chart4, t)!,
      chart5: Color.lerp(chart5, other.chart5, t)!,
      chart6: Color.lerp(chart6, other.chart6, t)!,
    );
  }
}

// Convenience extension on BuildContext
extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------
class AppTypography {
  static TextTheme textTheme() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge:  GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5),
      displayMedium: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.25),
      displaySmall:  GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w600, height: 1.3),
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
      headlineMedium:GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
      headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
      titleLarge:    GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.25),
      titleMedium:   GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall:    GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.1),
      labelMedium:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.1),
      labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.15),
    );
  }
}

// ---------------------------------------------------------------------------
// Spacing / Radius / Shadows
// ---------------------------------------------------------------------------
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs  = 8.0;
  static const double sm  = 12.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
  static const double xxxl= 64.0;
}

class AppRadius {
  static const double xs   = 8.0;
  static const double sm   = 12.0;
  static const double md   = 16.0;
  static const double lg   = 20.0;
  static const double xl   = 24.0;
  static const double xxl  = 28.0;
  static const double full = 9999.0;
}

class AppShadows {
  static List<BoxShadow> sm(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x1A000000) : const Color(0x0F000000), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> md(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x26000000) : const Color(0x14000000), blurRadius: 8, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> lg(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x33000000) : const Color(0x1A000000), blurRadius: 16, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> xl(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x40000000) : const Color(0x20000000), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // Legacy static constants kept for backward compat during migration
  static const shadowSm = [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 1))];
  static const shadowMd = [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))];
  static const shadowLg = [BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 4))];
  static const shadowXl = [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8))];
}

// ---------------------------------------------------------------------------
// Gradient helpers
// ---------------------------------------------------------------------------
class AppGradients {
  static LinearGradient warm({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end   = Alignment.bottomRight,
    AppColors? colors,
  }) {
    return LinearGradient(
      colors: [
        colors?.gradientWarmStart ?? AppColors.dark.gradientWarmStart,
        colors?.gradientWarmEnd   ?? AppColors.dark.gradientWarmEnd,
      ],
      begin: begin,
      end: end,
    );
  }

  static LinearGradient cool({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end   = Alignment.bottomRight,
  }) {
    return const LinearGradient(
      colors: [Color(0xFF3A5F78), Color(0xFF1F2E3A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient amber({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end   = Alignment.bottomRight,
    AppColors? colors,
  }) {
    return LinearGradient(
      colors: [
        colors?.primaryAmberLight ?? AppColors.dark.primaryAmberLight,
        colors?.primaryAmberDark  ?? AppColors.dark.primaryAmberDark,
      ],
      begin: begin,
      end: end,
    );
  }
}

// ---------------------------------------------------------------------------
// Theme builders
// ---------------------------------------------------------------------------
ThemeData buildDarkTheme() {
  const c    = AppColors.dark;
  final text = AppTypography.textTheme();
  return _buildTheme(
    brightness: Brightness.dark,
    c: c,
    text: text,
  );
}

ThemeData buildLightTheme() {
  const c    = AppColors.light;
  final text = AppTypography.textTheme();
  return _buildTheme(
    brightness: Brightness.light,
    c: c,
    text: text,
  );
}

/// Legacy alias — keeps existing code that calls buildTheme() working (returns dark theme).
ThemeData buildTheme() => buildDarkTheme();

ThemeData _buildTheme({
  required Brightness brightness,
  required AppColors c,
  required TextTheme text,
}) {
  final isDark = brightness == Brightness.dark;
  final base   = isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    extensions: [c],
    scaffoldBackgroundColor: c.background,

    colorScheme: base.colorScheme.copyWith(
      primary:                c.primaryAmber,
      primaryContainer:       c.primaryAmberDark,
      secondary:              c.secondaryBlue,
      secondaryContainer:     c.secondaryBlueDark,
      error:                  c.error,
      errorContainer:         c.error.withValues(alpha: 0.2),
      surface:                c.surfaceLow,
      surfaceContainerHighest:c.surfaceHigh,
      brightness:             brightness,
      onPrimary:              isDark ? AppColors.black : AppColors.white,
      onSecondary:            AppColors.white,
      onError:                AppColors.white,
      onSurface:              c.textPrimary,
      outline:                c.borderSubtle,
    ),

    textTheme: text.apply(
      bodyColor:    c.textPrimary,
      displayColor: c.textPrimary,
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: text.titleMedium?.copyWith(color: c.textPrimary),
      iconTheme: IconThemeData(color: c.textPrimary, size: 24),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceMid,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.primaryAmber, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      labelStyle:  text.bodyMedium?.copyWith(color: c.textSecondary),
      hintStyle:   text.bodyMedium?.copyWith(color: c.textTertiary),
      errorStyle:  text.bodySmall?.copyWith(color: c.error),
      helperStyle: text.bodySmall?.copyWith(color: c.textTertiary),
      prefixIconColor: c.textSecondary,
      suffixIconColor: c.textSecondary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        backgroundColor: c.primaryAmber,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        disabledBackgroundColor: c.surfaceHigh,
        disabledForegroundColor: c.textDisabled,
        elevation: 0,
        textStyle: text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        foregroundColor: c.primaryAmber,
        textStyle: text.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        foregroundColor: c.primaryAmber,
        side: BorderSide(color: c.primaryAmber, width: 1.5),
        textStyle: text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.textPrimary,
        backgroundColor: Colors.transparent,
        disabledForegroundColor: c.textDisabled,
        padding: const EdgeInsets.all(AppSpacing.sm),
      ),
    ),

    // Material 3 NavigationBar (used in new HomeShell)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surfaceLow,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primaryAmber.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: c.primaryAmber, size: 24);
        }
        return IconThemeData(color: c.textSecondary, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return text.labelSmall?.copyWith(color: c.primaryAmber, fontWeight: FontWeight.w700);
        }
        return text.labelSmall?.copyWith(color: c.textSecondary);
      }),
      elevation: 0,
      height: 68,
    ),

    // Keep BottomNavigationBar themed for backward compat
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surfaceLow,
      selectedItemColor: c.primaryAmber,
      unselectedItemColor: c.textSecondary,
      selectedLabelStyle: text.labelSmall,
      unselectedLabelStyle: text.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.surfaceHigh,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceMid,
      selectedColor: c.primaryAmber,
      disabledColor: c.surfaceHigh,
      labelStyle: text.labelMedium?.copyWith(color: c.textPrimary),
      secondaryLabelStyle: text.labelSmall?.copyWith(color: c.textSecondary),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      elevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.primaryAmber : c.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? c.primaryAmber.withValues(alpha: 0.4)
            : c.surfaceHigh;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.primaryAmber : Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(isDark ? AppColors.black : AppColors.white),
      side: BorderSide(color: c.borderSubtle, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.xxs)),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primaryAmber,
      linearTrackColor: c.surfaceHigh,
      circularTrackColor: c.surfaceHigh,
    ),

    dividerTheme: DividerThemeData(
      color: c.borderSubtle,
      thickness: 1,
      space: AppSpacing.md,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      tileColor: Colors.transparent,
      selectedTileColor: c.primaryAmber.withValues(alpha: 0.08),
      iconColor: c.textSecondary,
      textColor: c.textPrimary,
      titleTextStyle: text.bodyLarge?.copyWith(color: c.textPrimary),
      subtitleTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primaryAmber,
      foregroundColor: isDark ? AppColors.black : AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      textStyle: text.bodySmall?.copyWith(color: c.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
    ),
  );
}
