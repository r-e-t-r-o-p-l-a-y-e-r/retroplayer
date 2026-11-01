#include "my_application.h"

#include <unistd.h>

#include <flutter_linux/flutter_linux.h>
#include <glib/gstdio.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

static GdkPixbuf* load_embedded_icon(gint size) {
  g_autofree gchar* resource_path =
      g_strdup_printf("/app/retroplayer/icons/app_icon_%d.png", size);
  GError* error = NULL;
  GdkPixbuf* pixbuf = gdk_pixbuf_new_from_resource(resource_path, &error);
  if (pixbuf == NULL) {
    if (error != NULL) {
      g_warning("Retro Player: failed to load embedded icon %s: %s",
                resource_path, error->message);
      g_error_free(error);
    }
    return NULL;
  }
  return pixbuf;
}

static GList* build_embedded_icon_list() {
  const gint sizes[] = {48, 128, 256, 512, 0};
  GList* icons = NULL;
  for (gint i = 0; sizes[i] != 0; i++) {
    GdkPixbuf* pixbuf = load_embedded_icon(sizes[i]);
    if (pixbuf != NULL) {
      icons = g_list_append(icons, pixbuf);
    }
  }
  return icons;
}

static gchar* resolve_icon_path(const gchar* bundle_dir);

static void set_default_embedded_icon() {
  GList* icons = build_embedded_icon_list();
  if (icons != NULL) {
    gtk_window_set_default_icon_list(icons);
    g_list_free_full(icons, g_object_unref);
  }
}

static void set_window_icon(GtkWindow* window, const gchar* bundle_dir) {
  GList* icons = build_embedded_icon_list();
  if (icons != NULL) {
    gtk_window_set_icon_list(window, icons);
    g_list_free_full(icons, g_object_unref);
    return;
  }

  g_autofree gchar* icon_path = resolve_icon_path(bundle_dir);
  if (icon_path == NULL) {
    g_warning("Retro Player: could not locate app icon in bundle");
    return;
  }

  GError* error = NULL;
  GdkPixbuf* pixbuf = gdk_pixbuf_new_from_file(icon_path, &error);
  if (pixbuf == NULL) {
    g_warning("Retro Player: failed to load icon %s: %s", icon_path,
              error != NULL ? error->message : "unknown error");
    if (error != NULL) {
      g_error_free(error);
    }
    return;
  }

  gtk_window_set_icon(window, pixbuf);
  g_object_unref(pixbuf);
}

static void refresh_desktop_database(const gchar* app_dir) {
  g_autofree gchar* command = g_strdup_printf(
      "update-desktop-database %s >/dev/null 2>&1", app_dir);
  g_spawn_command_line_sync(command, NULL, NULL, NULL, NULL);
}

static gchar* resolve_bundle_dir(const gchar* exe_dir) {
  g_autofree gchar* direct_probe = g_build_filename(
      exe_dir, "share", "icons", "hicolor", "256x256", "apps",
      APPLICATION_ID ".png", NULL);
  if (g_file_test(direct_probe, G_FILE_TEST_IS_REGULAR)) {
    return g_strdup(exe_dir);
  }

  const gchar* relative_candidates[] = {"../bundle", "../../bundle", NULL};
  for (gint i = 0; relative_candidates[i] != NULL; i++) {
    g_autofree gchar* candidate =
        g_build_filename(exe_dir, relative_candidates[i], NULL);
    g_autofree gchar* canonical = g_canonicalize_filename(candidate, NULL);
    if (canonical == NULL) {
      continue;
    }

    g_autofree gchar* probe = g_build_filename(
        canonical, "share", "icons", "hicolor", "256x256", "apps",
        APPLICATION_ID ".png", NULL);
    if (g_file_test(probe, G_FILE_TEST_IS_REGULAR)) {
      return g_strdup(canonical);
    }
  }

  return g_strdup(exe_dir);
}

