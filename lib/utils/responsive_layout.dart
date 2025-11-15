import 'package:flutter/material.dart';

class ResponsiveLayout {
  // Pixel 5 dimensions
  static const Size pixel5 = Size(393, 851);
  
  // iPhone 14 Pro dimensions
  static const Size iphone14Pro = Size(393, 852);
  
  // Target design dimensions (we'll use Pixel 5 as our base)
  static const Size designSize = pixel5;
  
  static double scaleWidth(BuildContext context) {
    return MediaQuery.of(context).size.width / designSize.width;
  }
  
  static double scaleHeight(BuildContext context) {
    return MediaQuery.of(context).size.height / designSize.height;
  }
  
  static double scale(BuildContext context) {
    return (scaleWidth(context) + scaleHeight(context)) / 2;
  }
  
  static double responsiveWidth(BuildContext context, double width) {
    return width * scaleWidth(context);
  }
  
  static double responsiveHeight(BuildContext context, double height) {
    return height * scaleHeight(context);
  }
  
  static EdgeInsets responsivePadding(BuildContext context, EdgeInsets padding) {
    return EdgeInsets.only(
      left: padding.left * scaleWidth(context),
      top: padding.top * scaleHeight(context),
      right: padding.right * scaleWidth(context),
      bottom: padding.bottom * scaleHeight(context),
    );
  }
  
  static double responsiveFontSize(BuildContext context, double fontSize) {
    return fontSize * scale(context);
  }
  
  static BorderRadius responsiveBorderRadius(BuildContext context, BorderRadius borderRadius) {
    return BorderRadius.only(
      topLeft: Radius.circular(borderRadius.topLeft.x * scale(context)),
      topRight: Radius.circular(borderRadius.topRight.x * scale(context)),
      bottomLeft: Radius.circular(borderRadius.bottomLeft.x * scale(context)),
      bottomRight: Radius.circular(borderRadius.bottomRight.x * scale(context)),
    );
  }
}