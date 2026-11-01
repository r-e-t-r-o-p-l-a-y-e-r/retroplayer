# Flutter version pin

Retro Player builds and CI use a **pinned** Flutter stable release, not rolling “latest stable.”

| | |
|---|---|
| **Flutter** | 3.47.8 (stable) |
| **Dart** | 3.13.7 (bundled with the pin) |
| **Android AGP** | 9.1.0 ([`android/settings.gradle.kts`](../android/settings.gradle.kts)) |
| **Android Kotlin** | AGP built-in (embedded **2.2.10** with AGP 9.1; no `kotlin-android` on `:app`) |
| **Gradle wrapper** | 9.3.1 |
| **Built-in Kotlin** | `android.builtInKotlin=true` in [`android/gradle.properties`](../android/gradle.properties) |
| **App compileSdk** | max(Flutter default, **37**) — required by file_picker 13 / permission_handler 13 |
| **Config** | [`.fvm/fvm_config.json`](../.fvm/fvm_config.json) |
| **CI** | [`.github/workflows/test.yml`](../.github/workflows/test.yml) `flutter-version` |

## Local setup (FVM)

1. Install [FVM](https://fvm.app).
2. From the repo root:

```bash
fvm install
fvm use
```

3. Run Flutter/Dart via FVM, e.g. `fvm flutter pub get`, `fvm flutter test`, `fvm dart analyze`.

Without FVM, install Flutter **3.47.8** stable manually and ensure `flutter --version` matches before developing.

## Bumping the pin

1. Branch, e.g. `chore/flutter-x.y.z-deps`.
2. Update `.fvm/fvm_config.json` and CI `flutter-version`.
3. `fvm install` / `flutter pub upgrade` (review `dart pub outdated` majors).
4. Align **`android/`** AGP/Gradle with the [Flutter template defaults](https://github.com/flutter/flutter/tree/master/packages/flutter_tools/lib/src/android/gradle_utils.dart) for that SDK. With **built-in Kotlin**, do not re-add `kotlin-android` on `:app`; confirm `android.builtInKotlin=true`.
5. Regenerate code (`build_runner`, `stamp_build_info`).
6. **`flutter build apk --debug`** — no Flutter “applies the Kotlin Gradle Plugin” warning; no plugin subproject KGP failures. If Flutter’s KGP version checker conflicts with AGP’s embedded Kotlin, see `skipDependencyChecks` in `gradle.properties` (remove when Flutter accounts for built-in Kotlin).
7. Fix Flutter SDK deprecations flagged by `dart analyze` (e.g. `ReorderableListView.onReorderItem`).
8. `dart analyze --fatal-infos`, full `flutter test`, Linux debug build, Android release smoke if needed.
9. Update this table and the README Development section in the same PR.

## Dependency notes (3.47.8 completion)

- **Built-in Kotlin:** `:app` uses AGP embedded Kotlin (`kotlin { compilerOptions }` only). `skipDependencyChecks=true` works around Flutter’s standalone KGP floor (2.2.20) vs AGP 9.1’s embedded 2.2.10 until the Flutter Gradle plugin treats built-in Kotlin separately.
- **Pub majors:** file_picker 13, permission_handler 13, go_router 18; drift 2.35.x; freezed 4.0.3.
- **Deferred:** `sqlite3_flutter_libs` 0.6.0+eol — stay on 0.5.42 until Drift/public-release schema work validates 0.6.
- **Vendored:** `just_audio_media_kit` path override unchanged.
- **Security:** re-check transitives (`archive`, `http`, `sqlite3`, `ffi`) via Dependabot/OSV after lockfile changes.
