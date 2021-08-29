
import 'dart:async';

import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

class status_bar {
  static Future<String?> get platformVersion => status_barPlatform.instance.platformVersion;
}
