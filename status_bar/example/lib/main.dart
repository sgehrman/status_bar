import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:status_bar/status_bar.dart';
import 'package:status_bar_example/menu_item.dart';

typedef SystemTrayEventCallback = void Function(String eventName);
// const String _kTitleKey = "title";
// const String _kIconPathKey = "iconpath";
// const String _kToolTipKey = "tooltip";
const String _kIdKey = 'id';
const String _kTypeKey = 'type';
const String _kLabelKey = 'label';
const String _kSubMenuKey = 'submenu';
const String _kEnabledKey = 'enabled';
// const String _kMenuItemSelectedCallbackMethod = 'MenuItemSelectedCallback';
// const String _kSystemTrayEventCallbackMethod = 'SystemTrayEventCallback';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  // bool _updateInProgress = false;
  int _nextMenuItemId = 1;
  final Map<int, MenuItemSelectedCallback> _selectionCallbacks = {};
  // SystemTrayEventCallback? _systemTrayEventCallback;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    StatusBar.showStatusBar();

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await StatusBar.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> setContextMenu(List<MenuItemBase> menus) async {
    try {
      // _updateInProgress = true;

      StatusBar.setStatusBarText('sdfsdf');

      final c = _channelRepresentationForMenus(menus);

      print(c);

      // _updateInProgress = false;
    } on PlatformException catch (e) {
      print('Platform exception setting menu: ${e.message}');
    }
  }

  List<dynamic> _channelRepresentationForMenus(List<MenuItemBase> menus) {
    _selectionCallbacks.clear();
    _nextMenuItemId = 1;

    return menus.map(_channelRepresentationForMenuItem).toList();
  }

  /// Returns a representation of [item] suitable for passing over the
  /// platform channel to the native plugin.
  Map<String, dynamic> _channelRepresentationForMenuItem(MenuItemBase item) {
    final representation = <String, dynamic>{};
    if (item is MenuSeparator) {
      representation[_kTypeKey] = item.type;
    } else {
      representation[_kLabelKey] = item.label;
      if (item is SubMenu) {
        representation[_kTypeKey] = item.type;
        representation[_kSubMenuKey] =
            _channelRepresentationForMenu(item.children);
      } else if (item is MenuItem) {
        representation[_kTypeKey] = item.type;
        final handler = item.onClicked;
        if (handler != null) {
          representation[_kIdKey] = _storeMenuCallback(handler);
        }
        representation[_kEnabledKey] = item.enabled;
      } else {
        throw ArgumentError(
            'Unknown MenuItemBase type: $item (${item.runtimeType})');
      }
    }
    return representation;
  }

  /// Returns the representation of [menu] suitable for passing over the
  /// platform channel to the native plugin.
  List<dynamic> _channelRepresentationForMenu(List<MenuItemBase> menu) {
    final menuItemRepresentations = [];
    // Dividers are only allowed after non-divider items (see ApplicationMenu).
    var skipNextDivider = true;
    for (final menuItem in menu) {
      final isDivider = menuItem is MenuSeparator;
      if (isDivider && skipNextDivider) {
        continue;
      }
      skipNextDivider = isDivider;
      menuItemRepresentations.add(_channelRepresentationForMenuItem(menuItem));
    }
    // If the last item is a divider, remove it (see ApplicationMenu).
    if (skipNextDivider && menuItemRepresentations.isNotEmpty) {
      menuItemRepresentations.removeLast();
    }
    return menuItemRepresentations;
  }

  /// Stores [callback] for use plugin callback handling, returning the ID
  /// under which it was stored.
  ///
  /// The returned ID should be attached to the menu so that the native plugin
  /// can identify the menu item selected in the callback.
  int _storeMenuCallback(MenuItemSelectedCallback callback) {
    final id = _nextMenuItemId++;
    _selectionCallbacks[id] = callback;
    return id;
  }

  // Future<void> _callbackHandler(MethodCall methodCall) async {
  //   if (methodCall.method == _kMenuItemSelectedCallbackMethod) {
  //     if (_updateInProgress) {
  //       // Drop stale callbacks.
  //       // Evaluate whether this works in practice, or if races are
  //       // regular occurences that clients will need to be prepared to
  //       // handle (in which case a more complex ID system will be needed).
  //       print('Warning: Menu selection callback received during menu update.');
  //       return;
  //     }
  //     final int menuItemId = methodCall.arguments;
  //     final callback = _selectionCallbacks[menuItemId];
  //     if (callback == null) {
  //       throw Exception('Unknown menu item ID $menuItemId');
  //     }
  //     callback();
  //   } else if (methodCall.method == _kSystemTrayEventCallbackMethod) {
  //     if (_systemTrayEventCallback != null) {
  //       final String eventName = methodCall.arguments;
  //       _systemTrayEventCallback!(eventName);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
