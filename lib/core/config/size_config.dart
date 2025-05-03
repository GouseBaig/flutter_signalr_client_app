import 'package:flutter/cupertino.dart';
import 'package:flutter_signalr_client_app/core/config/config.dart';

class SizeConfig {
  static double _blockWidth = 0;
  static double _blockHeight = 0;

  static late double realScreenWidth;
  static late double realScreenHeight;
  static late double screenWidth;
  static late double screenHeight;
  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;

  static bool isPortrait = true;
  static bool isMobilePortrait = false;
  static bool isMobile = false;
  static bool isHeightShort = false;
  static bool isHeightVeryShort = false;
  static bool isHeightMiddle = false;
  static bool isHeightLarge = false;
  static bool isWidthLarge = false;

  void init(BoxConstraints constraints, Orientation orientation) {
    realScreenHeight = constraints.maxHeight;
    realScreenWidth = constraints.maxWidth;
    if (constraints.maxWidth <= MAX_SMALL_SCREEN) {
      isMobile = true;
    }
    if (constraints.maxHeight < 600) {
      isHeightVeryShort = true;
    } else if (constraints.maxHeight < 800) {
      isHeightShort = true;
    } else if (constraints.maxHeight < 1000) {
      isHeightMiddle = true;
    } else {
      isHeightLarge = true;
    }

    if (constraints.maxWidth > 600) {
      isWidthLarge = true;
    }

    if (orientation == Orientation.portrait) {
      isPortrait = true;
      if (realScreenWidth < 450) {
        isMobilePortrait = true;
      }

      screenHeight = realScreenHeight;
      screenWidth = realScreenWidth;
    } else {
      isPortrait = false;
      isMobilePortrait = false;

      screenHeight = realScreenWidth;
      screenWidth = realScreenHeight;
    }
    _blockWidth = screenWidth / 100;
    _blockHeight = screenHeight / 100;

    textMultiplier = _blockHeight;
    imageSizeMultiplier = _blockWidth;
    heightMultiplier = _blockHeight;
    widthMultiplier = _blockWidth;
  }

  static getTextMultiplierBasedOnWidth({double? width}) {
    // TODO handel LandScape case
    if (width != null) {
      return width / 100;
    }
    return widthMultiplier;
  }

  static getWidthMultiplier({double? width}) {
    // TODO handel LandScape case
    if (width != null) {
      return width / 100;
    }
    return widthMultiplier;
  }

  static getHeightMultiplier({double? height}) {
    // TODO handel LandScape case
    if (height != null) {
      return height / 100;
    }
    return heightMultiplier;
  }
}
