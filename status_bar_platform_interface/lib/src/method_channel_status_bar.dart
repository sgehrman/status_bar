import 'dart:io';
import 'package:flutter/services.dart';

import './status_bar_platform.dart';
import 'status_menu_item.dart';

class MethodChannelStatusBar extends StatusBarPlatform {
  MethodChannelStatusBar() {
    _channel.setMethodCallHandler((methodCall) async {
      _callback?.call(methodCall);
    });
  }

  final MethodChannel _channel = const MethodChannel('status_bar');
  void Function(MethodCall)? _callback;

  @override
  set outputCallback(void Function(MethodCall) callback) {
    _callback = callback;
  }

  @override
  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> showStatusBar(Map<String, dynamic> info) async {
    final bool result = await (Platform.isWindows
        ? _channel.invokeMethod('showStatusBar', {'info': info})
        : _channel.invokeMethod('showStatusBar', info));
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
  Future<bool> showWindow() async {
    final bool result = await _channel.invokeMethod('showWindow');
    return result;
  }

  @override
  Future<bool> hideWindow() async {
    final bool result = await _channel.invokeMethod('hideWindow');
    return result;
  }

  @override
  Future<bool> setStatusBarMenu(List<StatusMenuItem> menuItems) async {
    final menuMaps = StatusMenuItem.menuItemsToMaps(menuItems);

    final bool result = await (Platform.isWindows
        ? _channel.invokeMethod('setStatusBarMenu', {'menuItems': menuMaps})
        : _channel.invokeMethod('setStatusBarMenu', menuMaps));
    return result;
  }
}
