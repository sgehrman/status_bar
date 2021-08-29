//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <status_bar_linux/status_bar_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) status_bar_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "status_barPlugin");
  status_bar_plugin_register_with_registrar(status_bar_linux_registrar);
}
