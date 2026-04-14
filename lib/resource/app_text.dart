import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppText {
  static TextStyle get headingLarge => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get scoreLabel => TextStyle(
        fontSize: 13.sp,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get scoreValue => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get turnIndicator => TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonLabel => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      );
}
