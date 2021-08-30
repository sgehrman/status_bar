import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:status_bar/status_bar_plugin.dart';

typedef SystemTrayEventCallback = void Function(String eventName);
const String _kIconPathKey = "iconPath";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<StatusMenuItem>? _menuItemCache;
  StatusBarPlugin plugin = StatusBarPlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    plugin.showStatusBar(<String, dynamic>{
      _kIconPathKey: '/home/steve/Pictures/baby.jpg',
    });

    setContextMenu();

    // call back for menu items
    plugin.outputCallback = (methodCall) {
      if (methodCall.method == 'status_bar_menu') {
        final int menuItemId = methodCall.arguments;

        _performMenuAction(_menuItems(), menuItemId);
      }
    };

    String platformVersion;
    try {
      platformVersion =
          await plugin.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _performMenuAction(List<StatusMenuItem> items, int actionId) {
    for (final item in items) {
      if (item.id == actionId) {
        item.onTap?.call();
      } else {
        if (item.children != null && item.children!.isNotEmpty) {
          _performMenuAction(item.children!, actionId);
        }
      }
    }
  }

  List<StatusMenuItem> _menuItems() {
    if (_menuItemCache != null) {
      return _menuItemCache!;
    }
    int menuItemId = 1;

    _menuItemCache = [
      StatusMenuItem(
        type: StatusMenuItemType.item,
        id: menuItemId++,
        label: 'Show',
        onTap: () {
          // _appWindow.show();
        },
      ),
      StatusMenuItem(
        type: StatusMenuItemType.item,
        id: menuItemId++,
        label: 'Hide',
        onTap: () {
          // _appWindow.hide();
        },
      ),
      StatusMenuItem.separator(),
      StatusMenuItem(
        id: menuItemId++,
        type: StatusMenuItemType.submenu,
        label: "SubMenu",
        children: [
          StatusMenuItem(
            id: menuItemId++,
            type: StatusMenuItemType.item,
            label: 'SubItem1',
            enabled: false,
            onTap: () {
              print("click SubItem1");
            },
          ),
          StatusMenuItem(
            id: menuItemId++,
            type: StatusMenuItemType.item,
            label: 'SubItem2',
            onTap: () {
              print("click SubItem2");
            },
          ),
          StatusMenuItem(
            id: menuItemId++,
            type: StatusMenuItemType.item,
            label: 'SubItem3',
            onTap: () {
              print("click SubItem3");
            },
          ),
        ],
      ),
      StatusMenuItem.separator(),
      StatusMenuItem(
        id: menuItemId++,
        type: StatusMenuItemType.item,
        label: 'Quit',
        onTap: () {
          SystemNavigator.pop();
        },
      ),
    ];

    return _menuItemCache!;
  }

  Future<void> setContextMenu() async {
    try {
      final menus = _menuItems();

      plugin.setStatusBarMenu(menus);
    } on PlatformException catch (e) {
      print('Platform exception setting menu: ${e.message}');
    }
  }

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
