import 'dart:async';
import 'dart:typed_data';

import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

class StatusBar {
  static Future<String?> get platformVersion =>
      statusBarPlatform.instance.platformVersion;

  static Future<bool> showStatusBar() async {
    return statusBarPlatform.instance.showStatusBar();
  }

  static Future<bool> hideStatusBar() async {
    return statusBarPlatform.instance.hideStatusBar();
  }

  static Future<bool> setStatusBarText(String text) async {
    return statusBarPlatform.instance.setStatusBarText(text);
  }

  static Future<bool> setStatusBarIcon(Uint8List iconData) async {
    return statusBarPlatform.instance.setStatusBarIcon(iconData);
  }

  static Future<bool> isShown() async {
    return statusBarPlatform.instance.isShown();
  }
}
