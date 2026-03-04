import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// AppColors — ThemeExtension (adaptive light / dark)
// Design system: Refined Financial Brutalism
// Usage: Theme.of(context).extension<AppColors>()!  or  context.appColors
// ---------------------------------------------------------------------------
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    // ── Surface hierarchy ──────────────────────────────────────────────────
    required this.background,   // bgBase
    required this.bgSurface,    // cards, bottom nav
    required this.bgRaised,     // elevated cards
    required this.bgHigh,       // overlapping surfaces
    required this.bgOverlay,    // tooltips, modals
    // ── Legacy surface aliases (backward compat) ───────────────────────────
    required this.surfaceLow,   // == bgSurface
    required this.surfaceMid,   // == bgRaised
    required this.surfaceHigh,  // == bgHigh
    // ── Borders ───────────────────────────────────────────────────────────
    required this.borderSubtle,
    required this.borderMid,
    required this.borderStrong,
    // ── Amber accent ──────────────────────────────────────────────────────
    required this.primaryAmber,
    required this.primaryAmberLight,
    required this.primaryAmberDark,
    required this.amberBg,       // low-opacity amber fill
    required this.amberBorder,   // low-opacity amber border
    // ── Semantic ──────────────────────────────────────────────────────────
    required this.success,
    required this.successBg,
    required this.successBorder,
    required this.warning,
    required this.warningBg,
    required this.warningBorder,
    required this.error,
    required this.errorBg,
    required this.errorBorder,
    required this.info,
    required this.infoBg,
    // ── Text ──────────────────────────────────────────────────────────────
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textMono,      // blue-grey for refs/codes
    // ── Legacy (kept for backward compat) ─────────────────────────────────
    required this.secondaryBlue,
    required this.secondaryBlueLight,
    required this.secondaryBlueDark,
    required this.glassBackground,
    required this.glassBorder,
    required this.gradientWarmStart,
    required this.gradientWarmEnd,
    // ── Charts ────────────────────────────────────────────────────────────
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
    required this.chart6,
  });

  // ── Surface hierarchy ────────────────────────────────────────────────────
  final Color background;
  final Color bgSurface;
  final Color bgRaised;
  final Color bgHigh;
  final Color bgOverlay;
  // ── Legacy aliases ───────────────────────────────────────────────────────
  final Color surfaceLow;
  final Color surfaceMid;
  final Color surfaceHigh;
  // ── Borders ──────────────────────────────────────────────────────────────
  final Color borderSubtle;
  final Color borderMid;
  final Color borderStrong;
  // ── Amber ────────────────────────────────────────────────────────────────
  final Color primaryAmber;
  final Color primaryAmberLight;
  final Color primaryAmberDark;
  final Color amberBg;
  final Color amberBorder;
  // ── Semantic ─────────────────────────────────────────────────────────────
  final Color success;
  final Color successBg;
  final Color successBorder;
  final Color warning;
  final Color warningBg;
  final Color warningBorder;
  final Color error;
  final Color errorBg;
  final Color errorBorder;
  final Color info;
  final Color infoBg;
  // ── Text ─────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textMono;
  // ── Legacy ───────────────────────────────────────────────────────────────
  final Color secondaryBlue;
  final Color secondaryBlueLight;
  final Color secondaryBlueDark;
  final Color glassBackground;
  final Color glassBorder;
  final Color gradientWarmStart;
  final Color gradientWarmEnd;
  // ── Charts ───────────────────────────────────────────────────────────────
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;
  final Color chart6;

  // Convenience static constants
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // ── Dark Palette ─────────────────────────────────────────────────────────
  static const dark = AppColors(
    background:          Color(0xFF080B0F),
    bgSurface:           Color(0xFF0F1318),
    bgRaised:            Color(0xFF161B22),
    bgHigh:              Color(0xFF1E242D),
    bgOverlay:           Color(0xFF262D38),
    // legacy aliases
    surfaceLow:          Color(0xFF0F1318),
    surfaceMid:          Color(0xFF161B22),
    surfaceHigh:         Color(0xFF1E242D),
    // borders
    borderSubtle:        Color(0x0FFFFFFF),   // 6% white
    borderMid:           Color(0x1AFFFFFF),   // 10% white
    borderStrong:        Color(0x2DFFFFFF),   // 18% white
    // amber
    primaryAmber:        Color(0xFFE8831C),
    primaryAmberLight:   Color(0xFFF59532),
    primaryAmberDark:    Color(0xFFCC6D0A),
    amberBg:             Color(0x1AE8831C),   // 10%
    amberBorder:         Color(0x40E8831C),   // 25%
    // semantic
    success:             Color(0xFF28A96A),
    successBg:           Color(0x1A28A96A),
    successBorder:       Color(0x4028A96A),
    warning:             Color(0xFFD4922A),
    warningBg:           Color(0x1AD4922A),
    warningBorder:       Color(0x40D4922A),
    error:               Color(0xFFE03C3C),
    errorBg:             Color(0x1AE03C3C),
    errorBorder:         Color(0x40E03C3C),
    info:                Color(0xFF3A7FBB),
    infoBg:              Color(0x1A3A7FBB),
    // text
    textPrimary:         Color(0xFFF0F2F5),
    textSecondary:       Color(0xFF8B919E),
    textTertiary:        Color(0xFF555D6B),
    textDisabled:        Color(0xFF353B46),
    textMono:            Color(0xFF7AAEC8),   // blue-grey for refs/codes
    // legacy
    secondaryBlue:       Color(0xFF3A7FBB),
    secondaryBlueLight:  Color(0xFF5CA3CB),
    secondaryBlueDark:   Color(0xFF2B5F7D),
    glassBackground:     Color(0x14FFFFFF),
    glassBorder:         Color(0x1AFFFFFF),
    gradientWarmStart:   Color(0xFFE8831C),
    gradientWarmEnd:     Color(0xFFCC6D0A),
    // charts
    chart1:              Color(0xFFE8831C),
    chart2:              Color(0xFF3A7FBB),
    chart3:              Color(0xFF28A96A),
    chart4:              Color(0xFFD4922A),
    chart5:              Color(0xFFE03C3C),
    chart6:              Color(0xFF4A9EFF),
  );

  // ── Light Palette ─────────────────────────────────────────────────────────
  static const light = AppColors(
    background:          Color(0xFFF3F4F7),
    bgSurface:           Color(0xFFFFFFFF),
    bgRaised:            Color(0xFFF8F9FB),
    bgHigh:              Color(0xFFEDEEF2),
    bgOverlay:           Color(0xFFE5E7EC),
    // legacy aliases
    surfaceLow:          Color(0xFFFFFFFF),
    surfaceMid:          Color(0xFFF8F9FB),
    surfaceHigh:         Color(0xFFEDEEF2),
    // borders
    borderSubtle:        Color(0x0D000000),   // 5%
    borderMid:           Color(0x14000000),   // 8%
    borderStrong:        Color(0x24000000),   // 14%
    // amber
    primaryAmber:        Color(0xFFC96A00),
    primaryAmberLight:   Color(0xFFE07800),
    primaryAmberDark:    Color(0xFFA85500),
    amberBg:             Color(0x14C96A00),   // 8%
    amberBorder:         Color(0x33C96A00),   // 20%
    // semantic
    success:             Color(0xFF1A8A52),
    successBg:           Color(0x141A8A52),
    successBorder:       Color(0x331A8A52),
    warning:             Color(0xFFB07020),
    warningBg:           Color(0x14B07020),
    warningBorder:       Color(0x33B07020),
    error:               Color(0xFFC42B2B),
    errorBg:             Color(0x14C42B2B),
    errorBorder:         Color(0x33C42B2B),
    info:                Color(0xFF2166A0),
    infoBg:              Color(0x142166A0),
    // text
    textPrimary:         Color(0xFF0D1117),
    textSecondary:       Color(0xFF5A6170),
    textTertiary:        Color(0xFF8E96A3),
    textDisabled:        Color(0xFFBDC2CC),
    textMono:            Color(0xFF4A7A9B),
    // legacy
    secondaryBlue:       Color(0xFF2B6490),
    secondaryBlueLight:  Color(0xFF3A7FA5),
    secondaryBlueDark:   Color(0xFF1C4A6E),
    glassBackground:     Color(0x0A000000),
    glassBorder:         Color(0x18000000),
    gradientWarmStart:   Color(0xFFC96A00),
    gradientWarmEnd:     Color(0xFFA85500),
    // charts
    chart1:              Color(0xFFC96A00),
    chart2:              Color(0xFF2166A0),
    chart3:              Color(0xFF1A8A52),
    chart4:              Color(0xFFB07020),
    chart5:              Color(0xFFC42B2B),
    chart6:              Color(0xFF1A6FCC),
  );

  @override
  AppColors copyWith({
    Color? background, Color? bgSurface, Color? bgRaised, Color? bgHigh,
    Color? bgOverlay, Color? surfaceLow, Color? surfaceMid, Color? surfaceHigh,
    Color? borderSubtle, Color? borderMid, Color? borderStrong,
    Color? primaryAmber, Color? primaryAmberLight, Color? primaryAmberDark,
    Color? amberBg, Color? amberBorder,
    Color? success, Color? successBg, Color? successBorder,
    Color? warning, Color? warningBg, Color? warningBorder,
    Color? error, Color? errorBg, Color? errorBorder,
    Color? info, Color? infoBg,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
    Color? textDisabled, Color? textMono,
    Color? secondaryBlue, Color? secondaryBlueLight, Color? secondaryBlueDark,
    Color? glassBackground, Color? glassBorder,
    Color? gradientWarmStart, Color? gradientWarmEnd,
    Color? chart1, Color? chart2, Color? chart3,
    Color? chart4, Color? chart5, Color? chart6,
  }) {
    return AppColors(
      background:         background         ?? this.background,
      bgSurface:          bgSurface          ?? this.bgSurface,
      bgRaised:           bgRaised           ?? this.bgRaised,
      bgHigh:             bgHigh             ?? this.bgHigh,
      bgOverlay:          bgOverlay          ?? this.bgOverlay,
      surfaceLow:         surfaceLow         ?? this.surfaceLow,
      surfaceMid:         surfaceMid         ?? this.surfaceMid,
      surfaceHigh:        surfaceHigh        ?? this.surfaceHigh,
      borderSubtle:       borderSubtle       ?? this.borderSubtle,
      borderMid:          borderMid          ?? this.borderMid,
      borderStrong:       borderStrong       ?? this.borderStrong,
      primaryAmber:       primaryAmber       ?? this.primaryAmber,
      primaryAmberLight:  primaryAmberLight  ?? this.primaryAmberLight,
      primaryAmberDark:   primaryAmberDark   ?? this.primaryAmberDark,
      amberBg:            amberBg            ?? this.amberBg,
      amberBorder:        amberBorder        ?? this.amberBorder,
      success:            success            ?? this.success,
      successBg:          successBg          ?? this.successBg,
      successBorder:      successBorder      ?? this.successBorder,
      warning:            warning            ?? this.warning,
      warningBg:          warningBg          ?? this.warningBg,
      warningBorder:      warningBorder      ?? this.warningBorder,
      error:              error              ?? this.error,
      errorBg:            errorBg            ?? this.errorBg,
      errorBorder:        errorBorder        ?? this.errorBorder,
      info:               info               ?? this.info,
      infoBg:             infoBg             ?? this.infoBg,
      textPrimary:        textPrimary        ?? this.textPrimary,
      textSecondary:      textSecondary      ?? this.textSecondary,
      textTertiary:       textTertiary       ?? this.textTertiary,
      textDisabled:       textDisabled       ?? this.textDisabled,
      textMono:           textMono           ?? this.textMono,
      secondaryBlue:      secondaryBlue      ?? this.secondaryBlue,
      secondaryBlueLight: secondaryBlueLight ?? this.secondaryBlueLight,
      secondaryBlueDark:  secondaryBlueDark  ?? this.secondaryBlueDark,
      glassBackground:    glassBackground    ?? this.glassBackground,
      glassBorder:        glassBorder        ?? this.glassBorder,
      gradientWarmStart:  gradientWarmStart  ?? this.gradientWarmStart,
      gradientWarmEnd:    gradientWarmEnd    ?? this.gradientWarmEnd,
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
      background:         Color.lerp(background,         other.background,         t)!,
      bgSurface:          Color.lerp(bgSurface,          other.bgSurface,          t)!,
      bgRaised:           Color.lerp(bgRaised,           other.bgRaised,           t)!,
      bgHigh:             Color.lerp(bgHigh,             other.bgHigh,             t)!,
      bgOverlay:          Color.lerp(bgOverlay,          other.bgOverlay,          t)!,
      surfaceLow:         Color.lerp(surfaceLow,         other.surfaceLow,         t)!,
      surfaceMid:         Color.lerp(surfaceMid,         other.surfaceMid,         t)!,
      surfaceHigh:        Color.lerp(surfaceHigh,        other.surfaceHigh,        t)!,
      borderSubtle:       Color.lerp(borderSubtle,       other.borderSubtle,       t)!,
      borderMid:          Color.lerp(borderMid,          other.borderMid,          t)!,
      borderStrong:       Color.lerp(borderStrong,       other.borderStrong,       t)!,
      primaryAmber:       Color.lerp(primaryAmber,       other.primaryAmber,       t)!,
      primaryAmberLight:  Color.lerp(primaryAmberLight,  other.primaryAmberLight,  t)!,
      primaryAmberDark:   Color.lerp(primaryAmberDark,   other.primaryAmberDark,   t)!,
      amberBg:            Color.lerp(amberBg,            other.amberBg,            t)!,
      amberBorder:        Color.lerp(amberBorder,        other.amberBorder,        t)!,
      success:            Color.lerp(success,            other.success,            t)!,
      successBg:          Color.lerp(successBg,          other.successBg,          t)!,
      successBorder:      Color.lerp(successBorder,      other.successBorder,      t)!,
      warning:            Color.lerp(warning,            other.warning,            t)!,
      warningBg:          Color.lerp(warningBg,          other.warningBg,          t)!,
      warningBorder:      Color.lerp(warningBorder,      other.warningBorder,      t)!,
      error:              Color.lerp(error,              other.error,              t)!,
      errorBg:            Color.lerp(errorBg,            other.errorBg,            t)!,
      errorBorder:        Color.lerp(errorBorder,        other.errorBorder,        t)!,
      info:               Color.lerp(info,               other.info,               t)!,
      infoBg:             Color.lerp(infoBg,             other.infoBg,             t)!,
      textPrimary:        Color.lerp(textPrimary,        other.textPrimary,        t)!,
      textSecondary:      Color.lerp(textSecondary,      other.textSecondary,      t)!,
      textTertiary:       Color.lerp(textTertiary,       other.textTertiary,       t)!,
      textDisabled:       Color.lerp(textDisabled,       other.textDisabled,       t)!,
      textMono:           Color.lerp(textMono,           other.textMono,           t)!,
      secondaryBlue:      Color.lerp(secondaryBlue,      other.secondaryBlue,      t)!,
      secondaryBlueLight: Color.lerp(secondaryBlueLight, other.secondaryBlueLight, t)!,
      secondaryBlueDark:  Color.lerp(secondaryBlueDark,  other.secondaryBlueDark,  t)!,
      glassBackground:    Color.lerp(glassBackground,    other.glassBackground,    t)!,
      glassBorder:        Color.lerp(glassBorder,        other.glassBorder,        t)!,
      gradientWarmStart:  Color.lerp(gradientWarmStart,  other.gradientWarmStart,  t)!,
      gradientWarmEnd:    Color.lerp(gradientWarmEnd,    other.gradientWarmEnd,    t)!,
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
// Typography — Sora (UI) + DM Mono (refs/codes)
// ---------------------------------------------------------------------------
class AppTypography {
  static TextTheme textTheme() {
    final base = GoogleFonts.soraTextTheme();
    return base.copyWith(
      // Display scale — Sora
      displayLarge:  GoogleFonts.sora(fontSize: 40, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.5),
      displayMedium: GoogleFonts.sora(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2,  letterSpacing: -0.25),
      displaySmall:  GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w600, height: 1.25),
      // Headline scale
      headlineLarge: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
      headlineMedium:GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
      headlineSmall: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
      // Title scale
      titleLarge:    GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: -0.15),
      titleMedium:   GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall:    GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
      // Body scale
      bodyLarge:     GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium:    GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall:     GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5),
      // Label scale
      labelLarge:    GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.1),
      labelMedium:   GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.1),
      labelSmall:    GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3, letterSpacing: 0.1),
    );
  }

  // ── Special styles (not in Material textTheme) ───────────────────────────

  /// Hero display: 56px Sora w800 — used on splash/login wordmark.
  static TextStyle displayHero(Color color) => GoogleFonts.sora(
    fontSize: 56, fontWeight: FontWeight.w800, height: 1.05,
    letterSpacing: -1.0, color: color,
  );

  /// Mono label: 12px DM Mono — used for refs, codes, amounts.
  static TextStyle labelMono(Color color) => GoogleFonts.dmMono(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.4,
    letterSpacing: 0.02, color: color,
  );

  /// Mono body: 13px DM Mono — used for longer code/ref blocks.
  static TextStyle monoBody(Color color) => GoogleFonts.dmMono(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5, color: color,
  );
}

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------
class AppSpacing {
  static const double xxs  = 4.0;
  static const double xs   = 8.0;
  static const double sm   = 12.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;
}

