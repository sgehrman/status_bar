library status_bar_platform_interface;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/method_channel_status_bar.dart';

export 'src/method_channel_status_bar.dart';

abstract class status_barPlatform extends PlatformInterface {
  status_barPlatform() : super(token: _token);

  static final Object _token = Object();

  static status_barPlatform _instance = MethodChannelstatus_bar();

  static status_barPlatform get instance => _instance;

  static set instance(status_barPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> get platformVersion async {
    throw UnimplementedError('platformVersion has not been implemented.');
  }
}
