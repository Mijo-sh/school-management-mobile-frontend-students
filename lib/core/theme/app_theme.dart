import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: AppColors.purple300,
      primaryContainer: AppColors.purple200,
      secondary: AppColors.purple200,
      secondaryContainer: AppColors.purple400,
      tertiary: AppColors.green100,
      tertiaryContainer: AppColors.white,
      appBarColor: AppColors.purple400,
      error: AppColors.red300,
      errorContainer: AppColors.red100
    ),
    useMaterial3ErrorColors: true,
    surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
    blendLevel: 10,
    appBarStyle: FlexAppBarStyle.primary,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnLevel: 10,
      useM2StyleDividerInM3: true,
      defaultRadius: 24.0,
      segmentedButtonUnselectedForegroundSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      fabForegroundSchemeColor: SchemeColor.onPrimary,
      chipDeleteIconSchemeColor: SchemeColor.primary,
      alignedDropdown: true,
      tabBarItemSchemeColor: SchemeColor.onPrimary,
      tabBarUnselectedItemSchemeColor: SchemeColor.outline,
      searchBarBackgroundSchemeColor: SchemeColor.primaryFixed,
      searchViewBackgroundSchemeColor: SchemeColor.primaryFixed,
      navigationRailUseIndicator: true
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true)
  );

  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: AppColors.purple200,
      primaryContainer: AppColors.purple300,
      primaryLightRef: AppColors.purple300,
      secondary: AppColors.purple100,
      secondaryContainer: AppColors.purple400,
      secondaryLightRef: AppColors.purple200,
      tertiary: AppColors.green100,
      tertiaryContainer: AppColors.green200,
      tertiaryLightRef: AppColors.green100,
      appBarColor: AppColors.purple400,
      error: AppColors.red200,
      errorContainer: AppColors.red400
    ),
    useMaterial3ErrorColors: true,
    surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
    blendLevel: 10,
    appBarStyle: FlexAppBarStyle.primary,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnLevel: 10,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 24.0,
      segmentedButtonUnselectedForegroundSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      fabForegroundSchemeColor: SchemeColor.onPrimary,
      chipDeleteIconSchemeColor: SchemeColor.primary,
      alignedDropdown: true,
      appBarForegroundSchemeColor: SchemeColor.onPrimary,
      appBarIconSchemeColor: SchemeColor.onPrimary,
      appBarActionsIconSchemeColor: SchemeColor.onSecondary,
      tabBarItemSchemeColor: SchemeColor.onPrimary,
      searchBarBackgroundSchemeColor: SchemeColor.primaryFixed,
      searchViewBackgroundSchemeColor: SchemeColor.primaryFixed,
      navigationRailUseIndicator: true
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true)
  );
}