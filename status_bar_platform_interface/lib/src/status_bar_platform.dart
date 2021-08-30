import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'method_channel_status_bar.dart';
import 'status_menu_item.dart';

abstract class StatusBarPlatform extends PlatformInterface {
  StatusBarPlatform() : super(token: _token);

  static final Object _token = Object();
  static StatusBarPlatform _methodChannel = MethodChannelStatusBar();
  static StatusBarPlatform get methodChannel => _methodChannel;

  static set instance(StatusBarPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _methodChannel = instance;
  }

  // abstract interface functions
  set outputCallback(void Function(MethodCall) callback);
  Future<String?> get platformVersion;
  Future<bool> showStatusBar(Map<String, dynamic> info);
  Future<bool> hideStatusBar();
  Future<bool> setStatusBarText(String text);
  Future<bool> setStatusBarIcon(Uint8List iconData);
  Future<bool> isShown();
  Future<bool> setStatusBarMenu(List<StatusMenuItem> menuItems);
}
