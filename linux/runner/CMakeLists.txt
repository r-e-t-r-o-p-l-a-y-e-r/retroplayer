cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX C)

set(GRESOURCE_XML "${CMAKE_CURRENT_SOURCE_DIR}/../resources/retroplayer.gresource.xml")
set(GRESOURCE_C "${CMAKE_CURRENT_BINARY_DIR}/retroplayer_resources.c")

find_program(GLIB_COMPILE_RESOURCES_EXECUTABLE glib-compile-resources REQUIRED)

add_custom_command(
  OUTPUT ${GRESOURCE_C}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../resources"
  COMMAND ${GLIB_COMPILE_RESOURCES_EXECUTABLE}
  ARGS --sourcedir=${CMAKE_CURRENT_SOURCE_DIR}/../resources
        --target=${GRESOURCE_C}
        --generate-source
        ${GRESOURCE_XML}
  DEPENDS
    ${GRESOURCE_XML}
    "${CMAKE_CURRENT_SOURCE_DIR}/../resources/icons/app_icon_48.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/../resources/icons/app_icon_128.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/../resources/icons/app_icon_256.png"
    "${CMAKE_CURRENT_SOURCE_DIR}/../resources/icons/app_icon_512.png"
  VERBATIM
)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  ${GRESOURCE_C}
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/..")
