import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Read the SVG file
  // optional SVG source: assets/images/svg/graduation_cap.svg (not required by this script)

  // Create a 1024x1024 image with the teal background
  final image = img.Image(width: 1024, height: 1024);
  img.fill(image, color: img.ColorRgb8(25, 188, 188));

  // Save the main icon
  File('assets/images/icons/app_icon.png').writeAsBytesSync(img.encodePng(image));

  // Create a transparent image for the foreground
  final foreground = img.Image(width: 1024, height: 1024);
  img.fill(foreground, color: img.ColorRgba8(0, 0, 0, 0));

  // Save the foreground icon
  File('assets/images/icons/app_icon_foreground.png').writeAsBytesSync(img.encodePng(foreground));
}