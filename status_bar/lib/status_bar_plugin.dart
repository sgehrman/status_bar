import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

class StatusBarPlugin {
  static set outputCallback(void Function(MethodCall) callback) {
    StatusBarPlatform.methodChannel.outputCallback = callback;
  }

  static Future<String?> get platformVersion =>
      StatusBarPlatform.methodChannel.platformVersion;

  static Future<bool> showStatusBar(Map<String, dynamic> info) async {
    return StatusBarPlatform.methodChannel.showStatusBar(info);
  }

  static Future<bool> hideStatusBar() async {
    return StatusBarPlatform.methodChannel.hideStatusBar();
  }

  static Future<bool> setStatusBarText(String text) async {
    return StatusBarPlatform.methodChannel.setStatusBarText(text);
  }

  static Future<bool> setStatusBarIcon(Uint8List iconData) async {
    return StatusBarPlatform.methodChannel.setStatusBarIcon(iconData);
  }

  static Future<bool> setStatusBarMenu(
      List<Map<String, dynamic>> menuItems) async {
    return StatusBarPlatform.methodChannel.setStatusBarMenu(menuItems);
  }

  static Future<bool> isShown() async {
    return StatusBarPlatform.methodChannel.isShown();
  }
}
