#include "include/status_bar_linux/status_bar_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <cstring>

#include "tray.h"

#define status_bar_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), status_bar_plugin_get_type(), \
                              status_barPlugin))

struct _status_barPlugin
{
  GObject parent_instance;
  FlPluginRegistrar *registrar;
  FlMethodChannel *channel;
  SystemTray *system_tray;
};

G_DEFINE_TYPE(status_barPlugin, status_bar_plugin, g_object_get_type())

// ==============================================================
// ==============================================================

// const static char kTitleKey[] = "title";
const static char kIconPathKey[] = "iconPath";
// const static char kToolTipKey[] = "tooltip";

const static char kIdKey[] = "id";
const static char kTypeKey[] = "type";
const static char kLabelKey[] = "label";
const static char kSeparatorKey[] = "separator";
const static char kSubMenuKey[] = "submenu";
const static char kEnabledKey[] = "enabled";

// ==============================================================
// ==============================================================

status_barPlugin *g_plugin = nullptr;

static void tray_callback(GtkMenuItem *item, gpointer user_data)
{
  int64_t id = GPOINTER_TO_INT(user_data);

  g_autoptr(FlValue) result = fl_value_new_int(id);
  fl_method_channel_invoke_method(g_plugin->channel,
                                  "status_bar_callback", result,
                                  nullptr, nullptr, nullptr);
}

static GtkWidget *value_to_menu(status_barPlugin *self, FlValue *value);

static GtkWidget *value_to_menu_item(status_barPlugin *self, FlValue *value)
{
  if (fl_value_get_type(value) != FL_VALUE_TYPE_MAP)
  {
    return nullptr;
  }

  FlValue *type_value = fl_value_lookup_string(value, kTypeKey);
  if (type_value == nullptr ||
      fl_value_get_type(type_value) != FL_VALUE_TYPE_STRING)
  {
    return nullptr;
  }

  GtkWidget *menuItem = nullptr;

  const gchar *type = fl_value_get_string(type_value);

  if (strcmp(type, kSeparatorKey) == 0)
  {
    menuItem = gtk_separator_menu_item_new();
  }
  else
  {
    FlValue *label_value = fl_value_lookup_string(value, kLabelKey);

    if (label_value != nullptr &&
        fl_value_get_type(label_value) == FL_VALUE_TYPE_STRING)
    {
      if (strcmp(type, kSubMenuKey) == 0)
      {
        menuItem = gtk_menu_item_new_with_label(fl_value_get_string(label_value));
        GtkWidget *subMenu =
            value_to_menu(self, fl_value_lookup_string(value, kSubMenuKey));
        if (subMenu == nullptr)
        {
          return nullptr;
        }
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(menuItem), subMenu);
      }
      else
      {
        menuItem = gtk_menu_item_new_with_label(fl_value_get_string(label_value));

        FlValue *enabled_value = fl_value_lookup_string(value, kEnabledKey);
        if (enabled_value != nullptr &&
            fl_value_get_type(enabled_value) == FL_VALUE_TYPE_BOOL)
        {
          gtk_widget_set_sensitive(
              menuItem, fl_value_get_bool(enabled_value) ? TRUE : FALSE);
        }

        FlValue *id_value = fl_value_lookup_string(value, kIdKey);
        if (id_value != nullptr &&
            fl_value_get_type(id_value) == FL_VALUE_TYPE_INT)
        {
          g_signal_connect(G_OBJECT(menuItem), "activate",
                           G_CALLBACK(tray_callback),
                           GINT_TO_POINTER(fl_value_get_int(id_value)));
        }
      }
    }
  }

  return menuItem;
}

static GtkWidget *value_to_menu(status_barPlugin *self, FlValue *value)
{
  if (fl_value_get_type(value) != FL_VALUE_TYPE_LIST)
  {
    return nullptr;
  }

  GtkWidget *menu = gtk_menu_new();

  for (size_t i = 0; i < fl_value_get_length(value); ++i)
  {
    GtkWidget *menuItem =
        value_to_menu_item(self, fl_value_get_list_value(value, i));
    if (menuItem == nullptr)
    {
      return nullptr;
    }

    gtk_menu_shell_append(GTK_MENU_SHELL(menu), GTK_WIDGET(menuItem));
  }
  return GTK_WIDGET(menu);
}

static FlMethodResponse *set_context_menu(status_barPlugin *self,
                                          FlValue *args)
{
  g_autoptr(FlValue) result = fl_value_new_bool(FALSE);
  FlMethodResponse *response = nullptr;

  do
  {
    GtkWidget *menu = value_to_menu(self, args);
    if (menu == nullptr)
    {
      response = FL_METHOD_RESPONSE(fl_method_error_response_new(
          "kBadArgumentsError", "Menu list missing or malformed", nullptr));
      break;
    }

    self->system_tray->set_context_menu(GTK_WIDGET(menu));

    result = fl_value_new_bool(TRUE);

  } while (false);

  if (nullptr == response)
  {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  return response;
}

static FlMethodResponse *init_system_tray(status_barPlugin *self,
                                          FlValue *args)
{
  g_autoptr(FlValue) result = fl_value_new_bool(FALSE);
  FlMethodResponse *response = nullptr;

  const gchar *icon_path = "";
  const gchar *title = "---"; // crashes if blank ""
  const gchar *tool_tip = "";

  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP)
  {
    return FL_METHOD_RESPONSE(
        fl_method_error_response_new("Bad Arguments Error", "no map", nullptr));
  }

  FlValue *icon_path_value = fl_value_lookup_string(args, kIconPathKey);
  if (icon_path_value &&
      fl_value_get_type(icon_path_value) == FL_VALUE_TYPE_STRING)
  {
    icon_path = fl_value_get_string(icon_path_value);
  }

  result = fl_value_new_bool(
      self->system_tray->init_system_tray(title, icon_path, tool_tip));

  response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));

  return response;
}

// Called when a method call is received from Flutter.
static void status_bar_plugin_handle_method_call(
    status_barPlugin *self,
    FlMethodCall *method_call)
{
  g_autoptr(FlMethodResponse) response = nullptr;
  FlValue *args = fl_method_call_get_args(method_call);

  const gchar *method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0)
  {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "showStatusBar") == 0)
  {

    response = init_system_tray(self, args);
  }
  else if (strcmp(method, "hideStatusBar") == 0)
  {
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "setStatusBarText") == 0)
  {
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "setStatusBarIcon") == 0)
  {
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "setStatusBarMenu") == 0)
  {
    response = set_context_menu(self, args);
  }
  else if (strcmp(method, "isShown") == 0)
  {
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void status_bar_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(status_bar_plugin_parent_class)->dispose(object);
}

static void status_bar_plugin_class_init(status_barPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = status_bar_plugin_dispose;
}

static void status_bar_plugin_init(status_barPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  status_barPlugin *plugin = status_bar_PLUGIN(user_data);
  status_bar_plugin_handle_method_call(plugin, method_call);

  g_plugin = plugin;
}

void status_bar_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  status_barPlugin *plugin = status_bar_PLUGIN(
      g_object_new(status_bar_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "status_bar",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  plugin->system_tray = new SystemTray();

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));
  plugin->channel = channel;

  g_object_unref(plugin);
}
