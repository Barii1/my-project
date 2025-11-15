import 'package:flutter/material.dart';

class DeviceFrames {
  // iPhone 14 Pro dimensions
  static const iphone14Pro = Size(393, 852);
  
  // Pixel 5 dimensions
  static const pixel5 = Size(393, 851);
  
  // Safe padding values
  static const safePaddingTop = 47.0;
  static const safePaddingBottom = 34.0;
  
  // Content area dimensions
  static const maxContentWidth = 370.0;
  
  // Card margins
  static const horizontalMargin = 16.0;
  static const verticalMargin = 16.0;
  
  // Returns the available content height after accounting for safe areas and nav bar
  static double getContentHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom - 
           kBottomNavigationBarHeight;
  }
  
  // Returns appropriate padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: horizontalMargin,
      vertical: verticalMargin
    );
  }
}