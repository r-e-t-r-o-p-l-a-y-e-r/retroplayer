# Releasing Retro Player

One git tag produces every store build. All builds are signed with the same
developer key, so users can switch between Google Play, F-Droid, Accrescent and
GitHub releases without uninstalling.

## Versions

- `versionCode` and `versionName` live in `app/build.gradle.kts`. The first
  store version is `0.9.0` (versionCode 1).
- Every release raises `versionCode` by one and gets the tag `vX.Y.Z` matching
  `versionName`. Before 1.0, minor versions (0.10.0, 0.11.0, ...) mark store
  releases.
- Release notes: `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt`
  (500 characters at most; Play shows them as "What's new").

## Build variants

| Flavor | Goes to | Donation row in About |
| --- | --- | --- |
| `foss` | F-Droid, Accrescent, GitHub Releases | link to [liberapay.com/retroplayer](https://liberapay.com/retroplayer) |
| `play` | Google Play | the Liberapay username as plain text, no link |

Both flavors have the same app id `app.retroplayer`, key and versions. Google
Play only allows in-app donation links for validated tax-exempt organisations;
if Play review still objects to the plain text, remove it from `play`.

## Signing key

- One RSA 4096 key in a PKCS12 keystore, created once:

  ```bash
  keytool -genkeypair -v -storetype PKCS12 -keystore retroplayer-release.jks \
    -alias retroplayer -keyalg RSA -keysize 4096 -validity 36500
  ```

- Keep two offline backups of the keystore and the passwords in a password
  manager. Losing the key means no more updates on F-Droid and Accrescent.
- Certificate fingerprint for F-Droid (`AllowedAPKSigningKeys`, lowercase hex
  without colons):

  ```bash
  keytool -list -v -keystore retroplayer-release.jks -alias retroplayer | grep SHA256
  ```

- Local release builds read `keystore.properties` in the repo root
  (gitignored):

  ```properties
  storeFile=/path/to/retroplayer-release.jks
  storePassword=...
  keyAlias=retroplayer
  keyPassword=...
  ```

  CI uses the environment variables `RELEASE_KEYSTORE` (path),
  `RELEASE_KEYSTORE_PASSWORD`, `RELEASE_KEY_ALIAS` and `RELEASE_KEY_PASSWORD`.
  Without either, release builds are unsigned (that is how F-Droid builds
  them before copying your signature on).

## Reproducible builds

F-Droid rebuilds the tag and ships the developer-signed APK only when its
unsigned build matches it byte for byte (apart from the signature). Rules that
keep the build reproducible:

- The dependency metadata blob is off (`dependenciesInfo`).
- Build-config values come from the commit (`GIT_COMMIT`, commit time), never
  from the branch, the clock or the machine.
- Gradle wrapper (with checksum), JDK major version and build-tools are pinned.
- Release APKs come from a **clean checkout** (CI, or a fresh clone). An
  incremental build after earlier builds can rename one R8 class and no longer
  match F-Droid's clean build.

Checked on 0.9.0's build setup: a full clone and a shallow clone at different
paths give byte-identical unsigned APKs, and a clean signed build passes
F-Droid's comparison against a clean unsigned one. Check again before each
release (`pip install apksigcopier`; `apksigner` from build-tools on `PATH`):

```bash
git clone --depth 1 --branch v0.9.0 <repo> /tmp/rp && cd /tmp/rp
./gradlew --no-build-cache :app:assembleFossRelease          # unsigned, like F-Droid
apksigcopier compare retroplayer-0.9.0.apk --unsigned app/build/outputs/apk/foss/release/app-foss-release-unsigned.apk
apksigner verify --print-certs retroplayer-0.9.0.apk
```

If the comparison fails, `diffoscope` on the two APKs shows the difference.

## Release steps

1. Raise `versionCode` / `versionName`, write the changelog, update
   `doc/USAGE.md` and the store text if features changed.
2. `./gradlew check assembleRelease` and `scripts/device-smoke.sh` on an
   emulator; install the release build on a phone and try the main flows.
3. Merge to `main`, then tag: `git tag v0.9.0 && git push origin v0.9.0`.
4. `.github/workflows/release.yml` builds and attaches to a GitHub Release:
   the signed `foss` APK, the `play` AAB, the `foss` APK set for Accrescent,
   and SHA-256 sums.
5. Stores:
   - **Google Play:** upload the AAB to the closed test track (first release:
     12 testers for 14 days), then promote to production.
   - **F-Droid:** picks the tag up automatically after the first merge request
     to [fdroiddata](https://gitlab.com/fdroid/fdroiddata) (`UpdateCheckMode: Tags`).
   - **Accrescent:** upload the APK set in the developer console.

## First-time store setup

- **Google Play:** developer account; Play App Signing with your own key
  (PEPK export); Data safety "no data collected"; privacy policy URL
  (`PRIVACY.md` on GitHub); no ads; content rating; target audience;
  foreground service declaration for `mediaPlayback`; Android Auto opt-in in
  Advanced settings.
- **F-Droid:** merge request with `metadata/app.retroplayer.yml`: `Builds`
  with `commit: v0.9.0`, `subdir: app`, `gradle: [foss]`; `Binaries:` pointing
  at the GitHub Release APK; `AllowedAPKSigningKeys:` with the certificate
  SHA-256; `Liberapay: retroplayer`; `AutoUpdateMode: Version`,
  `UpdateCheckMode: Tags`. Test with `fdroid build` first.
- **Accrescent:** developer console access; upload the APK set with the
  listing and images. Check their current requirements before submitting.
