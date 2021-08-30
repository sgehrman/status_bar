import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../status_bar_platform_interface.dart';

class MethodChannelStatusBar extends statusBarPlatform {
  static const MethodChannel _channel = const MethodChannel('status_bar');

  @override
  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> showStatusBar() async {
    final bool result = await (Platform.isWindows
        ? _channel.invokeMethod('showStatusBar')
        : _channel.invokeMethod('showStatusBar'));
    return result;
  }

  @override
  Future<bool> hideStatusBar() async {
    final bool result = await _channel.invokeMethod('hideStatusBar');
    return result;
  }

  @override
  Future<bool> setStatusBarText(String text) async {
    final bool result = await (Platform.isWindows
        ? _channel.invokeMethod('setStatusBarText', {'text': text})
        : _channel.invokeMethod('setStatusBarText', text));
    return result;
  }

  @override
  Future<bool> setStatusBarIcon(Uint8List iconData) async {
    final bool result = await (Platform.isWindows
        ? _channel.invokeMethod('setStatusBarIcon', {'icon': iconData})
        : _channel.invokeMethod('setStatusBarIcon', iconData));
    return result;
  }

  @override
  Future<bool> isShown() async {
    final bool result = await _channel.invokeMethod('isShown');
    return result;
  }

  @override
  Future<bool> setStatusBarMenu(List<Map<String, dynamic>> menuItems) async {
    final bool result = await (Platform.isWindows
        ? _channel.invokeMethod('setStatusBarMenu', {'menuItems': menuItems})
        : _channel.invokeMethod('setStatusBarMenu', menuItems));
    return result;
  }
}
