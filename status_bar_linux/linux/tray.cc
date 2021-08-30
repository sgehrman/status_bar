#ifndef NATIVE_C
#define NATIVE_C

#include "tray.h"

#include <assert.h>
#include <dlfcn.h>
#include <gdk-pixbuf/gdk-pixbuf.h>
#include <gio/gio.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <string>

bool SystemTray::init_system_tray(const char *title,
                                  const char *iconPath,
                                  const char *toolTip)
{
  printf("SystemTray::init_system_tray\n");

  if (!init_indicator_api())
  {
    printf("init_indicator_api failed.\n");

    return false;
  }

  if (!create_indicator(title, iconPath, toolTip))
  {
    printf("create_indicator failed.\n");

    return false;
  }

  return true;
}

bool SystemTray::set_system_tray_info(const char *title,
                                      const char *iconPath,
                                      const char *toolTip)
{
  printf("SystemTray::set_system_tray_info title: %s, iconPath: %s, toolTip: %s\n", title, iconPath, toolTip);

  bool ret = false;

  do
  {
    if (!_app_indicator)
    {
      break;
    }

    if (iconPath)
    {
      std::string path = iconPath;
      if (!path.empty())
      {
        printf("HAS icon for sytem tray\n");

        _app_indicator_set_status(_app_indicator, APP_INDICATOR_STATUS_ACTIVE);
        _app_indicator_set_icon_full(_app_indicator, iconPath, "icon");
      }
      else
      {
        printf("No icon for sytem tray\n");

        _app_indicator_set_status(_app_indicator, APP_INDICATOR_STATUS_ACTIVE);
      }
    }

    // app_indicator_set_title(_app_indicator, "title");
    // app_indicator_set_label(_app_indicator, "label", "guide");
    ret = true;
  } while (false);

  return ret;
}

bool SystemTray::init_indicator_api()
{

  void *handle = dlopen("libappindicator3.so.1", RTLD_LAZY);
  if (!handle)
  {
    return false;
  }

  _app_indicator_new = reinterpret_cast<app_indicator_new_fun>(
      dlsym(handle, "app_indicator_new"));

  _app_indicator_set_status = reinterpret_cast<app_indicator_set_status_fun>(
      dlsym(handle, "app_indicator_set_status"));

  _app_indicator_set_icon_full =
      reinterpret_cast<app_indicator_set_icon_full_func>(
          dlsym(handle, "app_indicator_set_icon_full"));

  _app_indicator_set_attention_icon_full =
      reinterpret_cast<app_indicator_set_attention_icon_full_fun>(
          dlsym(handle, "app_indicator_set_attention_icon_full"));

  _app_indicator_set_menu = reinterpret_cast<app_indicator_set_menu_fun>(
      dlsym(handle, "app_indicator_set_menu"));

  if (!_app_indicator_new || !_app_indicator_set_status ||
      !_app_indicator_set_icon_full ||
      !_app_indicator_set_attention_icon_full || !_app_indicator_set_menu)
  {
    return false;
  }

  return true;
}

bool SystemTray::create_indicator(const char *title,
                                  const char *iconPath,
                                  const char *toolTip)
{
  printf("SystemTray::create_indicator title: %s, iconPath: %s, toolTip: %s\n",
         title, iconPath, toolTip);

  _app_indicator = _app_indicator_new(
      title, iconPath, APP_INDICATOR_CATEGORY_APPLICATION_STATUS);

  if (_app_indicator)
  {
    g_print("_app_indicator alloecked\n");
  }
  else
  {
    g_print("_app_indicator falied alloc\n");
  }

  _app_indicator_set_status(_app_indicator, APP_INDICATOR_STATUS_ACTIVE);

  g_print("_app_indicator set status\n");

  return true;
}

bool SystemTray::set_context_menu(GtkWidget *system_menu)
{
  printf("SystemTray::set_context_menu system_menu:%p\n", system_menu);

  if (!_app_indicator)
  {
    printf("_app_indicator null?\n");

    return false;
  }

  gtk_widget_show_all(system_menu);

  _app_indicator_set_menu(_app_indicator, GTK_MENU(system_menu));

  return true;
}

#endif // NATIVE_C