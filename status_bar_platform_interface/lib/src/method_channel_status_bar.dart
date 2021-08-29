import 'package:flutter/services.dart';

import '../status_bar_platform_interface.dart';

class MethodChannelstatus_bar extends status_barPlatform {
  static const MethodChannel _channel =
      const MethodChannel('status_bar');

  @override
  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}