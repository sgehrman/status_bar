cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "status_bar_linux")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

find_package(PkgConfig REQUIRED)

# sudo apt-get install libappindicator3-dev
pkg_check_modules (APPINDICATOR REQUIRED IMPORTED_TARGET ayatana-appindicator3-0.1)

add_library(${PLUGIN_NAME} SHARED
  "status_bar_plugin.cc"
  "tray"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::APPINDICATOR)

# List of absolute paths to libraries that should be bundled with the plugin
set(status_bar_bundled_libraries
  ""
  PARENT_SCOPE
)
