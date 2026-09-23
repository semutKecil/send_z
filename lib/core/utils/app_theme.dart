import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade the package to version 8.4.0.
///
/// Use it in a [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );
abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.mango,
    // Convenience direct styling properties.
    tabBarStyle: FlexTabBarStyle.universal,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      useMaterial3Typography: true,
      defaultRadius: 6.0,
      outlinedButtonBorderWidth: 1.0,
      outlinedButtonPressedBorderWidth: 2.0,
      segmentedButtonSchemeColor: SchemeColor.primary,
      segmentedButtonSelectedForegroundSchemeColor: SchemeColor.onPrimary,
      segmentedButtonBorderWidth: 1.0,
      switchSchemeColor: SchemeColor.primary,
      sliderTrackHeight: 3,
      progressIndicatorLinearMinHeight: 3,
      progressIndicatorStrokeWidth: 3,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorIsDense: true,
      inputDecoratorBackgroundAlpha: 25,
      inputDecoratorBorderSchemeColor: SchemeColor.primary,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: false,
      inputDecoratorFocusedBorderWidth: 1.5,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.onPrimaryFixedVariant,
      listTileSelectedSchemeColor: SchemeColor.onPrimaryContainer,
      listTileSelectedTileSchemeColor: SchemeColor.primaryContainer,
      fabUseShape: true,
      fabAlwaysCircular: true,
      fabSchemeColor: SchemeColor.primaryContainer,
      fabForegroundSchemeColor: SchemeColor.onPrimaryContainer,
      popupMenuElevation: 5.0,
      alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      useInputDecoratorThemeInDialogs: true,
      timePickerElementRadius: 6.0,
      datePickerHeaderBackgroundSchemeColor: SchemeColor.primary,
      datePickerHeaderForegroundSchemeColor: SchemeColor.onPrimary,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      appBarBackgroundSchemeColor: SchemeColor.primary,
      tabBarUnselectedItemOpacity: 0.83,
      tabBarIndicatorWeight: 6,
      tabBarIndicatorTopRadius: 4,
      tabBarDividerColor: Color(0x00000000),
      bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.onPrimary,
      bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.primaryFixed,
      bottomNavigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
      bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.primaryFixed,
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.primary,
      bottomNavigationBarElevation: 0.0,
      menuBarShadowColor: Color(0x00000000),
      menuIndicatorBackgroundSchemeColor: SchemeColor.primaryContainer,
      menuIndicatorForegroundSchemeColor: SchemeColor.onPrimaryContainer,
      searchBarElevation: 0.0,
      searchViewElevation: 0.0,
      searchUseGlobalShape: true,
      navigationBarMutedUnselectedLabel: true,
      navigationBarMutedUnselectedIcon: true,
      navigationBarIndicatorSchemeColor: SchemeColor.onPrimary,
      navigationBarBackgroundSchemeColor: SchemeColor.primary,
      navigationBarElevation: 0.0,
      navigationRailMutedUnselectedLabel: true,
      navigationRailMutedUnselectedIcon: true,
      navigationRailUseIndicator: true,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
      navigationRailLabelType: NavigationRailLabelType.selected,
    ),
    // ColorScheme seed generation configuration for light mode.
    keyColors: const FlexKeyColors(),
    tones: FlexSchemeVariant.soft.tones(Brightness.light),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.mango,
    // Convenience direct styling properties.
    tabBarStyle: FlexTabBarStyle.universal,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      blendOnColors: true,
      useMaterial3Typography: true,
      defaultRadius: 6.0,
      outlinedButtonBorderWidth: 1.0,
      outlinedButtonPressedBorderWidth: 2.0,
      segmentedButtonSchemeColor: SchemeColor.primary,
      segmentedButtonSelectedForegroundSchemeColor: SchemeColor.onPrimary,
      segmentedButtonBorderWidth: 1.0,
      switchSchemeColor: SchemeColor.primary,
      sliderTrackHeight: 3,
      progressIndicatorLinearMinHeight: 3,
      progressIndicatorStrokeWidth: 3,
      inputDecoratorSchemeColor: SchemeColor.primary,
      inputDecoratorIsFilled: true,
      inputDecoratorIsDense: true,
      inputDecoratorBackgroundAlpha: 33,
      inputDecoratorBorderSchemeColor: SchemeColor.primary,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: false,
      inputDecoratorFocusedBorderWidth: 1.5,
      inputDecoratorPrefixIconSchemeColor: SchemeColor.primaryFixed,
      listTileSelectedSchemeColor: SchemeColor.onPrimaryContainer,
      listTileSelectedTileSchemeColor: SchemeColor.primaryContainer,
      fabUseShape: true,
      fabAlwaysCircular: true,
      fabSchemeColor: SchemeColor.primaryContainer,
      fabForegroundSchemeColor: SchemeColor.onPrimaryContainer,
      popupMenuElevation: 5.0,
      alignedDropdown: true,
      tooltipRadius: 4,
      tooltipSchemeColor: SchemeColor.inverseSurface,
      tooltipOpacity: 0.9,
      useInputDecoratorThemeInDialogs: true,
      timePickerElementRadius: 6.0,
      datePickerHeaderBackgroundSchemeColor: SchemeColor.primary,
      datePickerHeaderForegroundSchemeColor: SchemeColor.onPrimary,
      snackBarElevation: 6,
      snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
      tabBarIndicatorWeight: 6,
      tabBarIndicatorTopRadius: 4,
      tabBarDividerColor: Color(0x00000000),
      bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.onPrimary,
      bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.primaryFixed,
      bottomNavigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
      bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.primaryFixed,
      bottomNavigationBarBackgroundSchemeColor: SchemeColor.primary,
      bottomNavigationBarElevation: 0.0,
      menuBarShadowColor: Color(0x00000000),
      menuIndicatorBackgroundSchemeColor: SchemeColor.primaryContainer,
      menuIndicatorForegroundSchemeColor: SchemeColor.onPrimaryContainer,
      searchBarElevation: 0.0,
      searchViewElevation: 0.0,
      searchUseGlobalShape: true,
      navigationBarMutedUnselectedLabel: true,
      navigationBarMutedUnselectedIcon: true,
      navigationBarIndicatorSchemeColor: SchemeColor.onPrimary,
      navigationBarBackgroundSchemeColor: SchemeColor.primary,
      navigationBarElevation: 0.0,
      navigationRailMutedUnselectedLabel: true,
      navigationRailMutedUnselectedIcon: true,
      navigationRailUseIndicator: true,
      navigationRailIndicatorSchemeColor: SchemeColor.primary,
      navigationRailLabelType: NavigationRailLabelType.selected,
    ),
    // ColorScheme seed configuration setup for dark mode.
    keyColors: const FlexKeyColors(),
    tones: FlexSchemeVariant.soft.tones(Brightness.dark),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
