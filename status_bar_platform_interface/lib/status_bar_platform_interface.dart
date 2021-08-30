library status_bar_platform_interface;

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'src/method_channel_status_bar.dart';

abstract class StatusBarPlatform extends PlatformInterface {
  StatusBarPlatform() : super(token: _token);

  static final Object _token = Object();
  static StatusBarPlatform _methodChannel = MethodChannelStatusBar();
  static StatusBarPlatform get methodChannel => _methodChannel;

  static set instance(StatusBarPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _methodChannel = instance;
  }

  set outputCallback(void Function(MethodCall) callback) {
    throw UnimplementedError('outputCallback has not been implemented.');
  }

  Future<String?> get platformVersion async {
    throw UnimplementedError('platformVersion has not been implemented.');
  }

  Future<bool> showStatusBar(Map<String, dynamic> info) async {
    throw UnimplementedError('showStatusBar has not been implemented.');
  }

  Future<bool> hideStatusBar() async {
    throw UnimplementedError('hideStatusBar has not been implemented.');
  }

  Future<bool> setStatusBarText(String text) async {
    throw UnimplementedError('setStatusBarText has not been implemented.');
  }

  Future<bool> setStatusBarIcon(Uint8List iconData) async {
    throw UnimplementedError('setStatusBarIcon has not been implemented.');
  }

  Future<bool> isShown() async {
    throw UnimplementedError('isShown has not been implemented.');
  }

  Future<bool> setStatusBarMenu(List<Map<String, dynamic>> menuItems) async {
    throw UnimplementedError('setStatusBarMenu has not been implemented.');
  }
}