// flutter run executes from intermediates_do_not_run/; icons live in ../bundle/.
// Installs ~/.local/share/applications + hicolor icons so GNOME/KDE Wayland
// can map the running window to Icon=app.retroplayer.
static void ensure_linux_desktop_integration(const gchar* exe_path,
                                             const gchar* bundle_dir) {
  g_autofree gchar* icon_probe = g_build_filename(
      bundle_dir, "share", "icons", "hicolor", "256x256", "apps",
      APPLICATION_ID ".png", NULL);
  if (!g_file_test(icon_probe, G_FILE_TEST_IS_REGULAR)) {
    return;
  }

  g_autofree gchar* app_dir =
      g_build_filename(g_get_user_data_dir(), "applications", NULL);
  g_autofree gchar* icon_root =
      g_build_filename(g_get_user_data_dir(), "icons", "hicolor", NULL);
  g_mkdir_with_parents(app_dir, 0755);
  g_mkdir_with_parents(icon_root, 0755);

  // Never write icon_root/index.theme. A stub theme there shadows the system
  // hicolor theme and can make unrelated desktop/app icons disappear. Also
  // remove a previously installed stub so startup self-heals.
  g_autofree gchar* index_dest =
      g_build_filename(icon_root, "index.theme", NULL);
  g_autofree gchar* cache_dest =
      g_build_filename(icon_root, "icon-theme.cache", NULL);
  g_unlink(index_dest);
  g_unlink(cache_dest);

  const gint sizes[] = {48, 128, 256, 512, 1024, 0};
  for (gint i = 0; sizes[i] != 0; i++) {
    g_autofree gchar* size_dir = g_strdup_printf("%dx%d", sizes[i], sizes[i]);
    g_autofree gchar* src = g_build_filename(
        bundle_dir, "share", "icons", "hicolor", size_dir, "apps",
        APPLICATION_ID ".png", NULL);
    if (!g_file_test(src, G_FILE_TEST_IS_REGULAR)) {
      continue;
    }

    g_autofree gchar* dest_dir =
        g_build_filename(icon_root, size_dir, "apps", NULL);
    g_mkdir_with_parents(dest_dir, 0755);
    g_autofree gchar* dest =
        g_build_filename(dest_dir, APPLICATION_ID ".png", NULL);

    GError* error = NULL;
    GFile* src_file = g_file_new_for_path(src);
    GFile* dest_file = g_file_new_for_path(dest);
    g_file_copy(src_file, dest_file, G_FILE_COPY_OVERWRITE, NULL, NULL, NULL,
                &error);
    if (error != NULL) {
      g_warning("Retro Player: failed to install icon %s: %s", dest,
                error->message);
      g_error_free(error);
    }
    g_object_unref(src_file);
    g_object_unref(dest_file);
  }

  // Do not run gtk-update-icon-cache on the user hicolor root: without a local
  // index.theme, lookups correctly fall through to /usr/share/icons/hicolor.

  g_autofree gchar* desktop_path =
      g_build_filename(app_dir, APPLICATION_ID ".desktop", NULL);

  g_autofree gchar* desktop_contents = g_strdup_printf(
      "[Desktop Entry]\n"
      "Version=1.0\n"
      "Type=Application\n"
      "Name=Retro Player\n"
      "Comment=Local audio player for music and audiobooks\n"
      "Exec=%s\n"
      "Icon=%s\n"
      "Terminal=false\n"
      "Categories=AudioVideo;Audio;Player;\n"
      "StartupNotify=true\n"
      "StartupWMClass=%s\n",
      exe_path, APPLICATION_ID, APPLICATION_ID);

  g_file_set_contents(desktop_path, desktop_contents, -1, NULL);
  refresh_desktop_database(app_dir);
}

static gchar* resolve_icon_path(const gchar* bundle_dir) {
  const gchar* relative_candidates[] = {
      "data/app_icon.png",
      "share/icons/hicolor/256x256/apps/" APPLICATION_ID ".png",
      "share/icons/hicolor/128x128/apps/" APPLICATION_ID ".png",
      "share/icons/hicolor/48x48/apps/" APPLICATION_ID ".png",
      NULL,
  };

  for (gint i = 0; relative_candidates[i] != NULL; i++) {
    g_autofree gchar* candidate =
        g_build_filename(bundle_dir, relative_candidates[i], NULL);
    if (g_file_test(candidate, G_FILE_TEST_IS_REGULAR)) {
      return g_strdup(candidate);
    }
  }

  return NULL;
}

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  gchar* bundle_dir;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void first_frame_cb(MyApplication* self, FlView* view) {
  GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(view));
  gtk_widget_show(toplevel);
  if (GTK_IS_WINDOW(toplevel)) {
    set_window_icon(GTK_WINDOW(toplevel), self->bundle_dir);
  }
}

static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  set_window_icon(window, self->bundle_dir);

  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "Retro Player");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "Retro Player");
  }

  gtk_window_set_default_size(window, 430, 880);
  gtk_window_set_resizable(window, TRUE);
  gtk_widget_set_size_request(GTK_WIDGET(window), 360, 640);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "#000000");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  g_signal_connect_swapped(view, "first-frame", G_CALLBACK(first_frame_cb),
                           self);
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

static void my_application_startup(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  set_default_embedded_icon();

  g_autofree gchar* exe_path = g_file_read_link("/proc/self/exe", NULL);
  if (exe_path != NULL) {
    g_autofree gchar* exe_dir = g_path_get_dirname(exe_path);
    self->bundle_dir = resolve_bundle_dir(exe_dir);
    gdk_set_program_class(APPLICATION_ID);
    ensure_linux_desktop_integration(exe_path, self->bundle_dir);
  }

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

static void my_application_shutdown(GApplication* application) {
  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_pointer(&self->bundle_dir, g_free);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
