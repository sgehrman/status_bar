import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:status_bar/status_bar_plugin.dart';
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
  final Map<int, void Function()> _selectionCallbacks = {};
  // SystemTrayEventCallback? _systemTrayEventCallback;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    StatusBarPlugin.showStatusBar();

    setContextMenu();

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await StatusBarPlugin.platformVersion ?? 'Unknown platform version';
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

  Future<void> setContextMenu() async {
    try {
      // _updateInProgress = true;

      final menus = [
        MenuItem(
          type: MenuItemType.item,
          label: 'Show',
          onTap: () {
            // _appWindow.show();
          },
        ),
        MenuItem(
          type: MenuItemType.item,
          label: 'Hide',
          onTap: () {
            // _appWindow.hide();
          },
        ),
        MenuItem.separator(),
        MenuItem(
          type: MenuItemType.submenu,
          label: "SubMenu",
          children: [
            MenuItem(
              type: MenuItemType.item,
              label: 'SubItem1',
              enabled: false,
              onTap: () {
                print("click SubItem1");
              },
            ),
            MenuItem(
              type: MenuItemType.item,
              label: 'SubItem2',
              onTap: () {
                print("click SubItem2");
              },
            ),
            MenuItem(
              type: MenuItemType.item,
              label: 'SubItem3',
              onTap: () {
                print("click SubItem3");
              },
            ),
          ],
        ),
      ];

      final c = _channelRepresentationForMenus(menus);

      StatusBarPlugin.setStatusBarMenu(c);

      // _updateInProgress = false;
    } on PlatformException catch (e) {
      print('Platform exception setting menu: ${e.message}');
    }
  }

  List<Map<String, dynamic>> _channelRepresentationForMenus(
      List<MenuItem> menus) {
    _selectionCallbacks.clear();
    _nextMenuItemId = 1;

    return menus.map(_channelRepresentationForMenuItem).toList();
  }

  Map<String, dynamic> _channelRepresentationForMenuItem(MenuItem item) {
    final result = <String, dynamic>{};

    result[_kTypeKey] = describeEnum(item.type);

    if (item.type != MenuItemType.separator) {
      result[_kEnabledKey] = item.enabled;
      result[_kLabelKey] = item.label;

      if (item.type == MenuItemType.submenu) {
        result[_kSubMenuKey] = _channelRepresentationForMenu(item.children!);
      } else {
        if (item.onTap != null) {
          result[_kIdKey] = _storeMenuCallback(item.onTap!);
        }
      }
    }

    return result;
  }

  /// Returns the representation of [menu] suitable for passing over the
  /// platform channel to the native plugin.
  List<dynamic> _channelRepresentationForMenu(List<MenuItem> menu) {
    final menuItemRepresentations = [];
    // Dividers are only allowed after non-divider items (see ApplicationMenu).
    var skipNextDivider = true;
    for (final menuItem in menu) {
      final isDivider = menuItem.type == MenuItemType.separator;
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

  int _storeMenuCallback(void Function() callback) {
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
