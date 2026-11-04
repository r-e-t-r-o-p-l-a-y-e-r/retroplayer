# Manual steps for the first store release

Steps that need the maintainer's accounts or signing key, in order. The
release process itself is in [RELEASE.md](RELEASE.md).

## 1. Signing key

- [x] Create the keystore (RSA 4096, PKCS12):
  ```bash
  keytool -genkeypair -v -storetype PKCS12 -keystore retroplayer-release.jks \
    -alias retroplayer -keyalg RSA -keysize 4096 -validity 36500 \
    -dname "CN=Retro Player"
  ```

- [x] Keep two offline backups of the keystore and the passwords in a password
  manager. Losing the key means no more updates on F-Droid and Accrescent.
- [x] Note the certificate SHA-256 for F-Droid (lowercase hex, no colons):
  ```bash
  keytool -list -v -keystore retroplayer-release.jks -alias retroplayer | grep SHA256
  ```

## 2. GitHub secrets

The release workflow (`.github/workflows/release.yml`) signs the builds on
GitHub's servers, so it needs the keystore and its passwords. GitHub stores
secrets encrypted, never shows them again after saving, hides them in logs,
and does not give them to workflows started from pull requests by forks.

| Secret | Value |
|--------|-------|
| `RELEASE_KEYSTORE_BASE64` | The keystore file as one line of text (base64), because secrets can only hold text |
| `RELEASE_KEYSTORE_PASSWORD` | The password you typed for the keystore in step 1 |
| `RELEASE_KEY_ALIAS` | `retroplayer` (the `-alias` from step 1) |
| `RELEASE_KEY_PASSWORD` | The same password as `RELEASE_KEYSTORE_PASSWORD`: a PKCS12 keystore made with keytool uses one password for the store and the key |

In the browser (needs admin rights on the repository):

1. Open the repository on GitHub → **Settings** → **Secrets and variables** →

   **Actions** → **New repository secret**.
2. Name `RELEASE_KEYSTORE_BASE64`; value: the output of
   ```bash
    base64 -w0 retroplayer-release.jks     # Linux; on macOS: base64 -i retroplayer-release.jks
   ```

    Copy the whole line (several thousand characters, no line breaks).
3. Add the other three secrets the same way.

Or with the GitHub CLI (`gh auth login` first); `gh` asks for the values, so
the passwords do not end up in the shell history:

```bash
base64 -w0 retroplayer-release.jks | gh secret set RELEASE_KEYSTORE_BASE64
gh secret set RELEASE_KEYSTORE_PASSWORD
gh secret set RELEASE_KEY_ALIAS          # type: retroplayer
gh secret set RELEASE_KEY_PASSWORD
gh secret list                           # shows the four names, not the values
```

- [x] `RELEASE_KEYSTORE_BASE64`
- [x] `RELEASE_KEYSTORE_PASSWORD`
- [x] `RELEASE_KEY_ALIAS`
- [x] `RELEASE_KEY_PASSWORD`
- [x] Optional: protect `v*` tags (Settings → Rules → Rulesets → New tag
  ruleset, target `v*`, restrict creations) so only you can start a signed
  release. Anyone with write access can push a tag otherwise.

If a value is wrong, the workflow fails at "Signed APK and AAB" (wrong
password or alias) or prints an empty certificate; set the secret again with
the same name to overwrite it. Wrong secrets never produce a build signed with
another key.

## 3. Remove the old 1.0.0

- [x] Delete the remote tag: `git push origin :refs/tags/v1.0.0`, and delete
  any GitHub Release on that tag.
- [x] On phones with the old build: `adb uninstall app.retroplayer`. It has
  versionCode 2, so Android refuses to install 0.9.0 (versionCode 1) over it.

## 4. Publish the rewritten history, merge, tag 0.9.0

The local history was rewritten so every commit shows
`freier-fall <273219319+freier-fall@users.noreply.github.com>` instead of a
real name and private addresses. GitHub still has the old commits until the
branches are force-pushed. Push **before** merging: merging first would put
the old commits onto `main`, and the rewrite would have to be redone.

- [ ] Replace all branches on GitHub (the open pull request updates itself):

  ```bash
  git push --force --all origin
  ```

- [ ] Check that only the new identity is left (plus `GitHub` for web merges
  and `dependabot[bot]`):

  ```bash
  git fetch origin --prune
  git log --all --format='%an <%ae>%n%cn <%ce>' | sort | uniq -c
  ```

- [ ] Merge the pull request from `feat/native-android` into `main`.
- [ ] Delete the local backup with the old history:
  `rm -rf /data/develop/apps/retroplayer-backup-2026-11-04.git`
- [ ] Optional: the pull request's timeline keeps links to the commits from
  before the force-push. To remove them, ask GitHub Support
  ([support.github.com](https://support.github.com)) to "remove cached views
  and unreachable commits" for the repository.
- [ ] `git tag v0.9.0 && git push origin v0.9.0`
- [ ] Check that the Release workflow publishes `retroplayer-0.9.0.apk`,
  `retroplayer-0.9.0.apks`, `retroplayer-0.9.0-play.aab` and `SHA256SUMS`.

## 5. Google Play

- [ ] Developer account (identity verification).
- [ ] Create the app `app.retroplayer`; Play App Signing with your own key
  (PEPK export of `retroplayer-release.jks`).
- [ ] Store listing from `fastlane/metadata/android/` (text per language,
  images from `en-US/images/`).
- [ ] Data safety: no data collected or shared.
- [ ] Privacy policy URL:
  `https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer/blob/main/PRIVACY.md`
- [ ] Ads: none. Content rating questionnaire. Target audience.
- [ ] Foreground service declaration: `mediaPlayback` (audio playback the user
  starts).
- [ ] Advanced settings → Form factors: opt in to Android Auto.
- [ ] Upload `retroplayer-0.9.0-play.aab` to a closed test. New personal
  accounts need 12 testers for 14 days before production access.
- [ ] Promote to production.

## 6. F-Droid

- [ ] Fork [fdroiddata](https://gitlab.com/fdroid/fdroiddata) and add
  `metadata/app.retroplayer.yml`:
  ```yaml
  Categories:
    - Multimedia
  License: GPL-3.0-or-later
  SourceCode: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer
  IssueTracker: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer/issues
  Liberapay: retroplayer

  RepoType: git
  Repo: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer.git
  Binaries: https://github.com/r-e-t-r-o-p-l-a-y-e-r/retroplayer/releases/download/v%v/retroplayer-%v.apk

  Builds:
    - versionName: 0.9.0
      versionCode: 1
      commit: v0.9.0
      subdir: app
      gradle:
        - yes

  AllowedAPKSigningKeys: <certificate SHA-256 from step 1>

  AutoUpdateMode: Version
  UpdateCheckMode: Tags
  CurrentVersion: 0.9.0
  CurrentVersionCode: 1
  ```

- [ ] Test with `fdroid build app.retroplayer:1` (fdroidserver), then open the
  merge request. Later releases are picked up from the tags.

## 7. Accrescent

- [ ] Register as a developer and check their current submission rules.
- [ ] Upload `retroplayer-0.9.0.apks` from the GitHub Release with the listing
  and images.
