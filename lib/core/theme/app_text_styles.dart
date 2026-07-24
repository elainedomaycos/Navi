import 'package:flutter/material.dart';
import 'app_colors.dart';

class NaviTextStyles {
  NaviTextStyles._();

  static const _font = 'Nunito';

  static const displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: NaviColors.textDark,
    letterSpacing: -0.5,
  );

  static const heading1 = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: NaviColors.textDark,
  );

  static const heading2 = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: NaviColors.textDark,
  );

  static const bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: NaviColors.textDark,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: NaviColors.textMid,
    height: 1.5,
  );

  static const label = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: NaviColors.textLight,
    letterSpacing: 0.3,
  );

  static const button = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const tagline = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: NaviColors.primaryLight,
    letterSpacing: 0.4,
  );
}