// ---------------------------------------------------------------------------
// Radius — Reduced to match Refined Financial Brutalism tokens
// ---------------------------------------------------------------------------
class AppRadius {
  static const double xs   = 4.0;
  static const double sm   = 6.0;
  static const double md   = 10.0;
  static const double lg   = 14.0;
  static const double xl   = 18.0;
  static const double xxl  = 22.0;
  static const double full = 9999.0;
}

// ---------------------------------------------------------------------------
// Shadows — border-based, no glow
// AppShadows.card: 1px borderStrong border as decoration (no shadow blur).
// ---------------------------------------------------------------------------
class AppShadows {
  /// Standard card border decoration (use instead of BoxShadow).
  static BoxDecoration cardDecoration({required Color borderColor, required Color fillColor, double radius = AppRadius.md}) {
    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
    );
  }

  // Kept for backward compat — minimal shadow, almost transparent
  static List<BoxShadow> sm(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x14000000) : const Color(0x0A000000), blurRadius: 2, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> md(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x1E000000) : const Color(0x0F000000), blurRadius: 4, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> lg(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x29000000) : const Color(0x14000000), blurRadius: 8, offset: const Offset(0, 4)),
  ];
  static List<BoxShadow> xl(bool isDark) => [
    BoxShadow(color: isDark ? const Color(0x33000000) : const Color(0x1A000000), blurRadius: 12, offset: const Offset(0, 6)),
  ];

  // Legacy static constants (backward compat)
  static const shadowSm = [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))];
  static const shadowMd = [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))];
  static const shadowLg = [BoxShadow(color: Color(0x1E000000), blurRadius: 8, offset: Offset(0, 4))];
  static const shadowXl = [BoxShadow(color: Color(0x29000000), blurRadius: 12, offset: Offset(0, 6))];
}

