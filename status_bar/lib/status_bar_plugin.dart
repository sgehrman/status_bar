import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

// exporting status_menu_item
export 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

class StatusBarPlugin extends StatusBarPlatform {
  set outputCallback(void Function(MethodCall) callback) {
    StatusBarPlatform.methodChannel.outputCallback = callback;
  }

  Future<String?> get platformVersion =>
      StatusBarPlatform.methodChannel.platformVersion;

  Future<bool> showStatusBar(Map<String, dynamic> info) async {
    return StatusBarPlatform.methodChannel.showStatusBar(info);
  }

  Future<bool> hideStatusBar() async {
    return StatusBarPlatform.methodChannel.hideStatusBar();
  }

  Future<bool> setStatusBarText(String text) async {
    return StatusBarPlatform.methodChannel.setStatusBarText(text);
  }

  Future<bool> setStatusBarIcon(Uint8List iconData) async {
    return StatusBarPlatform.methodChannel.setStatusBarIcon(iconData);
  }

  Future<bool> setStatusBarMenu(List<StatusMenuItem> menuItems) async {
    return StatusBarPlatform.methodChannel.setStatusBarMenu(menuItems);
  }

  Future<bool> isShown() async {
    return StatusBarPlatform.methodChannel.isShown();
  }
}
