# Releasing Retro Player

One git tag produces every release build. All builds are signed with the same
developer key, so users can switch between F-Droid and GitHub releases
without uninstalling. The app is not published on Google Play.

## Versions

- `versionCode` and `versionName` live in `app/build.gradle.kts`. The first
  store version is `0.9.0` (versionCode 1).
- Every release raises `versionCode` by one and gets the tag `vX.Y.Z` matching
  `versionName`. Before 1.0, minor versions (0.10.0, 0.11.0, ...) mark store
  releases.
- Release notes: `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt`
  (500 characters at most; F-Droid shows them as "What's new"). Translate them
  with `python3 scripts/mt_store_listings.py --field changelog`; the listing
  layout is described in [STORE_LOCALES.md](STORE_LOCALES.md).
- "Support this app" in About links to
  [liberapay.com/retroplayer](https://liberapay.com/retroplayer) in every build.

## Signing key

- One RSA 4096 key in a PKCS12 keystore, created once:

  ```bash
  keytool -genkeypair -v -storetype PKCS12 -keystore retroplayer-release.jks \
    -alias retroplayer -keyalg RSA -keysize 4096 -validity 36500 \
    -dname "CN=Retro Player"
  ```

- Keep two offline backups of the keystore and the passwords in a password
  manager. Losing the key means no more updates on F-Droid.
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

- GitHub repository secrets for `release.yml` (Settings → Secrets and
  variables → Actions): `RELEASE_KEYSTORE_BASE64` (output of
  `base64 -w0 retroplayer-release.jks`), `RELEASE_KEYSTORE_PASSWORD`,
  `RELEASE_KEY_ALIAS`, `RELEASE_KEY_PASSWORD`.

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
./gradlew --no-build-cache :app:assembleRelease              # unsigned, like F-Droid
apksigcopier compare retroplayer-0.9.0.apk --unsigned app/build/outputs/apk/release/app-release-unsigned.apk
apksigner verify --print-certs retroplayer-0.9.0.apk
```

If the comparison fails, `diffoscope` on the two APKs shows the difference.

## Release steps

1. Raise `versionCode` / `versionName`, write the changelog, update
   `doc/USAGE.md` and the store text if features changed.
2. `./gradlew check assembleRelease` and `scripts/device-smoke.sh` on an
   emulator; install the release build on a phone and try the main flows.
3. Merge to `main`, then tag: `git tag v0.9.0 && git push origin v0.9.0`.
4. `.github/workflows/release.yml` checks that the tag matches `versionName`,
   builds the signed APK first in the clean checkout, runs `check`, and
   attaches to a GitHub Release (notes from the changelog):
   `retroplayer-X.Y.Z.apk` and `SHA256SUMS`.
5. F-Droid picks the tag up automatically after the first merge request to
   [fdroiddata](https://gitlab.com/fdroid/fdroiddata) (`UpdateCheckMode: Tags`).

## First-time store setup

Step-by-step checklist: [MANUAL_STEPS.md](MANUAL_STEPS.md).

- **F-Droid:** merge request with `metadata/app.retroplayer.yml`: `Builds`
  with `commit: v0.9.0`, `subdir: app`, `gradle: [yes]`; `Binaries:` pointing
  at the GitHub Release APK; `AllowedAPKSigningKeys:` with the certificate
  SHA-256; `Liberapay: retroplayer`; `AutoUpdateMode: Version`,
  `UpdateCheckMode: Tags`. Test with `fdroid build` first.
