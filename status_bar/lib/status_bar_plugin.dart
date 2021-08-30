import 'dart:async';
import 'dart:typed_data';

import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

class StatusBarPlugin {
  static Future<String?> get platformVersion =>
      StatusBarPlatform.instance.platformVersion;

  static Future<bool> showStatusBar(Map<String, dynamic> info) async {
    return StatusBarPlatform.instance.showStatusBar(info);
  }

  static Future<bool> hideStatusBar() async {
    return StatusBarPlatform.instance.hideStatusBar();
  }

  static Future<bool> setStatusBarText(String text) async {
    return StatusBarPlatform.instance.setStatusBarText(text);
  }

  static Future<bool> setStatusBarIcon(Uint8List iconData) async {
    return StatusBarPlatform.instance.setStatusBarIcon(iconData);
  }

  static Future<bool> setStatusBarMenu(
      List<Map<String, dynamic>> menuItems) async {
    return StatusBarPlatform.instance.setStatusBarMenu(menuItems);
  }

  static Future<bool> isShown() async {
    return StatusBarPlatform.instance.isShown();
  }
}
