import 'package:flutter/foundation.dart';

enum StatusMenuItemType {
  item,
  separator,
  submenu,
}

class StatusMenuItem {
  const StatusMenuItem({
    required this.type,
    required this.label,
    required this.id,
    this.enabled = true,
    this.onTap,
    this.children,
    this.key = '',
  });

  factory StatusMenuItem.separator() {
    return StatusMenuItem(
      type: StatusMenuItemType.separator,
      label: '',
      id: 0,
    );
  }

  final StatusMenuItemType type;
  final String label;
  final String key;
  final int id;
  final bool enabled;
  final List<StatusMenuItem>? children;
  final void Function()? onTap;

  // =====================================================
  // static helpers

  static List<Map<String, dynamic>> menuItemsToMaps(List<StatusMenuItem> menu) {
    final List<Map<String, dynamic>> result = [];
    var skipNextDivider = true;

    for (final menuItem in menu) {
      final isDivider = menuItem.type == StatusMenuItemType.separator;

      if (isDivider && skipNextDivider) {
        continue;
      }

      skipNextDivider = isDivider;
      result.add(menuItemToMap(menuItem));
    }

    if (skipNextDivider && result.isNotEmpty) {
      result.removeLast();
    }

    return result;
  }

  static Map<String, dynamic> menuItemToMap(StatusMenuItem item) {
    final result = <String, dynamic>{};

    result['type'] = describeEnum(item.type);

    if (item.type != StatusMenuItemType.separator) {
      result['enabled'] = item.enabled;
      result['label'] = item.label;
      result['id'] = item.id;
      result['key'] = item.key;

      if (item.type == StatusMenuItemType.submenu) {
        result['submenu'] = menuItemsToMaps(item.children!);
      }
    }

    return result;
  }
}
