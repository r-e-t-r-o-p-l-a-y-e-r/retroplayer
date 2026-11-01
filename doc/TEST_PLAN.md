# Retro Player — test plan

Maps each use case in [REQUIREMENTS.md](REQUIREMENTS.md) to the tests that cover
it and the tests still missing. How to run tests and the general pyramid are in
[AUTOMATED_TESTING.md](AUTOMATED_TESTING.md).

## Conventions

- **Real-shell tests** use `pumpRealApp` (`test/helpers/real_app.dart`): the real
  `AppRouter`, `PlayerDockShell`, `MainShellView` and full provider tree.
- **Back is pressed with `sendSystemBackGesture`** (predictive-back channel,
  the path an Android edge swipe takes). `handlePopRoute` is only for unit
  tests of the guard itself.
- **Android back ownership** is asserted with `recordFrameworkHandlesBack`.
- Prefer `pumpUntil(condition)` over fixed `pumpFrames(count: N)`.

Legend: ✅ covered · ⚠️ partial · ❌ missing (to add).

| UC | Existing tests | Status | Missing / to add |
|----|----------------|--------|------------------|
| UC-01 start / restore | `ui/core/app_session_bootstrap_test`, `ui/core/cold_start_bootstrap_test`, `data/repositories/playback_repository_restore_perf_test`, `integration/persistence_restart_test` (23-track case), `dev/persistence_harness_test`, `ui/features/library/library_view_model_session_test`, `library_album_detail_session_test` | ✅ | Manual ΔT1/ΔT2 on device: [cold-start-baseline.md](cold-start-baseline.md) |
| UC-02 roots | `library_remove_root_test`, `library_add_root_test`, `data/services/library_storage_persistence_test` | ✅ | — |
| UC-03 scan / metadata | `browse_shows_folders_before_scan_test`, `scan_library_progressive_test`, `library_progressive_scan_test`, `data/services/file_scan_service_test`, `metadata_service_test`, `lazy_folder_covers_test`, `library_cover_enrich_test`, `group_tracks_into_albums_test` | ✅ | Placeholders are absorbed into the forming album; a one-file folder stays a placeholder track until tags arrive |
| UC-04 folder browse | `library_browse_widget_test` (app bar stays Library inside a folder), `library_path_summary_test` (current segment stays on screen; earlier segment scrolls in from the left), `library_index_labels_test`, `library_parent_scroll_restore_test`, `browse_library_test`, `library_paths_test`, `library_favorites_test` (swipe right marks a folder; long-press drag reorders the starred links and the order reloads), `folder_favorite_back_gesture_test` (back-edge drag does not favorite) | ✅ | Real-shell characterization: browse three levels and back up (`ui/characterization/shell_flows_test`) |
| UC-07 album detail | `album_player_sheet_test` (app bar reads Album; the album name stays in the body), `library_album_detail_session_test`, `library_jump_to_playing_test` | ✅ | Characterization: open, play track, close (`shell_flows_test`) |
| UC-08 playlists | `playlist_file_test`, `resolve_playlist_paths_test`, `library_repository_playlist_test`, `playlist_playback_test` (app bar reads Playlist and has no play button; the playlist name stays in the body), `playlist_keyboard_test` (read-only badge, long-press reorder, save color, select all / deselect all, German labels), `library_track_picker_test`, `playlist_remote_rejection_test`, `playlist_create_edit_test`, `playback_queue_test` (paths and index survive a new view model; folder playback leaves them; virtual-root save is refused; a library folder writes the `.m3u` and keeps the queue; played tracks stay listed; clear removes every track after confirmation and stops queue playback only), `playback_repository_test` (cold start restores queue playback), `queue_tap_playback_test` (preview play then adopt) | ✅ | — |
| UC-09 play | `application/play_queue_test` (album, folder, playlist, track on in-memory ports), `library_browse_widget_test` | ✅ | — |
| UC-10 transport | `player_progress_test`, `player_touch_gesture_test`, `player_view_model_persistence_test`, `player_view_model_duration_test`, `playback_progress_bar_duration_test`, `player_speed_test`, `player_jump_test` (15 s clamp, side buttons, art double-tap) | ✅ | — |
| UC-11 resume | `play_queue_test` (each album and folder resumes where it was left), `playback_resume_test`, `persistence_resume_test`, `playback_repository_test`, `persistence_restart_test` | ✅ | — |
| UC-12 sheet | `player_dock_shell_test` (predictive-back scrub keeps Now Playing chrome), `album_player_sheet_test`, `player_panel_view_model_test`, `app_back_guard_test`, `system_back_flows_test` | ✅ | — |
| UC-13 locate | `library_jump_to_playing_test`, `player_view_test` | ✅ | — |
| UC-14 back | `back_policy_test`, `app_bar_back_leading_test`, `app_location_test`, `app_back_guard_test`, `system_back_flows_test`, `escape_back_test`, `settings_return_navigation_test`, `android_device_feedback_test` | ✅ | — |
| UC-15 keyboard | `app_shortcuts_test`, `library_keyboard_*`, `settings_keyboard_test`, `playlist_keyboard_test`, `shortcut_labels_test` | ✅ | — |
| UC-16 settings | `equalizer_view_model_test`, `equalizer_filter_builder_test`, `settings_licenses_test`, `settings_l10n_test`, `theme_preference_storage_test`, `locale_preference_storage_test`, `settings_reset_database_test`, `app_database_test` (reset keeps or removes library folders) | ⚠️ | `EqualizerSection` smoke, `ThemeViewModel` / `LocaleViewModel` units, data storage view smoke (`settings_widgets_test`, `preference_view_models_test`) |
| UC-17 background | `retro_audio_handler_test`, `linux_playback_*` | ⚠️ | Handler mirrors play/pause/seek/skip. The media item sends title, artist, and album, with file-name and folder-name fallbacks (`retro_audio_handler_transport_test`, `playback_item_test`) |
| UC-18 privacy | `test/privacy/*` | ✅ | — |

## Performance guards

| Guard | Test |
|-------|------|
| Position ticks rebuild only the progress bar and time labels, not the shell AppBar, library tiles or `PlayerSheetHost` | `ui/performance/position_rebuild_test` |
| Tag reads run off the UI isolate | `library_progressive_scan_test` (fake scanner) |

## Architecture guards

| Guard | Test |
|-------|------|
| `lib/domain` imports no Flutter, `dart:io`, data, ui or application code; `lib/application` reaches data only through `lib/application/ports` | `architecture/layering_test` |
| Back (system, edge swipe, Escape) shares one decision table | `ui/core/navigation/back_policy_test` |
| Player sheet animation is injected (no binding-name check) | `ui/features/player/player_panel_view_model_test` |
