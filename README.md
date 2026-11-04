# Retro Player for Android (native)

A native Kotlin and Jetpack Compose version of Retro Player for Android only.
It has the same app id (`app.retroplayer`), look and behaviour as the Flutter
app in the repository root, which stays the reference
([doc/REQUIREMENTS.md](../doc/REQUIREMENTS.md), use cases UC-01 to UC-18).
Where the native app behaves differently, the requirements say so in
"Android native" notes.

On top of the Flutter features it has Android Auto browsing, a home-screen
widget, M4B chapters (player, seek bar, notification), headphone options and
a sort order per album.

Working on this code with an agent? Read [AGENTS.md](AGENTS.md) first;
[PLAN.md](PLAN.md) has the task history.

## Privacy and storage

- No network: the release manifest has no `INTERNET` or
  `ACCESS_NETWORK_STATE`; `./gradlew check` fails if one comes back
  (`verifyReleasePrivacy`). No Google Play services, Firebase or analytics.
- Folders are opened only through the system folder picker (Storage Access
  Framework); the app asks for no storage or media permission.
- Your folders and files are read-only. The only files the app writes are
  M3U playlists it created itself; for those it asks once for write access
  to the library folder. `DiskWriteGuardTest` fails the build if any other
  code can write documents.
- Permissions in the release build: foreground media playback service, wake
  lock, notifications, and `RECEIVE_BOOT_COMPLETED`. The last one comes from
  WorkManager, which the Glance widget library uses for widget updates;
  WorkManager reschedules pending work after a reboot. The app does no work of
  its own at boot.

## Build and run

Requirements: JDK 17 and the Android SDK (`ANDROID_HOME`). No Android Studio
needed; everything runs through Gradle from this folder.

```bash
cd android-native
./gradlew :app:assembleDebug          # app/build/outputs/apk/debug/app-debug.apk
scripts/install-test-build.sh         # build and install on a device (-d SERIAL)
./gradlew assembleRelease             # release APK
```

Debug builds use the app id `app.retroplayer.debug` and the name "Retro Player
test", so they install next to the Flutter app or a release build, with their
own data.

Translated strings come from the Flutter ARB files
(`lib/l10n/app_*.arb`). After changing them, regenerate the Android resources:

```bash
python3 ../scripts/arb_to_android.py           # --check in CI
```

## Tests

| What | Command |
| --- | --- |
| everything: unit, Robolectric, lint, privacy | `./gradlew check` |
| one module | `./gradlew :domain:test`, `./gradlew :app:testDebugUnitTest` (same for `:data`, `:playback`) |
| one test class | `./gradlew :app:testDebugUnitTest --tests '*AlbumViewModelTest*'` |
| screenshots: check | `./gradlew verifyRoborazziDebug` |
| screenshots: record after a UI change | `./gradlew recordRoborazziDebug` |
| device tests on a running emulator | `scripts/device-smoke.sh` |
| device tests on managed emulators | `./gradlew :app:phonesGroupDebugAndroidTest` |

### Screenshot tests

`ScreenshotTest` renders every screen with Robolectric and
[Roborazzi](https://github.com/takahirom/roborazzi): light and dark on a phone,
and the main screens also on a tablet, in German, in the right-to-left
pseudo-locale and at font scale 2. The recorded images live in
`app/src/test/screenshots/`. When a UI change is intended, record again and
commit the new images with the change. Robolectric draws all font weights the
same and leaves out some outlines, so compare layout and colours, not text
weight, with the user guide images in
[doc/images/tutorial/](../doc/images/tutorial/).

### Device tests

`app/src/androidTest/.../smoke/DeviceSmokeTest.kt` drives the real app: add a
folder through the system picker, play, queue, save and delete a playlist, the
A–Z bar, rotation, settings and language. The tests create their sample folder
(`/sdcard/Music/RetroPlayerSamples`) on the device when it is missing.

On an emulator you started yourself:

```bash
$ANDROID_HOME/emulator/emulator -avd <avd> -no-window -no-audio -no-boot-anim -gpu host &
scripts/device-smoke.sh                # all tests
scripts/device-smoke.sh <testMethod>   # one test
```

`device-smoke.sh` uses the emulator, never an attached phone, because the test
runner clears the app's data.

### Managed devices

Gradle can create and start the emulators itself (`testOptions.managedDevices`
in `app/build.gradle.kts`):

| Group | Devices |
| --- | --- |
| `phones` | Pixel 2 (API 27), Pixel 7 (API 33), Pixel 9 (API 35) |
| `fullMatrix` | the phones plus Pixel 4 (API 30), Pixel Tablet (API 35), Pixel Fold (API 35) |

```bash
./gradlew :app:phonesGroupDebugAndroidTest
./gradlew :app:fullMatrixGroupDebugAndroidTest
```

They use full AOSP images because the smaller ATD images have no system folder
picker. The emulator needs KVM. Locally the GPU mode is `host`; on machines
without a GPU (CI) pass
`-Pandroid.testoptions.manageddevices.emulator.gpu=swiftshader_indirect`.
The first run downloads the system images.

## CI

`.github/workflows/android-native.yml` runs `check assembleRelease`, the ARB
sync check and `verifyRoborazziDebug`, then the `phones` group on a runner with
KVM enabled.

## Modules

| Module | Kind | Contents |
| --- | --- | --- |
| `:domain` | Kotlin/JVM | models, sorting, album grouping, M3U, chapters, resume and transport rules, settings model |
| `:data` | Android library | folder scanner (SAF), tag reader, Room database, DataStore settings, library repository, playlist files |
| `:playback` | Android library | `PlaybackService` (Media3 `MediaLibraryService`, Android Auto tree), queue building, progress saving |
| `:app` | application | Compose UI, view models, Hilt modules, widget, media controller connection |

Details, conventions and pitfalls: [AGENTS.md](AGENTS.md).
