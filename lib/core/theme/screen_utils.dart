import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A utility class that provides easy access to ScreenUtil functionality
/// for responsive design throughout the app.
class Responsive {
  /// Convert width dimension to responsive size
  static double w(double width) => width.w;

  /// Convert height dimension to responsive size
  static double h(double height) => height.h;

  /// Convert radius dimension to responsive size
  static double r(double radius) => radius.r;

  /// Convert font size to responsive size
  static double sp(double fontSize) => fontSize.sp;

  /// Convert width with adaptation (minimum size guaranteed)
  static double adaptW(double width) => width.sw;

  /// Convert height with adaptation (minimum size guaranteed)
  static double adaptH(double height) => height.sh;

  /// Create responsive EdgeInsets with adaptive sizes
  static EdgeInsets padding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left.w,
      top: top.h,
      right: right.w,
      bottom: bottom.h,
    );
  }

  /// Create responsive EdgeInsets with symmetric padding
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(horizontal: horizontal.w, vertical: vertical.h);
  }

  /// Create responsive EdgeInsets with all sides equal
  static EdgeInsets all(double value) {
    return EdgeInsets.all(value.r);
  }

  /// Get responsive size constraints
  static BoxConstraints constraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth?.w ?? 0.0,
      maxWidth: maxWidth?.w ?? double.infinity,
      minHeight: minHeight?.h ?? 0.0,
      maxHeight: maxHeight?.h ?? double.infinity,
    );
  }

  /// Check if current device is a tablet (based on screen width)
  static bool get isTablet => ScreenUtil().screenWidth >= 600;

  /// Check if current device is a phone (based on screen width)
  static bool get isPhone => ScreenUtil().screenWidth < 600;
}
