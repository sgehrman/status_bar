import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:status_bar_platform_interface/status_bar_platform_interface.dart';

/// A web implementation of the status_bar plugin.
class status_barPlugin extends status_barPlatform {
  static void registerWith(Registrar? registrar) {
    status_barPlatform.instance = status_barPlugin();
  }

  @override
  Future<String?> get platformVersion async {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }
}