// ---------------------------------------------------------------------------
// Gradient helpers
// ---------------------------------------------------------------------------
class AppGradients {
  /// Warm amber gradient — clean 2-stop linear per Refined Financial Brutalism.
  static LinearGradient amber({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end   = Alignment.bottomRight,
    AppColors? colors,
  }) {
    final base = colors?.primaryAmber ?? AppColors.dark.primaryAmber;
    return LinearGradient(
      colors: [base, base.withValues(alpha: 0.7)],
      begin: begin,
      end: end,
    );
  }

  /// Legacy warm gradient — kept for backward compat.
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

  /// Cool blue gradient — legacy.
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
}

// ---------------------------------------------------------------------------
// Theme builders
// ---------------------------------------------------------------------------
ThemeData buildDarkTheme()  => _buildTheme(brightness: Brightness.dark,  c: AppColors.dark);
ThemeData buildLightTheme() => _buildTheme(brightness: Brightness.light, c: AppColors.light);

/// Legacy alias — keeps existing code that calls buildTheme() working.
ThemeData buildTheme() => buildDarkTheme();

ThemeData _buildTheme({
  required Brightness brightness,
  required AppColors c,
}) {
  final isDark = brightness == Brightness.dark;
  final base   = isDark ? ThemeData.dark() : ThemeData.light();
  final text   = AppTypography.textTheme();

  return base.copyWith(
    extensions: [c],
    scaffoldBackgroundColor: c.background,

    colorScheme: base.colorScheme.copyWith(
      primary:                c.primaryAmber,
      primaryContainer:       c.primaryAmberDark,
      secondary:              c.secondaryBlue,
      secondaryContainer:     c.secondaryBlueDark,
      error:                  c.error,
      errorContainer:         c.errorBg,
      surface:                c.bgSurface,
      surfaceContainerHighest:c.bgHigh,
      brightness:             brightness,
      onPrimary:              isDark ? AppColors.black : AppColors.white,
      onSecondary:            AppColors.white,
      onError:                AppColors.white,
      onSurface:              c.textPrimary,
      outline:                c.borderMid,
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
      fillColor: c.bgRaised,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: c.borderMid, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: c.primaryAmber, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: c.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: c.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        backgroundColor: c.primaryAmber,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        disabledBackgroundColor: c.bgHigh,
        disabledForegroundColor: c.textDisabled,
        elevation: 0,
        textStyle: text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        foregroundColor: c.primaryAmber,
        textStyle: text.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
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
        padding: const EdgeInsets.all(AppSpacing.xs),
      ),
    ),

    // NavigationBar — custom bottom nav will replace this in Phase 9,
    // but keep themed for any screen that still uses NavigationBar temporarily.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.bgSurface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primaryAmber.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: c.primaryAmber, size: 22);
        }
        return IconThemeData(color: c.textTertiary, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return text.labelSmall?.copyWith(color: c.primaryAmber, fontWeight: FontWeight.w700);
        }
        return text.labelSmall?.copyWith(color: c.textTertiary);
      }),
      elevation: 0,
      height: 64,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.bgSurface,
      selectedItemColor: c.primaryAmber,
      unselectedItemColor: c.textTertiary,
      selectedLabelStyle: text.labelSmall,
      unselectedLabelStyle: text.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.bgHigh,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: c.bgRaised,
      selectedColor: c.primaryAmber,
      disabledColor: c.bgHigh,
      labelStyle: text.labelMedium?.copyWith(color: c.textPrimary),
      secondaryLabelStyle: text.labelSmall?.copyWith(color: c.textSecondary),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      elevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.primaryAmber : c.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? c.primaryAmber.withValues(alpha: 0.35)
            : c.bgHigh;
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? c.primaryAmber : Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(isDark ? AppColors.black : AppColors.white),
      side: BorderSide(color: c.borderMid, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primaryAmber,
      linearTrackColor: c.bgHigh,
      circularTrackColor: c.bgHigh,
    ),

    dividerTheme: DividerThemeData(
      color: c.borderSubtle,
      thickness: 1,
      space: AppSpacing.md,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      tileColor: Colors.transparent,
      selectedTileColor: c.primaryAmber.withValues(alpha: 0.07),
      iconColor: c.textSecondary,
      textColor: c.textPrimary,
      titleTextStyle: text.bodyLarge?.copyWith(color: c.textPrimary),
      subtitleTextStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.primaryAmber,
      foregroundColor: isDark ? AppColors.black : AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.bgOverlay,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: c.borderMid, width: 1),
      ),
      textStyle: text.bodySmall?.copyWith(color: c.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
    ),
  );
}
