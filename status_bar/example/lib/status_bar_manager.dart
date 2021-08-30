import 'dart:async';
import 'package:flutter/services.dart';
import 'package:status_bar/status_bar_plugin.dart';

class StatusBarManager {
  StatusBarManager() {
    _setupStatusBar();
  }

  List<StatusMenuItem>? _menuItemCache;
  StatusBarPlugin plugin = StatusBarPlugin();

  void _setupStatusBar() {
    plugin.showStatusBar(<String, dynamic>{
      'iconPath': '/home/steve/Pictures/baby.jpg',
    });

    _setContextMenu();

    // call back for menu items
    plugin.outputCallback = (methodCall) {
      if (methodCall.method == 'status_bar_menu') {
        final int menuItemId = methodCall.arguments;

        _performMenuAction(_menuItems(), menuItemId);
      }
    };
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
          plugin.isShown();
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

  Future<void> _setContextMenu() async {
    try {
      final menus = _menuItems();

      plugin.setStatusBarMenu(menus);
    } on PlatformException catch (e) {
      print('Platform exception setting menu: ${e.message}');
    }
  }
}
