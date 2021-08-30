enum MenuItemType {
  item,
  separator,
  submenu,
}

class MenuItem {
  const MenuItem({
    required this.type,
    required this.label,
    this.enabled = true,
    this.onTap,
    this.children,
  });

  factory MenuItem.separator() {
    return MenuItem(type: MenuItemType.separator, label: '');
  }

  final MenuItemType type;
  final String label;
  final bool enabled;
  final List<MenuItem>? children;
  final void Function()? onTap;
}
